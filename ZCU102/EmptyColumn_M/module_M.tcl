lappend auto_path D:/prruns/tedtcl
package require ted

source ./static_placement_constraints_border_East_M.tcl
source ./static_placement_constraints_border_West_M.tcl
source ./static_placement_constraints_partial_module_M.tcl
source ./static_interface_constraints_border_East_M.tcl
source ./static_interface_constraints_border_West_M.tcl

place_design

set nodesToBlock {}
set clockIndicesToBlock [lsort -dictionary [struct::set difference [::ted::utility::range 32] {0 10}]]
set clkTiles [get_tiles -filter {TYPE == RCLK_INT_L && GRID_POINT_X>115 && GRID_POINT_X<117 && GRID_POINT_Y == 217}]
foreach clkTile $clkTiles {
	foreach i $clockIndicesToBlock {
			lappend nodesToBlock "${clkTile}/RCLK_INT_L.CLK_LEAF_SITES_${i}\_CLK_IN->>CLK_LEAF_SITES_${i}\_CLK_LEAF"
	}
}

set clkTiles [get_tiles -filter {TYPE == RCLK_INT_L && GRID_POINT_X>115 && GRID_POINT_X<117 && GRID_POINT_Y == 155}]
foreach clkTile $clkTiles {
	foreach i $clockIndicesToBlock { 
			lappend nodesToBlock "${clkTile}/RCLK_INT_L.CLK_LEAF_SITES_${i}\_CLK_IN->>CLK_LEAF_SITES_${i}\_CLK_LEAF"
	}
}

ted::routing::blockNodes [ted::routing::getNetVCC] $nodesToBlock

#top border 124
puts "#top border"
ted::routing::blockFreeNodesOnTiles [ted::routing::getNetVCC] [get_tiles -filter {TYPE==INT_RBRK && GRID_POINT_Y==124 && GRID_POINT_X>115 && GRID_POINT_X<117}]
# -excludeClock 

#bottom border
#CPU PS is on bottom, so no need to block there
#ted::routing::blockFreeNodesOnTiles [ted::routing::getNetVCC] [get_tiles -filter {TYPE==INT_TERM_P && GRID_POINT_Y==248 && GRID_POINT_X>115 && GRID_POINT_X<149}] -excludeClock


#left border
puts "#left border"
source ./blocker_West_M.tcl
#right border
puts "#right border"
source ./blocker_East_M.tcl

write_checkpoint ./placed_design_M_w_blocker -force

route_design

write_checkpoint ./routed_design_M -force

set_property is_route_fixed 0 [ted::routing::getNetVCC]
set_property is_route_fixed 0 [ted::routing::getNetGND]
route_design    -unroute -physical_nets

route_design  -physical_nets

write_checkpoint ./final_M -force 

set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]
set_property BITSTREAM.GENERAL.CRC DISABLE [current_design]
write_bitstream ./final_M -force