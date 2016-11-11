set inputgro "310Kstep7.8_production.gro"
set inputtrr "../310KsplitDMPC.trr"

proc mean {upperMemberList} {
    set result 0
    foreach n $upperMemberList {
        set result [expr $result + $n]
    }
    set averageMember [expr $result / [llength $upperMemberList]]
    return $averageMember
}

set molid [mol new $inputgro type gro waitfor all]
mol addfile $inputtrr type trr waitfor all molid $molid

set sum 0
set count 0
for {set i 2} { $i < $nf } {incr i} {
    mol addfile $inputtrr type trr waitfor all molid $molid

    set upperMember [atomselect $molid "name P and resname DMPC and z < 35"]
    set upperMemberList [$upperMember get {z}]
    set mem_level [mean $upperMemberList]

    set melittin [[atomselect $molid "protein and carbon"] get {z}] 
    set melittin [lsort $melittin]
    set melittin [lrange $melittin end-7 end]
    set meli_level [mean $melittin]

    set depth [expr $meli_level - $mem_level] 

    set sum [$sum + $depth]
    set count [$count + 1]
}

puts [expr $sum / $count]



