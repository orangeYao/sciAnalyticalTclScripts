set inputgro "../310Kstep7.8_production.gro"
set front "../"
#set end "Kstep7.8_production.trr"
set end "K_simple.trr"

set outfile [open "outfile.txt" "w"]

proc mean {upperMemberList} {
    set result 0
    foreach n $upperMemberList {
        set result [expr $result + $n]
    }
    set averageMember [expr $result / [llength $upperMemberList]]
    return $averageMember
}

for {set temp 275} {$temp < 316} {incr temp 5} {

	set inputtrr $front$temp$end

	puts $inputtrr
	set molid [mol new $inputgro type gro waitfor all]
	mol addfile $inputtrr type trr waitfor all molid $molid
	set nf [molinfo $molid get numframes]


	set sum 0
	set count 0
	set errorSum 0
	puts $nf
	for {set i 2} { $i < $nf } {incr i} {

		set upperMember [atomselect $molid "name P and resname DMPC and resid > 276" frame $i]
		set upperMemberList [$upperMember get {z}]
		set mem_level [mean $upperMemberList]


		set melittin [[atomselect $molid "protein and carbon" frame $i] get {z}] 
		set melittin [lsort $melittin]
		set melittin [lrange $melittin end-7 end]
		set meli_level [mean $melittin]



		set depth($i) [expr $meli_level - $mem_level] 
		set sum [expr $sum + $depth($i)]
		set count [expr $count + 1]
	}


	set average [expr $sum / $count]
	for {set i 2} { $i < $nf } {incr i} {
		set	errorSum [expr pow($depth($i) - $average , 2) + $errorSum] 
	}
	puts $count

	set averageError [expr pow ($errorSum / $count, 0.5)]

	set noUse "final result:"
	puts $noUse$inputtrr
	puts $average 
	puts $outfile "$average \t $averageError"
	mol delete $molid
}

exit
