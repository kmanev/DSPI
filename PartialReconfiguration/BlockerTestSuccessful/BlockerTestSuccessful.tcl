# Setup:
# module in CLBs : SLICE_X44Y187 and SLICE_X45Y187
# Fully blocked SW tiles on grid points:
# 179 , 238
# 184 , 238
# 188 , 238
# 193 , 238
# 197 , 238

# 179 , 239
# 197 , 239

# 179 , 241
# 197 , 241

# 179 , 242
# 184 , 242
# 188 , 242
# 193 , 242
# 197 , 242

# partially blocked:
# West: 
# 179 , 240
# East: 
# 197 , 240
lappend auto_path D:/prruns/tedtcl
package require ted

opt_design

# Place connections away from module:
place_cell bd_i/EastCon_0/inst/EtoWbusIn_reg[0] SLICE_X52Y187/AFF
place_cell bd_i/EastCon_0/inst/EtoWbusIn_reg[1] SLICE_X52Y187/BFF
place_cell bd_i/EastCon_0/inst/EtoWbusIn_reg[2] SLICE_X52Y187/CFF
place_cell bd_i/EastCon_0/inst/EtoWbusIn_reg[3] SLICE_X52Y187/DFF
place_cell bd_i/EastCon_0/inst/EtoWbusIn_reg[4] SLICE_X52Y187/EFF
place_cell bd_i/EastCon_0/inst/EtoWbusIn_reg[5] SLICE_X52Y187/FFF
place_cell bd_i/EastCon_0/inst/EtoWbusIn_reg[6] SLICE_X52Y187/GFF
place_cell bd_i/EastCon_0/inst/EtoWbusIn_reg[7] SLICE_X52Y187/HFF

place_cell bd_i/EastCon_0/inst/WtoEbusOut_dst_reg[0] SLICE_X53Y187/AFF
place_cell bd_i/EastCon_0/inst/WtoEbusOut_dst_reg[1] SLICE_X53Y187/BFF
place_cell bd_i/EastCon_0/inst/WtoEbusOut_dst_reg[2] SLICE_X53Y187/CFF
place_cell bd_i/EastCon_0/inst/WtoEbusOut_dst_reg[3] SLICE_X53Y187/DFF
place_cell bd_i/EastCon_0/inst/WtoEbusOut_dst_reg[4] SLICE_X53Y187/EFF
place_cell bd_i/EastCon_0/inst/WtoEbusOut_dst_reg[5] SLICE_X53Y187/FFF
place_cell bd_i/EastCon_0/inst/WtoEbusOut_dst_reg[6] SLICE_X53Y187/GFF
place_cell bd_i/EastCon_0/inst/WtoEbusOut_dst_reg[7] SLICE_X53Y187/HFF

place_cell bd_i/WestCon_0/inst/EtoWbusOut_dst_reg[0] SLICE_X35Y187/AFF
place_cell bd_i/WestCon_0/inst/EtoWbusOut_dst_reg[1] SLICE_X35Y187/BFF
place_cell bd_i/WestCon_0/inst/EtoWbusOut_dst_reg[2] SLICE_X35Y187/CFF
place_cell bd_i/WestCon_0/inst/EtoWbusOut_dst_reg[3] SLICE_X35Y187/DFF
place_cell bd_i/WestCon_0/inst/EtoWbusOut_dst_reg[4] SLICE_X35Y187/EFF
place_cell bd_i/WestCon_0/inst/EtoWbusOut_dst_reg[5] SLICE_X35Y187/FFF
place_cell bd_i/WestCon_0/inst/EtoWbusOut_dst_reg[6] SLICE_X35Y187/GFF
place_cell bd_i/WestCon_0/inst/EtoWbusOut_dst_reg[7] SLICE_X35Y187/HFF

place_cell bd_i/WestCon_0/inst/WtoEbusIn_reg[0] SLICE_X36Y187/AFF
place_cell bd_i/WestCon_0/inst/WtoEbusIn_reg[1] SLICE_X36Y187/BFF
place_cell bd_i/WestCon_0/inst/WtoEbusIn_reg[2] SLICE_X36Y187/CFF
place_cell bd_i/WestCon_0/inst/WtoEbusIn_reg[3] SLICE_X36Y187/DFF
place_cell bd_i/WestCon_0/inst/WtoEbusIn_reg[4] SLICE_X36Y187/EFF
place_cell bd_i/WestCon_0/inst/WtoEbusIn_reg[5] SLICE_X36Y187/FFF
place_cell bd_i/WestCon_0/inst/WtoEbusIn_reg[6] SLICE_X36Y187/GFF
place_cell bd_i/WestCon_0/inst/WtoEbusIn_reg[7] SLICE_X36Y187/HFF

# Place the partial module manually
place_cell bd_i/BlockerTestSuccessful_0/inst/EtoWbusOut_reg[0] SLICE_X44Y187/AFF
place_cell bd_i/BlockerTestSuccessful_0/inst/EtoWbusOut_reg[1] SLICE_X44Y187/BFF
place_cell bd_i/BlockerTestSuccessful_0/inst/EtoWbusOut_reg[2] SLICE_X44Y187/CFF
place_cell bd_i/BlockerTestSuccessful_0/inst/EtoWbusOut_reg[3] SLICE_X44Y187/DFF
place_cell bd_i/BlockerTestSuccessful_0/inst/EtoWbusOut_reg[4] SLICE_X44Y187/EFF
place_cell bd_i/BlockerTestSuccessful_0/inst/EtoWbusOut_reg[5] SLICE_X44Y187/FFF
place_cell bd_i/BlockerTestSuccessful_0/inst/EtoWbusOut_reg[6] SLICE_X44Y187/GFF
place_cell bd_i/BlockerTestSuccessful_0/inst/EtoWbusOut_reg[7] SLICE_X44Y187/HFF

place_cell bd_i/BlockerTestSuccessful_0/inst/WtoEbusOut_reg[0] SLICE_X45Y187/AFF
place_cell bd_i/BlockerTestSuccessful_0/inst/WtoEbusOut_reg[1] SLICE_X45Y187/BFF
place_cell bd_i/BlockerTestSuccessful_0/inst/WtoEbusOut_reg[2] SLICE_X45Y187/CFF
place_cell bd_i/BlockerTestSuccessful_0/inst/WtoEbusOut_reg[3] SLICE_X45Y187/DFF
place_cell bd_i/BlockerTestSuccessful_0/inst/WtoEbusOut_reg[4] SLICE_X45Y187/EFF
place_cell bd_i/BlockerTestSuccessful_0/inst/WtoEbusOut_reg[5] SLICE_X45Y187/FFF
place_cell bd_i/BlockerTestSuccessful_0/inst/WtoEbusOut_reg[6] SLICE_X45Y187/GFF
place_cell bd_i/BlockerTestSuccessful_0/inst/WtoEbusOut_reg[7] SLICE_X45Y187/HFF


place_design

set nodesToBlock {}
#block all clock generators except for clk0 and clk10 
set clockIndicesToBlock [lsort -dictionary [struct::set difference [::ted::utility::range 32] {0 10}]] 
set clkTiles [get_tiles -filter {TYPE == RCLK_INT_L && GRID_POINT_X>=27 && GRID_POINT_X<=33 && GRID_POINT_Y == 217}]
foreach clkTile $clkTiles {
	foreach i $clockIndicesToBlock {
			lappend nodesToBlock "${clkTile}/RCLK_INT_L.CLK_LEAF_SITES_${i}\_CLK_IN->>CLK_LEAF_SITES_${i}\_CLK_LEAF"
	}
}
ted::routing::blockNodes [ted::routing::getNetVCC] $nodesToBlock

# Block all fully blocked tiles
ted::routing::blockFreeNodes [ted::routing::getNetVCC] [get_nodes -of_objects [get_tiles -filter {TYPE==INT && GRID_POINT_Y==238 && GRID_POINT_X==179}] -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR* && NAME!~*CLK* && NAME!~*BUFCE*}]
ted::routing::blockFreeNodes [ted::routing::getNetVCC] [get_nodes -of_objects [get_tiles -filter {TYPE==INT && GRID_POINT_Y==238 && GRID_POINT_X==184}] -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR* && NAME!~*CLK* && NAME!~*BUFCE*}]
ted::routing::blockFreeNodes [ted::routing::getNetVCC] [get_nodes -of_objects [get_tiles -filter {TYPE==INT && GRID_POINT_Y==238 && GRID_POINT_X==188}] -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR* && NAME!~*CLK* && NAME!~*BUFCE*}]
ted::routing::blockFreeNodes [ted::routing::getNetVCC] [get_nodes -of_objects [get_tiles -filter {TYPE==INT && GRID_POINT_Y==238 && GRID_POINT_X==193}] -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR* && NAME!~*CLK* && NAME!~*BUFCE*}]
ted::routing::blockFreeNodes [ted::routing::getNetVCC] [get_nodes -of_objects [get_tiles -filter {TYPE==INT && GRID_POINT_Y==238 && GRID_POINT_X==197}] -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR* && NAME!~*CLK* && NAME!~*BUFCE*}]
ted::routing::blockFreeNodes [ted::routing::getNetVCC] [get_nodes -of_objects [get_tiles -filter {TYPE==INT && GRID_POINT_Y==239 && GRID_POINT_X==179}] -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR* && NAME!~*CLK* && NAME!~*BUFCE*}]
ted::routing::blockFreeNodes [ted::routing::getNetVCC] [get_nodes -of_objects [get_tiles -filter {TYPE==INT && GRID_POINT_Y==239 && GRID_POINT_X==197}] -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR* && NAME!~*CLK* && NAME!~*BUFCE*}]
ted::routing::blockFreeNodes [ted::routing::getNetVCC] [get_nodes -of_objects [get_tiles -filter {TYPE==INT && GRID_POINT_Y==241 && GRID_POINT_X==179}] -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR* && NAME!~*CLK* && NAME!~*BUFCE*}]
ted::routing::blockFreeNodes [ted::routing::getNetVCC] [get_nodes -of_objects [get_tiles -filter {TYPE==INT && GRID_POINT_Y==241 && GRID_POINT_X==197}] -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR* && NAME!~*CLK* && NAME!~*BUFCE*}]
ted::routing::blockFreeNodes [ted::routing::getNetVCC] [get_nodes -of_objects [get_tiles -filter {TYPE==INT && GRID_POINT_Y==242 && GRID_POINT_X==179}] -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR* && NAME!~*CLK* && NAME!~*BUFCE*}]
ted::routing::blockFreeNodes [ted::routing::getNetVCC] [get_nodes -of_objects [get_tiles -filter {TYPE==INT && GRID_POINT_Y==242 && GRID_POINT_X==184}] -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR* && NAME!~*CLK* && NAME!~*BUFCE*}]
ted::routing::blockFreeNodes [ted::routing::getNetVCC] [get_nodes -of_objects [get_tiles -filter {TYPE==INT && GRID_POINT_Y==242 && GRID_POINT_X==188}] -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR* && NAME!~*CLK* && NAME!~*BUFCE*}]
ted::routing::blockFreeNodes [ted::routing::getNetVCC] [get_nodes -of_objects [get_tiles -filter {TYPE==INT && GRID_POINT_Y==242 && GRID_POINT_X==193}] -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR* && NAME!~*CLK* && NAME!~*BUFCE*}]
ted::routing::blockFreeNodes [ted::routing::getNetVCC] [get_nodes -of_objects [get_tiles -filter {TYPE==INT && GRID_POINT_Y==242 && GRID_POINT_X==197}] -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR* && NAME!~*CLK* && NAME!~*BUFCE*}]

# Block the partially blocked tiles:

ted::routing::blockFreeNodes [ted::routing::getNetVCC] [get_nodes -of_objects [get_tiles -filter {TYPE==INT && GRID_POINT_X==179 && GRID_POINT_Y==240}] -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR* && NAME!~*CLK* && NAME!~*BUFCE* && NAME!~*/BQ && NAME!~*/DQ && NAME!~*/FQ && NAME!~*/HQ && NAME!~*/EE2_W_END1* && NAME!~*INT_NODE_GLOBAL_0_INT_OUT1 && NAME!~*INT_NODE_GLOBAL_5_INT_OUT1 && NAME!~*BYPASS_E1 && NAME!~*BYPASS_E3 && NAME!~*BYPASS_E9 && NAME!~*BYPASS_E11 && NAME!~*CTRL_E0 && NAME!~*CTRL_E2 && NAME!~*CTRL_E4 && NAME!~*CTRL_E5 && NAME!~*CTRL_E6 && NAME!~*CTRL_E7 && NAME!~*CLE_CLE_L_SITE_0_BQ && NAME!~*CLE_CLE_L_SITE_0_DQ && NAME!~*CLE_CLE_L_SITE_0_FQ && NAME!~*CLE_CLE_L_SITE_0_HQ && NAME!~*BYPASS_W1 && NAME!~*BYPASS_W3 && NAME!~*BYPASS_W9 && NAME!~*BYPASS_W11 && NAME!~*CTRL_W0 && NAME!~*CTRL_W2 && NAME!~*CTRL_W4 && NAME!~*CTRL_W5 && NAME!~*CTRL_W6 && NAME!~*CTRL_W7 && NAME!~*CLE_CLE_M_SITE_0_BQ && NAME!~*CLE_CLE_M_SITE_0_DQ && NAME!~*CLE_CLE_M_SITE_0_FQ && NAME!~*CLE_CLE_M_SITE_0_HQ && NAME!~*/EE2_W_END2* && NAME!~*/EE2_W_END5* && NAME!~*/EE2_W_END6* && NAME!~*/EE2_W_BEG1* && NAME!~*/EE2_W_BEG2* && NAME!~*/EE2_W_BEG5* && NAME!~*/EE2_W_BEG6* && NAME!~*/WW2_W_END1* && NAME!~*/WW2_W_END2* && NAME!~*/WW2_W_END5* && NAME!~*/WW2_W_END6* && NAME!~*/WW2_W_BEG1* && NAME!~*/WW2_W_BEG2* && NAME!~*/WW2_W_BEG5* && NAME!~*/WW2_W_BEG6* && NAME!~*/EE2_E_END1* && NAME!~*/EE2_E_END2* && NAME!~*/EE2_E_END5* && NAME!~*/EE2_E_END6* && NAME!~*/EE2_E_BEG1* && NAME!~*/EE2_E_BEG2* && NAME!~*/EE2_E_BEG5* && NAME!~*/EE2_E_BEG6* && NAME!~*/WW2_E_END1* && NAME!~*/WW2_E_END2* && NAME!~*/WW2_E_END5* && NAME!~*/WW2_E_END6* && NAME!~*/WW2_E_BEG1* && NAME!~*/WW2_E_BEG2* && NAME!~*/WW2_E_BEG5* && NAME!~*/WW2_E_BEG6* && NAME!~*INT_NODE_SDQ_1_INT_OUT1* && NAME!~*INT_NODE_IMUX_30_INT_OUT1* && NAME!~*INT_NODE_SDQ_4_INT_OUT0* && NAME!~*INT_NODE_SDQ_9_INT_OUT0* && NAME!~*INT_NODE_IMUX_4_INT_OUT1* && NAME!~*INT_NODE_SDQ_10_INT_OUT0* && NAME!~*INT_NODE_SDQ_23_INT_OUT0* && NAME!~*INT_NODE_IMUX_14_INT_OUT0* && NAME!~*INT_NODE_SDQ_24_INT_OUT0* && NAME!~*INT_NODE_SDQ_27_INT_OUT1* && NAME!~*INT_NODE_IMUX_17_INT_OUT1* && NAME!~*INT_NODE_SDQ_30_INT_OUT0* && NAME!~*INT_NODE_SDQ_36_INT_OUT0* && NAME!~*INT_NODE_IMUX_21_INT_OUT1* && NAME!~*INT_NODE_SDQ_37_INT_OUT0* && NAME!~*INT_NODE_SDQ_49_INT_OUT1* && NAME!~*INT_NODE_IMUX_62_INT_OUT1* && NAME!~*INT_NODE_SDQ_52_INT_OUT0* && NAME!~*INT_NODE_SDQ_57_INT_OUT0* && NAME!~*INT_NODE_IMUX_36_INT_OUT1* && NAME!~*INT_NODE_SDQ_58_INT_OUT0* && NAME!~*INT_NODE_SDQ_71_INT_OUT0* && NAME!~*INT_NODE_IMUX_46_INT_OUT0* && NAME!~*INT_NODE_SDQ_72_INT_OUT0* && NAME!~*INT_NODE_SDQ_75_INT_OUT1* && NAME!~*INT_NODE_IMUX_49_INT_OUT1* && NAME!~*INT_NODE_SDQ_78_INT_OUT0* && NAME!~*INT_NODE_SDQ_84_INT_OUT0* && NAME!~*INT_NODE_IMUX_53_INT_OUT1* && NAME!~*INT_NODE_SDQ_85_INT_OUT0* && NAME!~*INT_NODE_SDQ_51_INT_OUT0* && NAME!~*INT_NODE_IMUX_33_INT_OUT1* && NAME!~*INT_NODE_SDQ_55_INT_OUT1* && NAME!~*INT_NODE_SDQ_68_INT_OUT1* && NAME!~*INT_NODE_IMUX_44_INT_OUT0* && NAME!~*INT_NODE_SDQ_77_INT_OUT0* && NAME!~*INT_NODE_SDQ_82_INT_OUT1* && NAME!~*INT_NODE_SDQ_3_INT_OUT0* && NAME!~*INT_NODE_IMUX_1_INT_OUT1* && NAME!~*INT_NODE_SDQ_7_INT_OUT1* && NAME!~*INT_NODE_IMUX_12_INT_OUT0* && NAME!~*INT_NODE_SDQ_29_INT_OUT0* && NAME!~*INT_NODE_SDQ_34_INT_OUT1*}]

ted::routing::blockFreeNodes [ted::routing::getNetVCC] [get_nodes -of_objects [get_tiles -filter {TYPE==INT && GRID_POINT_X==197 && GRID_POINT_Y==240}] -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR* && NAME!~*CLK* && NAME!~*BUFCE* && NAME!~*/BQ && NAME!~*/DQ && NAME!~*/FQ && NAME!~*/HQ && NAME!~*/EE2_W_END1* && NAME!~*INT_NODE_GLOBAL_0_INT_OUT1 && NAME!~*INT_NODE_GLOBAL_5_INT_OUT1 && NAME!~*BYPASS_E1 && NAME!~*BYPASS_E3 && NAME!~*BYPASS_E9 && NAME!~*BYPASS_E11 && NAME!~*CTRL_E0 && NAME!~*CTRL_E2 && NAME!~*CTRL_E4 && NAME!~*CTRL_E5 && NAME!~*CTRL_E6 && NAME!~*CTRL_E7 && NAME!~*CLE_CLE_L_SITE_0_BQ && NAME!~*CLE_CLE_L_SITE_0_DQ && NAME!~*CLE_CLE_L_SITE_0_FQ && NAME!~*CLE_CLE_L_SITE_0_HQ && NAME!~*BYPASS_W1 && NAME!~*BYPASS_W3 && NAME!~*BYPASS_W9 && NAME!~*BYPASS_W11 && NAME!~*CTRL_W0 && NAME!~*CTRL_W2 && NAME!~*CTRL_W4 && NAME!~*CTRL_W5 && NAME!~*CTRL_W6 && NAME!~*CTRL_W7 && NAME!~*CLE_CLE_M_SITE_0_BQ && NAME!~*CLE_CLE_M_SITE_0_DQ && NAME!~*CLE_CLE_M_SITE_0_FQ && NAME!~*CLE_CLE_M_SITE_0_HQ && NAME!~*/EE2_W_END2* && NAME!~*/EE2_W_END5* && NAME!~*/EE2_W_END6* && NAME!~*/EE2_W_BEG1* && NAME!~*/EE2_W_BEG2* && NAME!~*/EE2_W_BEG5* && NAME!~*/EE2_W_BEG6* && NAME!~*/WW2_W_END1* && NAME!~*/WW2_W_END2* && NAME!~*/WW2_W_END5* && NAME!~*/WW2_W_END6* && NAME!~*/WW2_W_BEG1* && NAME!~*/WW2_W_BEG2* && NAME!~*/WW2_W_BEG5* && NAME!~*/WW2_W_BEG6* && NAME!~*/EE2_E_END1* && NAME!~*/EE2_E_END2* && NAME!~*/EE2_E_END5* && NAME!~*/EE2_E_END6* && NAME!~*/EE2_E_BEG1* && NAME!~*/EE2_E_BEG2* && NAME!~*/EE2_E_BEG5* && NAME!~*/EE2_E_BEG6* && NAME!~*/WW2_E_END1* && NAME!~*/WW2_E_END2* && NAME!~*/WW2_E_END5* && NAME!~*/WW2_E_END6* && NAME!~*/WW2_E_BEG1* && NAME!~*/WW2_E_BEG2* && NAME!~*/WW2_E_BEG5* && NAME!~*/WW2_E_BEG6* && NAME!~*INT_NODE_SDQ_1_INT_OUT1* && NAME!~*INT_NODE_IMUX_30_INT_OUT1* && NAME!~*INT_NODE_SDQ_4_INT_OUT0* && NAME!~*INT_NODE_SDQ_9_INT_OUT0* && NAME!~*INT_NODE_IMUX_4_INT_OUT1* && NAME!~*INT_NODE_SDQ_10_INT_OUT0* && NAME!~*INT_NODE_SDQ_23_INT_OUT0* && NAME!~*INT_NODE_IMUX_14_INT_OUT0* && NAME!~*INT_NODE_SDQ_24_INT_OUT0* && NAME!~*INT_NODE_SDQ_27_INT_OUT1* && NAME!~*INT_NODE_IMUX_17_INT_OUT1* && NAME!~*INT_NODE_SDQ_30_INT_OUT0* && NAME!~*INT_NODE_SDQ_36_INT_OUT0* && NAME!~*INT_NODE_IMUX_21_INT_OUT1* && NAME!~*INT_NODE_SDQ_37_INT_OUT0* && NAME!~*INT_NODE_SDQ_49_INT_OUT1* && NAME!~*INT_NODE_IMUX_62_INT_OUT1* && NAME!~*INT_NODE_SDQ_52_INT_OUT0* && NAME!~*INT_NODE_SDQ_57_INT_OUT0* && NAME!~*INT_NODE_IMUX_36_INT_OUT1* && NAME!~*INT_NODE_SDQ_58_INT_OUT0* && NAME!~*INT_NODE_SDQ_71_INT_OUT0* && NAME!~*INT_NODE_IMUX_46_INT_OUT0* && NAME!~*INT_NODE_SDQ_72_INT_OUT0* && NAME!~*INT_NODE_SDQ_75_INT_OUT1* && NAME!~*INT_NODE_IMUX_49_INT_OUT1* && NAME!~*INT_NODE_SDQ_78_INT_OUT0* && NAME!~*INT_NODE_SDQ_84_INT_OUT0* && NAME!~*INT_NODE_IMUX_53_INT_OUT1* && NAME!~*INT_NODE_SDQ_85_INT_OUT0* && NAME!~*INT_NODE_SDQ_51_INT_OUT0* && NAME!~*INT_NODE_IMUX_33_INT_OUT1* && NAME!~*INT_NODE_SDQ_55_INT_OUT1* && NAME!~*INT_NODE_SDQ_68_INT_OUT1* && NAME!~*INT_NODE_IMUX_44_INT_OUT0* && NAME!~*INT_NODE_SDQ_77_INT_OUT0* && NAME!~*INT_NODE_SDQ_82_INT_OUT1* && NAME!~*INT_NODE_SDQ_3_INT_OUT0* && NAME!~*INT_NODE_IMUX_1_INT_OUT1* && NAME!~*INT_NODE_SDQ_7_INT_OUT1* && NAME!~*INT_NODE_IMUX_12_INT_OUT0* && NAME!~*INT_NODE_SDQ_29_INT_OUT0* && NAME!~*INT_NODE_SDQ_34_INT_OUT1*}]

write_checkpoint ./place_design_w_blocker -force

#route the interface wires (32 wires through 32 free spaces)
route_design -nets [get_nets */*Con_0*/*to*]

write_checkpoint ./routed_macros -force

#continue with PR flow
route_design -preserve

write_checkpoint ./routed_design_w_blocker -force

set_property is_route_fixed 1 [ted::routing::getNetGND]
set_property is_route_fixed 0 [ted::routing::getNetVCC]
route_design    -unroute -physical_nets
route_design  -physical_nets

write_checkpoint ./final -force 

set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]
set_property BITSTREAM.GENERAL.CRC DISABLE [current_design]
write_bitstream ./final -force