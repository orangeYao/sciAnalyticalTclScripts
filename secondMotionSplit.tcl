set temperautre "../../310"
set inputgro "../../splitDMPC.gro"
set inputtrr "KsplitDMPC.trr" 
set inputtrr $temperautre$inputtrr
set outputpdb "_310.pdb"
set DMPC "DMPC"

puts ""
puts ""

set molid [mol new $inputgro type gro waitfor all] 
mol addfile $inputtrr type trr waitfor all molid $molid
set nf [molinfo $molid get numframes]

for {set i 2 } { $i < $nf } {incr i } { 
    #27 to 519 (<520) DMPC
    puts $i
    for {set j 1} {$j < 500} {incr j } {

        #set frame 1 reference, 
        set sel_rotate1 [atomselect $molid "resname $DMPC and resid $j and (name C212 C213 C214)" frame 1]
        set sel_rotate2 [atomselect $molid "resname $DMPC and resid $j and (name C312 C313 C314)" frame 1]
        set test [vecsub [measure center $sel_rotate1] [measure center $sel_rotate2]]
        set rotate_ref [lreplace [vecsub [measure center $sel_rotate1] [measure center $sel_rotate2]] 2 2 0]

        set sel1 [atomselect $molid "resname $DMPC and resid $j" frame 1]
        set r1_ref [measure center $sel1]
        
        $sel_rotate1 delete
        $sel_rotate2 delete
        $sel1 delete

        #rotation movement around z axis
        set sel_rotate1 [atomselect $molid "resname $DMPC and resid $j and (name C212 C213 C214)" frame $i]
        set sel_rotate2 [atomselect $molid "resname $DMPC and resid $j and (name C312 C313 C314)" frame $i]
        set rotate [lreplace [vecsub [measure center $sel_rotate1] [measure center $sel_rotate2]] 2 2 0]        


        set sel1 [atomselect $molid "resname $DMPC and resid $j" frame $i]
        set c_alpha [expr [vecdot $rotate $rotate_ref]/[veclength $rotate_ref] / [veclength $rotate]]
        set judge [lindex [veccross $rotate $rotate_ref] 2] 

        if {$judge < 0} {
            set alpha [expr acos($c_alpha)/3.141592653*180]
        } else {
            set alpha [expr acos($c_alpha)/3.141592653*180*(-1)]    
        }

        $sel1 delete


        set sel1 [atomselect $molid "resname $DMPC and resid $j" frame 1]
        $sel1 move [transaxis z $alpha]

        ####translational movement 
        
        set r1 [measure center $sel1]

        set toMove [vecsub $r1_ref $r1]
        $sel1 moveby $toMove
        #puts "after movement [measure center $sel1]"
        $sel_rotate1 delete
        $sel_rotate2 delete
        $sel1 delete
    }
    #set select_all [atomselect $molid "all" frame 1] 
    #$select_all writepdb $i$outputpdb

    set select_all [atomselect $molid "resname $DMPC and hydrogen" frame 1] 
    $select_all writepdb $i$outputpdb

    $select_all delete
}

mol delete $molid
exit
