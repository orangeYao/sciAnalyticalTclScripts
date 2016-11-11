set number "310K"
set groname "../"
set trrname "../"
set outname "long_"
append groname $number "step7.8_production.gro"
append trrname $number "_simple.trr"
append outname  $number "tiltWithBeta.pdb"

puts "" 
puts "" 

mol new $groname  waitfor all
mol addfile $trrname waitfor all

puts "" 
puts "" 



for {set i 0} {$i < 600 } {incr i} {
      set summation($i) 0
}

set count_frame 0

#set last_frame 200
set last_frame 100 

#for {set nn 0} {$nn < 200} {incr nn 10} {
for {set nn 0} {$nn < [expr $last_frame + 1]} {incr nn 1} {

	incr count_frame
	#set p_to_calculate [atomselect top "(name P and within 30 of  protein) and z < 47" frame $nn]
	set p_to_calculate [atomselect top "name P and z < 47" frame $nn]

	for {set i 0} {$i < [$p_to_calculate num]} {incr i} {
		##find index of each atom
		set p_index [lindex [$p_to_calculate list] $i]
		##select each atom
		set p_individual [atomselect top "index $p_index" frame $nn]   

		set p_around [atomselect top "(within 20 of index $p_index) and name P" frame $nn]

		if {[$p_around num] < 5} {
			puts "error! less than 4 atoms found"
		}

		for {set j 0} {$j < [$p_around num]} {incr j} {
			set p_around_index [lindex [$p_to_calculate list] $j]
			set p_around_individual [atomselect top "index $p_around_index" frame $nn]
			set distance($j) [veclength [vecsub [measure center $p_around_individual] [measure center $p_individual]] ]
			$p_around_individual delete
		}

		set list [list $distance(0)]
		for {set j 1} {$j < [$p_around num]} {incr j} {
			lappend  list $distance($j)

		}
		set sorted [lrange [lsort -real $list] 1 3]
		#puts $sorted
		
		#using sorted array back to find out 3 nearest atom indexs 
		set count 0
		for {set j 0} {$j < [$p_around num]} {incr j} {
			set p_around_index [lindex [$p_to_calculate list] $j]
			set p_around_individual [atomselect top "index $p_around_index" frame $nn]
			set temp [vecsub [measure center $p_around_individual] [measure center $p_individual]]
			if {[veclength $temp]>= [lindex $sorted 0]  &&  [veclength $temp ]<= [lindex $sorted 2]} {
				#puts [veclength $temp]
				set surface_vector($count) $temp
				################### find N
				set count [expr $count + 1]
			}
			$p_around_individual delete
		}

		
		set n [vecnorm [veccross $surface_vector(0) $surface_vector(1)] ]
		if {[lindex $n 2] < 0} {
			set n [vecnorm [veccross $surface_vector(1) $surface_vector(0)] ]
		}

		set N1select [atomselect top "(same resid as (index $p_index)) and name C1" frame $nn]
		set N2select [atomselect top "(same resid as (index $p_index)) and name C214" frame $nn]
		set N1 [measure center $N1select] 
		set N2 [measure center $N2select]
		set N [vecnorm [vecsub $N2 $N1 ]]
		
		set tilt [vecsub [vecscale $n  [expr 1/[vecdot $n $N] ] ] $N]

		#puts "{x,y,z,c}:   [measure center $p_individual] $tilt"
		if {[veclength $tilt] > 1} {
			set tiltResult 1
		} else {
			set tiltResult [veclength $tilt]
		}

		set idid [$p_individual get resid]


		if {$nn == $last_frame} {
			set oneRes [atomselect top "resid $idid"]
			$oneRes set beta [expr $summation($idid) / $count_frame] 
			$oneRes delete
			puts "beta: resid $idid"
			puts [expr $summation($idid) / $count_frame]
		}

		set summation($idid) [expr $summation($idid) + $tiltResult]

			
		$p_individual delete
		$p_around delete
		$N1select delete
		$N2select delete
		
	}
	puts $nn
	$p_to_calculate delete
	if {$nn == $last_frame} {
		set all [atomselect top all]
		$all writepdb $outname 
	}

}
exit
