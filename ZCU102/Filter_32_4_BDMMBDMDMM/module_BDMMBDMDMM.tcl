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

set nodesToBlock {}
#block all clock generators except for clk0 and clk10 
set clockIndicesToBlock [lsort -dictionary [struct::set difference [::ted::utility::range 32] {0 10}]] 
set clkTiles [get_tiles -filter {TYPE == RCLK_INT_L && GRID_POINT_X>97 && GRID_POINT_X<162 && GRID_POINT_Y == 217}]
foreach clkTile $clkTiles {
	foreach i $clockIndicesToBlock {
			lappend nodesToBlock "${clkTile}/RCLK_INT_L.CLK_LEAF_SITES_${i}\_CLK_IN->>CLK_LEAF_SITES_${i}\_CLK_LEAF"
	}
}

set clkTiles [get_tiles -filter {TYPE == RCLK_INT_L && GRID_POINT_X>97 && GRID_POINT_X<162 && GRID_POINT_Y == 155}]
foreach clkTile $clkTiles {
	foreach i $clockIndicesToBlock {
			lappend nodesToBlock "${clkTile}/RCLK_INT_L.CLK_LEAF_SITES_${i}\_CLK_IN->>CLK_LEAF_SITES_${i}\_CLK_LEAF"
	}
}

ted::routing::blockNodes [ted::routing::getNetVCC] $nodesToBlock

# TEST!!!!!!
# BFF
# DFF
# FFF
# HFF
# LOGIC_OUTS_E6 LOGIC_OUTS_E10 LOGIC_OUTS_E22 LOGIC_OUTS_E26
# NAME!~*INT_NODE_GLOBAL_0_INT_OUT1 && NAME!~*INT_NODE_GLOBAL_5_INT_OUT1 && 

# NAME!~*BYPASS_E1 && NAME!~*BYPASS_E3 && NAME!~*BYPASS_E9 && NAME!~*BYPASS_E11 && NAME!~*CTRL_E0 && NAME!~*CTRL_E2 && NAME!~*E4 && NAME!~*E5 && NAME!~*E6 && NAME!~*E7 && 
# NAME!~*CLE_CLE_L_SITE_0_BQ && NAME!~*CLE_CLE_L_SITE_0_DQ && NAME!~*CLE_CLE_L_SITE_0_FQ && NAME!~*CLE_CLE_L_SITE_0_HQ && 
# NAME!~*BYPASS_W1 && NAME!~*BYPASS_W3 && NAME!~*BYPASS_W9 && NAME!~*BYPASS_W11 && NAME!~*CTRL_W0 && NAME!~*CTRL_W2 && NAME!~*W4 && NAME!~*W5 && NAME!~*W6 && NAME!~*W7 && 
# NAME!~*CLE_CLE_M_SITE_0_BQ && NAME!~*CLE_CLE_M_SITE_0_DQ && NAME!~*CLE_CLE_M_SITE_0_FQ && NAME!~*CLE_CLE_M_SITE_0_HQ && 
#ted::routing::blockFreeNodes [ted::routing::getNetVCC] [get_nodes -of_objects [get_tiles -filter {TYPE==INT && GRID_POINT_X==103 && GRID_POINT_Y>=239 && GRID_POINT_Y<=242}] -filter {
#NAME!~*BYPASS_E1 && NAME!~*BYPASS_E3 && NAME!~*BYPASS_E9 && NAME!~*BYPASS_E11 && NAME!~*CTRL_E0 && NAME!~*CTRL_E2 && NAME!~*CTRL_E4 && NAME!~*CTRL_E5 && NAME!~*CTRL_E6 && NAME!~*CTRL_E7 && 
#NAME!~*CLE_CLE_L_SITE_0_BQ && NAME!~*CLE_CLE_L_SITE_0_DQ && NAME!~*CLE_CLE_L_SITE_0_FQ && NAME!~*CLE_CLE_L_SITE_0_HQ && 
#NAME!~*BYPASS_W1 && NAME!~*BYPASS_W3 && NAME!~*BYPASS_W9 && NAME!~*BYPASS_W11 && NAME!~*CTRL_W0 && NAME!~*CTRL_W2 && NAME!~*CTRL_W4 && NAME!~*CTRL_W5 && NAME!~*CTRL_W6 && NAME!~*CTRL_W7 && 
#NAME!~*CLE_CLE_M_SITE_0_BQ && NAME!~*CLE_CLE_M_SITE_0_DQ && NAME!~*CLE_CLE_M_SITE_0_FQ && NAME!~*CLE_CLE_M_SITE_0_HQ && 
#NAME!~*INT_NODE_GLOBAL_0_INT_OUT1 && NAME!~*INT_NODE_GLOBAL_5_INT_OUT1 && !IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR* && NAME!~*CLK* && NAME!~*BUFCE* && NAME!~*/EE2_W_END1* && NAME!~*/EE2_W_END2* && NAME!~*/EE2_W_END5* && NAME!~*/EE2_W_END6* && NAME!~*/EE2_W_BEG1* && NAME!~*/EE2_W_BEG2* && NAME!~*/EE2_W_BEG5* && NAME!~*/EE2_W_BEG6* && NAME!~*/WW2_W_END1* && NAME!~*/WW2_W_END2* && NAME!~*/WW2_W_END5* && NAME!~*/WW2_W_END6* && NAME!~*/WW2_W_BEG1* && NAME!~*/WW2_W_BEG2* && NAME!~*/WW2_W_BEG5* && NAME!~*/WW2_W_BEG6* && NAME!~*/EE2_E_END1* && NAME!~*/EE2_E_END2* && NAME!~*/EE2_E_END5* && NAME!~*/EE2_E_END6* && NAME!~*/EE2_E_BEG1* && NAME!~*/EE2_E_BEG2* && NAME!~*/EE2_E_BEG5* && NAME!~*/EE2_E_BEG6* && NAME!~*/WW2_E_END1* && NAME!~*/WW2_E_END2* && NAME!~*/WW2_E_END5* && NAME!~*/WW2_E_END6* && NAME!~*/WW2_E_BEG1* && NAME!~*/WW2_E_BEG2* && NAME!~*/WW2_E_BEG5* && NAME!~*/WW2_E_BEG6* && NAME!~*INT_NODE_SDQ_1_INT_OUT1* && NAME!~*INT_NODE_IMUX_30_INT_OUT1* && NAME!~*INT_NODE_SDQ_4_INT_OUT0* && NAME!~*INT_NODE_SDQ_9_INT_OUT0* && NAME!~*INT_NODE_IMUX_4_INT_OUT1* && NAME!~*INT_NODE_SDQ_10_INT_OUT0* && NAME!~*INT_NODE_SDQ_23_INT_OUT0* && NAME!~*INT_NODE_IMUX_14_INT_OUT0* && NAME!~*INT_NODE_SDQ_24_INT_OUT0* && NAME!~*INT_NODE_SDQ_27_INT_OUT1* && NAME!~*INT_NODE_IMUX_17_INT_OUT1* && NAME!~*INT_NODE_SDQ_30_INT_OUT0* && NAME!~*INT_NODE_SDQ_36_INT_OUT0* && NAME!~*INT_NODE_IMUX_21_INT_OUT1* && NAME!~*INT_NODE_SDQ_37_INT_OUT0* && NAME!~*INT_NODE_SDQ_49_INT_OUT1* && NAME!~*INT_NODE_IMUX_62_INT_OUT1* && NAME!~*INT_NODE_SDQ_52_INT_OUT0* && NAME!~*INT_NODE_SDQ_57_INT_OUT0* && NAME!~*INT_NODE_IMUX_36_INT_OUT1* && NAME!~*INT_NODE_SDQ_58_INT_OUT0* && NAME!~*INT_NODE_SDQ_71_INT_OUT0* && NAME!~*INT_NODE_IMUX_46_INT_OUT0* && NAME!~*INT_NODE_SDQ_72_INT_OUT0* && NAME!~*INT_NODE_SDQ_75_INT_OUT1* && NAME!~*INT_NODE_IMUX_49_INT_OUT1* && NAME!~*INT_NODE_SDQ_78_INT_OUT0* && NAME!~*INT_NODE_SDQ_84_INT_OUT0* && NAME!~*INT_NODE_IMUX_53_INT_OUT1* && NAME!~*INT_NODE_SDQ_85_INT_OUT0* && NAME!~*INT_NODE_SDQ_51_INT_OUT0* && NAME!~*INT_NODE_IMUX_33_INT_OUT1* && NAME!~*INT_NODE_SDQ_55_INT_OUT1* && NAME!~*INT_NODE_SDQ_68_INT_OUT1* && NAME!~*INT_NODE_IMUX_44_INT_OUT0* && NAME!~*INT_NODE_SDQ_77_INT_OUT0* && NAME!~*INT_NODE_SDQ_82_INT_OUT1* && NAME!~*INT_NODE_SDQ_3_INT_OUT0* && NAME!~*INT_NODE_IMUX_1_INT_OUT1* && NAME!~*INT_NODE_SDQ_7_INT_OUT1* && NAME!~*INT_NODE_IMUX_12_INT_OUT0* && NAME!~*INT_NODE_SDQ_29_INT_OUT0* && NAME!~*INT_NODE_SDQ_34_INT_OUT1*}]

# NAME!~*BYPASS_E1 && NAME!~*BYPASS_E3 && NAME!~*BYPASS_E9 && NAME!~*BYPASS_E11 && NAME!~*CTRL_E0 && NAME!~*CTRL_E2 && NAME!~*CTRL_E4 && NAME!~*CTRL_E5 && NAME!~*CTRL_E6 && NAME!~*CTRL_E7 && NAME!~*CLE_CLE_L_SITE_0_BQ && NAME!~*CLE_CLE_L_SITE_0_DQ && NAME!~*CLE_CLE_L_SITE_0_FQ && NAME!~*CLE_CLE_L_SITE_0_HQ && NAME!~*BYPASS_W1 && NAME!~*BYPASS_W3 && NAME!~*BYPASS_W9 && NAME!~*BYPASS_W11 && NAME!~*CTRL_W0 && NAME!~*CTRL_W2 && NAME!~*CTRL_W4 && NAME!~*CTRL_W5 && NAME!~*CTRL_W6 && NAME!~*CTRL_W7 && NAME!~*CLE_CLE_M_SITE_0_BQ && NAME!~*CLE_CLE_M_SITE_0_DQ && NAME!~*CLE_CLE_M_SITE_0_FQ && NAME!~*CLE_CLE_M_SITE_0_HQ && 
#top border 124
puts "#top border"
ted::routing::blockFreeNodes [ted::routing::getNetVCC] [get_nodes -of_objects [get_tiles -filter {TYPE==INT_RBRK && GRID_POINT_Y==124 && GRID_POINT_X>105 && GRID_POINT_X<149}] -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR* && NAME!~*CLK* && NAME!~*BUFCE*}]
#ted::routing::blockFreeNodesOnTiles [ted::routing::getNetVCC] [get_tiles -filter {TYPE==INT_RBRK && GRID_POINT_Y==124 && GRID_POINT_X>105 && GRID_POINT_X<149}] -excludeClock
# -excludeClock 

#bottom border
#CPU PS is on bottom and for now not blocking there
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

route_design -nets [get_nets */WestConnection*/dir*]
route_design -nets [get_nets */EastConnection*/dir*]
route_design -nets [get_nets */WestConnection*/rstn*]
route_design -nets [get_nets */EastConnection*/rstn*]

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