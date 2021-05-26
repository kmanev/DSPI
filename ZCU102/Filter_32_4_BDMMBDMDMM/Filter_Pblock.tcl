
create_pblock pblock_filter_0
resize_pblock pblock_filter_0 -add {SLICE_X20Y180:SLICE_X32Y189 DSP48E2_X4Y72:DSP48E2_X5Y75 RAMB18_X3Y72:RAMB18_X3Y75 RAMB36_X3Y36:RAMB36_X3Y37}
add_cells_to_pblock pblock_filter_0 [get_cells [list {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[0].cmp} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[0].fifoLane} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[0].DNF_And_clauses}]] -clear_locs


create_pblock pblock_filter_1
resize_pblock pblock_filter_1 -add {SLICE_X20Y185:SLICE_X32Y194 DSP48E2_X4Y74:DSP48E2_X5Y77 RAMB18_X3Y74:RAMB18_X3Y77 RAMB36_X3Y37:RAMB36_X3Y38}
add_cells_to_pblock pblock_filter_1 [get_cells [list {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[1].cmp} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[1].fifoLane} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[1].DNF_And_clauses}]] -clear_locs


create_pblock pblock_filter_2
resize_pblock pblock_filter_2 -add {SLICE_X20Y190:SLICE_X32Y199 DSP48E2_X4Y76:DSP48E2_X5Y79 RAMB18_X3Y76:RAMB18_X3Y79 RAMB36_X3Y38:RAMB36_X3Y39}
add_cells_to_pblock pblock_filter_2 [get_cells [list {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[2].cmp} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[2].fifoLane} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[2].DNF_And_clauses}]] -clear_locs


create_pblock pblock_filter_3
resize_pblock pblock_filter_3 -add {SLICE_X20Y195:SLICE_X32Y204 DSP48E2_X4Y78:DSP48E2_X5Y81 RAMB18_X3Y78:RAMB18_X3Y81 RAMB36_X3Y39:RAMB36_X3Y40}
add_cells_to_pblock pblock_filter_3 [get_cells [list {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[3].cmp} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[3].fifoLane} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[3].DNF_And_clauses}]] -clear_locs


create_pblock pblock_filter_4
resize_pblock pblock_filter_4 -add {SLICE_X20Y200:SLICE_X32Y209 DSP48E2_X4Y80:DSP48E2_X5Y83 RAMB18_X3Y80:RAMB18_X3Y83 RAMB36_X3Y40:RAMB36_X3Y41}
add_cells_to_pblock pblock_filter_4 [get_cells [list {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[4].cmp} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[4].fifoLane} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[4].DNF_And_clauses}]] -clear_locs


create_pblock pblock_filter_5
resize_pblock pblock_filter_5 -add {SLICE_X20Y205:SLICE_X32Y214 DSP48E2_X4Y82:DSP48E2_X5Y85 RAMB18_X3Y82:RAMB18_X3Y85 RAMB36_X3Y41:RAMB36_X3Y42}
add_cells_to_pblock pblock_filter_5 [get_cells [list {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[5].cmp} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[5].fifoLane} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[5].DNF_And_clauses}]] -clear_locs


create_pblock pblock_filter_6
resize_pblock pblock_filter_6 -add {SLICE_X20Y210:SLICE_X32Y219 DSP48E2_X4Y84:DSP48E2_X5Y87 RAMB18_X3Y84:RAMB18_X3Y87 RAMB36_X3Y42:RAMB36_X3Y43}
add_cells_to_pblock pblock_filter_6 [get_cells [list {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[6].cmp} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[6].fifoLane} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[6].DNF_And_clauses}]] -clear_locs


create_pblock pblock_filter_7
resize_pblock pblock_filter_7 -add {SLICE_X20Y215:SLICE_X32Y224 DSP48E2_X4Y86:DSP48E2_X5Y89 RAMB18_X3Y86:RAMB18_X3Y89 RAMB36_X3Y43:RAMB36_X3Y44}
add_cells_to_pblock pblock_filter_7 [get_cells [list {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[7].cmp} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[7].fifoLane} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[7].DNF_And_clauses}]] -clear_locs


create_pblock pblock_filter_8
resize_pblock pblock_filter_8 -add {SLICE_X20Y290:SLICE_X32Y299 DSP48E2_X4Y116:DSP48E2_X5Y119 RAMB18_X3Y116:RAMB18_X3Y119 RAMB36_X3Y58:RAMB36_X3Y59}
add_cells_to_pblock pblock_filter_8 [get_cells [list {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[15].fifoLane} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[15].cmp} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[15].DNF_And_clauses}]] -clear_locs


create_pblock pblock_filter_9
resize_pblock pblock_filter_9 -add {SLICE_X20Y285:SLICE_X32Y294 DSP48E2_X4Y114:DSP48E2_X5Y117 RAMB18_X3Y114:RAMB18_X3Y117 RAMB36_X3Y57:RAMB36_X3Y58}
add_cells_to_pblock pblock_filter_9 [get_cells [list {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[14].fifoLane} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[14].cmp} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[14].DNF_And_clauses}]] -clear_locs


create_pblock pblock_filter_10
resize_pblock pblock_filter_10 -add {SLICE_X20Y280:SLICE_X32Y289 DSP48E2_X4Y112:DSP48E2_X5Y115 RAMB18_X3Y112:RAMB18_X3Y115 RAMB36_X3Y56:RAMB36_X3Y57}
add_cells_to_pblock pblock_filter_10 [get_cells [list {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[13].fifoLane} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[13].cmp} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[13].DNF_And_clauses}]] -clear_locs


create_pblock pblock_filter_11
resize_pblock pblock_filter_11 -add {SLICE_X20Y275:SLICE_X32Y284 DSP48E2_X4Y110:DSP48E2_X5Y113 RAMB18_X3Y110:RAMB18_X3Y113 RAMB36_X3Y55:RAMB36_X3Y56}
add_cells_to_pblock pblock_filter_11 [get_cells [list {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[12].fifoLane} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[12].cmp} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[12].DNF_And_clauses}]] -clear_locs


create_pblock pblock_filter_12
resize_pblock pblock_filter_12 -add {SLICE_X20Y270:SLICE_X32Y279 DSP48E2_X4Y108:DSP48E2_X5Y111 RAMB18_X3Y108:RAMB18_X3Y111 RAMB36_X3Y54:RAMB36_X3Y55}
add_cells_to_pblock pblock_filter_12 [get_cells [list {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[11].fifoLane} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[11].cmp} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[11].DNF_And_clauses}]] -clear_locs


create_pblock pblock_filter_13
resize_pblock pblock_filter_13 -add {SLICE_X20Y265:SLICE_X32Y274 DSP48E2_X4Y106:DSP48E2_X5Y109 RAMB18_X3Y106:RAMB18_X3Y109 RAMB36_X3Y53:RAMB36_X3Y54}
add_cells_to_pblock pblock_filter_13 [get_cells [list {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[10].fifoLane} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[10].cmp} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[10].DNF_And_clauses}]] -clear_locs


create_pblock pblock_filter_14
resize_pblock pblock_filter_14 -add {SLICE_X20Y260:SLICE_X32Y269 DSP48E2_X4Y104:DSP48E2_X5Y107 RAMB18_X3Y104:RAMB18_X3Y107 RAMB36_X3Y52:RAMB36_X3Y53}
add_cells_to_pblock pblock_filter_14 [get_cells [list {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[9].fifoLane} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[9].cmp} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[9].DNF_And_clauses}]] -clear_locs


create_pblock pblock_filter_15
resize_pblock pblock_filter_15 -add {SLICE_X20Y255:SLICE_X32Y264 DSP48E2_X4Y102:DSP48E2_X5Y105 RAMB18_X3Y102:RAMB18_X3Y105 RAMB36_X3Y51:RAMB36_X3Y52}
add_cells_to_pblock pblock_filter_15 [get_cells [list {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[8].fifoLane} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[8].cmp} {design_1_i/Filter_32_4_0/inst/dafilter/genblk2[8].DNF_And_clauses}]] -clear_locs


