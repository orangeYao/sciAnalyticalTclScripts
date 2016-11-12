set number "275K"
set groname "../"
set trrname "../"
set outfile2 ""
set lip1 "DMPC"
set lip3 "CHL1"
append groname $number "step7.8_production.gro"
append trrname $number "_simple.trr"
append outfile2  $number "splay.dat"

mol new $groname  waitfor all
mol addfile $trrname waitfor all

set outfile2 [open "$outfile2" "w"]
set numOfPoint 180.0
set rightPoint 180
set leftPoint 0
set step [expr ($rightPoint - $leftPoint) / $numOfPoint]
for {set i 0} {$i <  [expr 1 + $numOfPoint]} {incr i} {
      set count($i) 0
}

#200 frames
for {set nn 0} {$nn < 200} {incr nn 1} {
	puts "frame:   $nn"
	set p_to_calculate [atomselect top "name P" frame $nn]

	for {set i 0} {$i < [$p_to_calculate num]} {incr i} {
		set p_index [lindex [$p_to_calculate get resid] $i]
		set ctail_sel [atomselect top "resid $p_index and name C212 C213 C214 C312 C313 C314" frame $nn]
		set ctail [measure center $ctail_sel]
		set pnhead_sel [atomselect top "resid $p_index and name P C2" frame $nn]
		set pnhead [measure center $pnhead_sel ]
		set t [vecnorm [vecsub $ctail $pnhead]]
		set p_to_calculate2 [atomselect top "(resname $lip1  and name C2) and (within 10.0 of (resid $p_index and name C2)) and not (resid $p_index)" frame $nn]
		puts "num surrounding [$p_to_calculate2 num]"
		set res_list2 [$p_to_calculate2 get resid]
		foreach id_res2 $res_list2 {
			set pnhead2_sel [atomselect top "resid $id_res2 and name P C2" frame $nn]
			set pnhead2 [measure center $pnhead2_sel]
			set ctail2_sel [atomselect top "resid $id_res2 and name C212 C213 C214 C312 C313 C314" frame $nn]			
			set ctail2 [measure center $ctail2_sel]
			set t2 [vecnorm [vecsub $ctail2 $pnhead2]]
			set c_alpha [expr [vecdot $t $t2]/[veclength $t] / [veclength $t2]]
			set alpha [expr acos ($c_alpha)/3.141592653*180]
			puts "alhua is $alpha"
			set index [expr round([expr ($alpha - $leftPoint)/$step])]
			set count($index) [expr $count($index) + 1] 	
			$pnhead2_sel delete
			$ctail2_sel delete
		}
		$p_to_calculate2 delete
		$pnhead_sel delete
        $ctail_sel delete
	}
	$p_to_calculate delete
}

set Sum 0.0
for {set i 0} {$i <  $numOfPoint} {incr i} {
	puts "$count($i)"
	set Sum [expr $Sum + $count($i)]
}
set normalToUnit [expr $Sum / $numOfPoint * ($rightPoint - $leftPoint)]

puts $outfile2 $Sum
for {set i 0} {$i <  $numOfPoint } {incr i} {
             #   puts "[expr $leftPoint + $i * $step + 0.5 * $step] \t [expr $count($i) / $normalToUnit]"
             #  puts "[expr $leftPoint + $i * $step + 0.5 * $step] \t [expr $count($i)* 1] "
		set Palpha [expr $count($i) / $normalToUnit]
		set xalpha [expr [expr $leftPoint + $i * $step + 0.5 * $step]/180*3.141592653]
		set answer [expr -1 * log ([expr $Palpha/sin($xalpha)])]
		puts $answer
		puts $outfile2 "[expr pow($leftPoint + $i * $step + 0.5 * $step, 2)] \t  $answer"
}

close $outfile2
exit
