mol new 2_310.pdb

for {set x 2} {$x <= 101} {incr x} {
    set y $x
    mol addfile [append y "_310.pdb"]
}

animate write dcd {./310.dcd} beg 0 end 99
