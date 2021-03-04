lappend auto_path D:/prruns/tedtcl
package require ted
# Dont change
set yCLKParam1 217
set yCLKParam2 155
set yBorderTop 124
set yBorderBottom 248
set yBorderTopp6 126
set yBorderBottomm6 247
set yBorderTopp7 125
set yBorderBottomm7 246
# reference
#set xBorderWest 187
#set xBorderEast 216
#set xBorderWestOut 185
#set xBorderEastOut 219
# for MMBDMDMM footprint:
set xBorderWest 115
set xBorderEast 149
set xBorderWestOut 112
set xBorderEastOut 152
# for BDMMBDMDMM footprint:
set xBorderWest 105
set xBorderEast 149
set xBorderWestOut 103
set xBorderEastOut 152

opt_design

source ./static_placement_constraints_border_East_BDMMBDMDMM.tcl
source ./static_placement_constraints_border_West_BDMMBDMDMM.tcl
source ./static_placement_constraints_partial_module_BDMMBDMDMM.tcl
source ./static_interface_constraints_border_East_BDMMBDMDMM.tcl
source ./static_interface_constraints_border_West_BDMMBDMDMM.tcl

source ./place_flops_West_BDMMBDMDMM.tcl
source ./place_flops_East_BDMMBDMDMM.tcl

source ./Filter_Pblock_BDMMBDMDMM.tcl
place_design

# source ./static_interface_constraints_border_East.tcl
# source ./static_interface_constraints_border_West.tcl

#top border 124
puts "#top border"
ted::routing::blockFreeNodes [ted::routing::getNetVCC] [get_nodes -of_objects [get_tiles -filter {TYPE==INT_RBRK && GRID_POINT_Y==124 && GRID_POINT_X>105 && GRID_POINT_X<149}] -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR* && NAME!~*CLK* && NAME!~*BUFCE*}]

# -excludeClock 

#bottom border
#CPU PS is on bottom, so no need to block there
#ted::routing::blockFreeNodesOnTiles [ted::routing::getNetVCC] [get_tiles -filter {TYPE==INT_TERM_P && GRID_POINT_Y==248 && GRID_POINT_X>115 && GRID_POINT_X<149}] -excludeClock


#left border
puts "#left border"
source ./blocker_West_BDMMBDMDMM.tcl
#right border
puts "#right border"
source ./blocker_East_BDMMBDMDMM.tcl
# route_design -nets [get_nets */MacroConnWest*/dirTwo*]
# route_design -nets [get_nets */MacroConnWest*/dirOne*]
# route_design -nets [get_nets */MacroConnEast*/dirOne*]
# route_design -nets [get_nets */MacroConnEast*/dirTwo*]

write_checkpoint ./place_design_w_blocker -force

route_design -nets [get_nets */MacroConnWest*/dir*]
route_design -nets [get_nets */MacroConnEast*/dir*]
route_design -nets [get_nets */MacroConnWest*/rstn*]
route_design -nets [get_nets */MacroConnEast*/rstn*]

write_checkpoint ./routed_macros -force

#set_property is_route_fixed 0 [ted::routing::getNetVCC]
#route_design    -unroute -physical_nets

#set nodesToBlock {}

#set clockIndicesToBlock [lsort -dictionary [struct::set difference [::ted::utility::range 32] {0 10}]]
#set clkTiles [get_tiles -filter {TYPE == RCLK_INT_L && GRID_POINT_X>115 && GRID_POINT_X<149 && GRID_POINT_Y == 217}]
#foreach clkTile $clkTiles {
#	foreach i $clockIndicesToBlock {
#			lappend nodesToBlock "${clkTile}/RCLK_INT_L.CLK_LEAF_SITES_${i}\_CLK_IN->>CLK_LEAF_SITES_${i}\_CLK_LEAF"
#	}
#}

#set clkTiles [get_tiles -filter {TYPE == RCLK_INT_L && GRID_POINT_X>115 && GRID_POINT_X<149 && GRID_POINT_Y == 155}]
#foreach clkTile $clkTiles {
#	foreach i $clockIndicesToBlock {
#			lappend nodesToBlock "${clkTile}/RCLK_INT_L.CLK_LEAF_SITES_${i}\_CLK_IN->>CLK_LEAF_SITES_${i}\_CLK_LEAF"
#	}
#}

#ted::routing::blockNodes [ted::routing::getNetVCC] $nodesToBlock

# top-bottom borders
#ted::routing::blockFreeNodesOnTiles [ted::routing::getNetVCC] [get_tiles -filter {TYPE==INT_RBRK && GRID_POINT_Y==124 && GRID_POINT_X>115 && GRID_POINT_X<149}]
# -excludeClock
#ted::routing::blockFreeNodesOnTiles [ted::routing::getNetVCC] [get_tiles -filter {TYPE==INT && GRID_POINT_Y==248 && GRID_POINT_X>115 && GRID_POINT_X<149}]
# -excludeClock
# left-right borders
#ted::routing::blockFreeNodesOnTiles [ted::routing::getNetVCC] [get_tiles -filter {TYPE==INT && GRID_POINT_X==112 && GRID_POINT_Y>124 && GRID_POINT_Y<248}]
#ted::routing::blockFreeNodesOnTiles [ted::routing::getNetVCC] [get_tiles -filter {TYPE==INT && GRID_POINT_X==152 && GRID_POINT_Y>124 && GRID_POINT_Y<248}]

route_design -preserve

write_checkpoint ./routed_design_w_blocker -force

set_property is_route_fixed 1 [ted::routing::getNetGND]
set_property is_route_fixed 0 [ted::routing::getNetVCC]
route_design    -unroute -physical_nets
route_design  -physical_nets

write_checkpoint ./final_filter -force 

set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]
set_property BITSTREAM.GENERAL.CRC DISABLE [current_design]
write_bitstream ./final_filter -force