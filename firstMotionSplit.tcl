set temperautre 310
set front "../../"
append front $temperautre
set outputpdb "_"
set inputgro "../../splitDMPC.gro"
set inputtrr "KsplitDMPC.trr"
set inputtrr $front$inputtrr
append outputpdb $temperautre ".pdb"
set DMPC "DMPC"

puts ""
puts ""
puts ""


set molid [mol new $inputgro type gro waitfor all]
mol addfile $inputtrr type trr waitfor all molid $molid
set nf [molinfo $molid get numframes]


puts ""
puts ""
puts ""

#the loop in frames is simple
#for each frame $i move the reference DMPC $j to the DMPC $j center in frame 1
#set i = 1 later
for {set i 2 } { $i < $nf } {incr i } { 
    for {set j 1} {$j < 500} {incr j } {

        set sel1 [atomselect $molid "resname $DMPC and resid $j" frame $i]
        set r1_ref [measure center $sel1]
		$sel1 delete

		set sel1 [atomselect $molid "resname $DMPC and resid $j" frame 1] 
		set r1 [measure center $sel1]

		set toMove [vecsub $r1_ref $r1]

		$sel1 moveby $toMove
		$sel1 delete
        
    }
    set select_all [atomselect $molid "resname $DMPC and hydrogen" frame 1]
    $select_all writepdb $i$outputpdb
}

mol delete $molid
exit
