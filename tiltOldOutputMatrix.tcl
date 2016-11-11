set number "280K"
set groname "../"
set trrname "../"
set outname "long_"
append groname $number "step7.8_production.gro"
append trrname $number "_simple.trr"
append outname  $number "tilt.dat"

mol new $groname  waitfor all
mol addfile $trrname waitfor all

set outfile_t [open "$outname" "w"]
set outfile_p [open "splay.dat" "w"]

for {set nn 0} {$nn < 200} {incr nn 10} {

set p_to_calculate [atomselect top "(name P and within 30 of  protein) and z < 47" frame $nn]
for {set i 0} {$i < [$p_to_calculate num]} {incr i} {
#for {set i 0} {$i < 5} {incr i} 
	##find index of each atom
	set p_index [lindex [$p_to_calculate list] $i]
	##select each atom
	set p_individual [atomselect top "index $p_index" frame $nn]   
	#puts [measure center $p_individual]

	set p_around [atomselect top "(within 12 of index $p_index) and name P" frame $nn]

	puts [$p_around num]
	if {[$p_around num] < 5} {
		puts "error! less than 4 atoms found"
	}

	for {set j 0} {$j < [$p_around num]} {incr j} {
		set p_around_index [lindex [$p_to_calculate list] $j]
		set p_around_individual [atomselect top "index $p_around_index" frame $nn]
		set distance($j) [veclength [vecsub [measure center $p_around_individual] [measure center $p_individual]] ]
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
	}

	#puts [veclength $surface_vector(0)] 
	#puts [veclength $surface_vector(1)]
	#puts [veclength $surface_vector(2)]
	
	set n [vecnorm [veccross $surface_vector(0) $surface_vector(1)] ]
	puts "original nz:  [lindex $n 2]"
	if {[lindex $n 2] < 0} {
		set n [vecnorm [veccross $surface_vector(1) $surface_vector(0)] ]
	}
	puts "n:    $n"

	set N1 [measure center [atomselect top "(same resid as (index $p_index)) and name C1" frame $nn]]
	set N2 [measure center [atomselect top "(same resid as (index $p_index)) and name C214" frame $nn]]
	set N [vecnorm [vecsub $N2 $N1 ]]
	puts  "N:   $N"
	puts "{x,y,z}:   [measure center $p_individual]]"
	
	set tilt [vecsub [vecscale $n  [expr 1/[vecdot $n $N] ] ] $N]
	puts "tilt:  $tilt"

	puts "{x,y,z,u,v,w}:   [measure center $p_individual] $n"
	puts "{x,y,z,c}:   [measure center $p_individual] $tilt"
	puts $outfile_p "[measure center $p_individual] $n"
	puts $outfile_t "[measure center $p_individual] [veclength $tilt]"
	puts ""
	
}
}
close $outfile_p
close $outfile_t
exit
