#modified by zhiyao, from Kevin
# Protocol:
# for numframes
#     for selections
#         open file for writing
#         [for segments]
#             call measure scripts
#         [end]
#     [end]
# [end]

proc findSaltBridges { nn ondist } {
    set sel1 [atomselect top "(lipid and oxygen)" frame $nn]
    set sel2 [atomselect top "(protein and nitrogen)" frame $nn]
    set tmpList [measure contacts $ondist $sel1 $sel2]
    
	puts [$sel1 num]
	puts [$sel2 num]
    $sel1 delete
    $sel2 delete
    
#    foreach i [lindex $tmpList 0] j [lindex $tmpList 1] {
#        set potPairs($i,$j) 1
#    }
#
#    foreach pair [array names potPairs] {
#    
#        foreach { ac ba } [split $pair ,] break
#
#        set refAc [atomselect top "same residue as index $ac"]
#        set refBa [atomselect top "same residue as index $ba"]
#        set refAcIndex [lindex [$refAc list] 0]
#        set refBaIndex [lindex [$refBa list] 0]
#
#
#        if [info exists finalPairs($refAcIndex,$refBaIndex)] {
#          unset potPairs($ac,$ba)
#        } else {
#          set acName [lindex [$refAc get resname] 0]
#          set acId [lindex [$refAc get resid] 0]
#          set acSegname [lindex [$refAc get segname] 0]
#          set baName [lindex [$refBa get resname] 0]
#          set baId [lindex [$refBa get resid] 0]
#          set baSegname [lindex [$refBa get segname] 0]
#          if {$acSegname ne $baSegname} {
#            set finalPairs($refAcIndex,$refBaIndex) 1
#            set out_line [join "FOUND: $acSegname $acName $acId - $baSegname $baName $baId"]
#            puts "$out_line"
#          }
#        }
#        $refAc delete
#        $refBa delete
#    }
#    set res [format "%d" [llength [array names finalPairs]]]
    set res [format "%d" [llength [lindex $tmpList 0]]]
    return $res

}

# /------------------/

# /     Main Body    /
# /------------------/

# !!!Important!!!
# Deleting existing files as we APPEND instead of trashing and opening new files
# Make sure you will delete all the existing files
# !!!Important!!!

# Load your structure and frames
set molnum [mol new ../280Kstep7.8_production.gro  waitfor all]
mol addfile ../280Kstep7.8_production.trr -last 2000 waitfor all

set total_frame [molinfo $molnum get numframes]
for {set nn1 0} {$nn1 < 200} {incr nn1} {
    
	set nn [expr 10 * $nn1]
	puts "Frame $nn"

      # Output file name
      set outf [open 280chl.dat "a"]
      # Write TIME at the very first of a line
      set out_line [format "%4.2f" $nn]
      # Definition of segments
      # You are free to use {seg1} {...} {seg2} {...}
          # Call calc funtion you like
          lappend out_line [findSaltBridges $nn 3.5]
      # Write to file
      puts $outf "$out_line"
      # Remember to close the file
      close $outf
    }

quit
