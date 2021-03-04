lappend auto_path D:/prruns/tedtcl
package require ted

source ./static_placement_constraints_border_East_B.tcl
source ./static_placement_constraints_border_West_B.tcl
source ./static_placement_constraints_partial_module_B.tcl
source ./static_interface_constraints_border_East_B.tcl
source ./static_interface_constraints_border_West_B.tcl

place_design

#top border 124
puts "#top border"
ted::routing::blockFreeNodesOnTiles [ted::routing::getNetVCC] [get_tiles -filter {TYPE==INT_RBRK && GRID_POINT_Y==124 && GRID_POINT_X>123 && GRID_POINT_X<126}]
# -excludeClock 

#bottom border
#CPU PS is on bottom, so no need to block there
#ted::routing::blockFreeNodesOnTiles [ted::routing::getNetVCC] [get_tiles -filter {TYPE==INT_TERM_P && GRID_POINT_Y==248 && GRID_POINT_X>115 && GRID_POINT_X<149}] -excludeClock


#left border
puts "#left border"
source ./blocker_West_B.tcl
#right border
puts "#right border"
source ./blocker_East_B.tcl

write_checkpoint ./placed_design_B_w_blocker -force

route_design

write_checkpoint ./routed_design_B -force

set_property is_route_fixed 0 [ted::routing::getNetVCC]
set_property is_route_fixed 0 [ted::routing::getNetGND]
route_design    -unroute -physical_nets

route_design  -physical_nets

write_checkpoint ./final_B -force 

set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]
set_property BITSTREAM.GENERAL.CRC DISABLE [current_design]
write_bitstream ./final_B -force