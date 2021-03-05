
create_pblock pblock_request_fifo
resize_pblock pblock_request_fifo -add SLICE_X30Y243:SLICE_X32Y246
add_cells_to_pblock pblock_request_fifo [get_cells [list design_1_i/Filter_16_2_0/inst/dafilter/request_fifo]] -clear_locs






create_pblock filterpblock_1
resize_pblock filterpblock_1 -add SLICE_X30Y181:SLICE_X32Y187
add_cells_to_pblock filterpblock_1 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[0].cmp}]] -clear_locs
 
 
create_pblock filterpblock_2
resize_pblock filterpblock_2 -add SLICE_X30Y188:SLICE_X32Y193
add_cells_to_pblock filterpblock_2 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[1].cmp}]] -clear_locs
 
 
create_pblock filterpblock_3
resize_pblock filterpblock_3 -add SLICE_X30Y194:SLICE_X32Y199
add_cells_to_pblock filterpblock_3 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[2].cmp}]] -clear_locs
 
 
create_pblock filterpblock_4
resize_pblock filterpblock_4 -add SLICE_X30Y200:SLICE_X32Y205
add_cells_to_pblock filterpblock_4 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[3].cmp}]] -clear_locs
 
 
create_pblock filterpblock_5
resize_pblock filterpblock_5 -add SLICE_X30Y206:SLICE_X32Y211
add_cells_to_pblock filterpblock_5 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[4].cmp}]] -clear_locs
 
 
create_pblock filterpblock_6
resize_pblock filterpblock_6 -add SLICE_X30Y212:SLICE_X32Y217
add_cells_to_pblock filterpblock_6 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[5].cmp}]] -clear_locs
 
 
create_pblock filterpblock_7
resize_pblock filterpblock_7 -add SLICE_X30Y218:SLICE_X32Y223
add_cells_to_pblock filterpblock_7 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[6].cmp}]] -clear_locs
 
 
create_pblock filterpblock_8
resize_pblock filterpblock_8 -add SLICE_X30Y224:SLICE_X32Y229
add_cells_to_pblock filterpblock_8 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[7].cmp}]] -clear_locs
 
 
create_pblock filterpblock_9
resize_pblock filterpblock_9 -add SLICE_X30Y292:SLICE_X32Y298
add_cells_to_pblock filterpblock_9 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[15].cmp}]] -clear_locs
 
 
create_pblock filterpblock_10
resize_pblock filterpblock_10 -add SLICE_X30Y286:SLICE_X32Y291
add_cells_to_pblock filterpblock_10 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[14].cmp}]] -clear_locs
 
 
create_pblock filterpblock_11
resize_pblock filterpblock_11 -add SLICE_X30Y280:SLICE_X32Y285
add_cells_to_pblock filterpblock_11 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[13].cmp}]] -clear_locs
 
 
create_pblock filterpblock_12
resize_pblock filterpblock_12 -add SLICE_X30Y274:SLICE_X32Y279
add_cells_to_pblock filterpblock_12 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[12].cmp}]] -clear_locs
 
 
create_pblock filterpblock_13
resize_pblock filterpblock_13 -add SLICE_X30Y268:SLICE_X32Y273
add_cells_to_pblock filterpblock_13 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[11].cmp}]] -clear_locs
 
 
create_pblock filterpblock_14
resize_pblock filterpblock_14 -add SLICE_X30Y262:SLICE_X32Y267
add_cells_to_pblock filterpblock_14 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[10].cmp}]] -clear_locs
 
 
create_pblock filterpblock_15
resize_pblock filterpblock_15 -add SLICE_X30Y256:SLICE_X32Y261
add_cells_to_pblock filterpblock_15 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[9].cmp}]] -clear_locs
 
 
create_pblock filterpblock_16
resize_pblock filterpblock_16 -add SLICE_X30Y250:SLICE_X32Y255
add_cells_to_pblock filterpblock_16 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[8].cmp}]] -clear_locs
 
 
 
 
 
 
 
 
 
 
 
 
 

create_pblock filterpblock2_1
resize_pblock filterpblock2_1 -add SLICE_X28Y181:SLICE_X30Y187
add_cells_to_pblock filterpblock2_1 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[0].DNF_And_clauses}]] -clear_locs
 
 
create_pblock filterpblock2_2
resize_pblock filterpblock2_2 -add SLICE_X28Y188:SLICE_X30Y193
add_cells_to_pblock filterpblock2_2 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[1].DNF_And_clauses}]] -clear_locs
 
 
create_pblock filterpblock2_3
resize_pblock filterpblock2_3 -add SLICE_X28Y194:SLICE_X30Y199
add_cells_to_pblock filterpblock2_3 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[2].DNF_And_clauses}]] -clear_locs
 
 
create_pblock filterpblock2_4
resize_pblock filterpblock2_4 -add SLICE_X28Y200:SLICE_X30Y205
add_cells_to_pblock filterpblock2_4 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[3].DNF_And_clauses}]] -clear_locs
 
 
create_pblock filterpblock2_5
resize_pblock filterpblock2_5 -add SLICE_X28Y206:SLICE_X30Y211
add_cells_to_pblock filterpblock2_5 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[4].DNF_And_clauses}]] -clear_locs
 
 
create_pblock filterpblock2_6
resize_pblock filterpblock2_6 -add SLICE_X28Y212:SLICE_X30Y217
add_cells_to_pblock filterpblock2_6 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[5].DNF_And_clauses}]] -clear_locs
 
 
create_pblock filterpblock2_7
resize_pblock filterpblock2_7 -add SLICE_X28Y218:SLICE_X30Y223
add_cells_to_pblock filterpblock2_7 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[6].DNF_And_clauses}]] -clear_locs
 
 
create_pblock filterpblock2_8
resize_pblock filterpblock2_8 -add SLICE_X28Y224:SLICE_X30Y229
add_cells_to_pblock filterpblock2_8 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[7].DNF_And_clauses}]] -clear_locs
 
 
create_pblock filterpblock2_9
resize_pblock filterpblock2_9 -add SLICE_X28Y292:SLICE_X30Y298
add_cells_to_pblock filterpblock2_9 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[15].DNF_And_clauses}]] -clear_locs
 
 
create_pblock filterpblock2_10
resize_pblock filterpblock2_10 -add SLICE_X28Y286:SLICE_X30Y291
add_cells_to_pblock filterpblock2_10 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[14].DNF_And_clauses}]] -clear_locs
 
 
create_pblock filterpblock2_11
resize_pblock filterpblock2_11 -add SLICE_X28Y280:SLICE_X30Y285
add_cells_to_pblock filterpblock2_11 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[13].DNF_And_clauses}]] -clear_locs
 
 
create_pblock filterpblock2_12
resize_pblock filterpblock2_12 -add SLICE_X28Y274:SLICE_X30Y279
add_cells_to_pblock filterpblock2_12 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[12].DNF_And_clauses}]] -clear_locs
 
 
create_pblock filterpblock2_13
resize_pblock filterpblock2_13 -add SLICE_X28Y268:SLICE_X30Y273
add_cells_to_pblock filterpblock2_13 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[11].DNF_And_clauses}]] -clear_locs
 
 
create_pblock filterpblock2_14
resize_pblock filterpblock2_14 -add SLICE_X28Y262:SLICE_X30Y267
add_cells_to_pblock filterpblock2_14 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[10].DNF_And_clauses}]] -clear_locs
 
 
create_pblock filterpblock2_15
resize_pblock filterpblock2_15 -add SLICE_X28Y256:SLICE_X30Y261
add_cells_to_pblock filterpblock2_15 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[9].DNF_And_clauses}]] -clear_locs
 
 
create_pblock filterpblock2_16
resize_pblock filterpblock2_16 -add SLICE_X28Y250:SLICE_X30Y255
add_cells_to_pblock filterpblock2_16 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[8].DNF_And_clauses}]] -clear_locs
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

create_pblock filterpblock3_1
resize_pblock filterpblock3_1 -add SLICE_X26Y181:SLICE_X27Y187
add_cells_to_pblock filterpblock3_1 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[0].fifoLane}]] -clear_locs
 
 
create_pblock filterpblock3_2
resize_pblock filterpblock3_2 -add SLICE_X26Y188:SLICE_X27Y193
add_cells_to_pblock filterpblock3_2 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[1].fifoLane}]] -clear_locs
 
 
create_pblock filterpblock3_3
resize_pblock filterpblock3_3 -add SLICE_X26Y194:SLICE_X27Y199
add_cells_to_pblock filterpblock3_3 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[2].fifoLane}]] -clear_locs
 
 
create_pblock filterpblock3_4
resize_pblock filterpblock3_4 -add SLICE_X26Y200:SLICE_X27Y205
add_cells_to_pblock filterpblock3_4 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[3].fifoLane}]] -clear_locs
 
 
create_pblock filterpblock3_5
resize_pblock filterpblock3_5 -add SLICE_X26Y206:SLICE_X27Y211
add_cells_to_pblock filterpblock3_5 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[4].fifoLane}]] -clear_locs
 
 
create_pblock filterpblock3_6
resize_pblock filterpblock3_6 -add SLICE_X26Y212:SLICE_X27Y217
add_cells_to_pblock filterpblock3_6 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[5].fifoLane}]] -clear_locs
 
 
create_pblock filterpblock3_7
resize_pblock filterpblock3_7 -add SLICE_X26Y218:SLICE_X27Y223
add_cells_to_pblock filterpblock3_7 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[6].fifoLane}]] -clear_locs
 
 
create_pblock filterpblock3_8
resize_pblock filterpblock3_8 -add SLICE_X26Y224:SLICE_X27Y229
add_cells_to_pblock filterpblock3_8 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[7].fifoLane}]] -clear_locs
 
 
create_pblock filterpblock3_9
resize_pblock filterpblock3_9 -add SLICE_X26Y292:SLICE_X27Y298
add_cells_to_pblock filterpblock3_9 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[15].fifoLane}]] -clear_locs
 
 
create_pblock filterpblock3_10
resize_pblock filterpblock3_10 -add SLICE_X26Y286:SLICE_X27Y291
add_cells_to_pblock filterpblock3_10 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[14].fifoLane}]] -clear_locs
 
 
create_pblock filterpblock3_11
resize_pblock filterpblock3_11 -add SLICE_X26Y280:SLICE_X27Y285
add_cells_to_pblock filterpblock3_11 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[13].fifoLane}]] -clear_locs
 
 
create_pblock filterpblock3_12
resize_pblock filterpblock3_12 -add SLICE_X26Y274:SLICE_X27Y279
add_cells_to_pblock filterpblock3_12 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[12].fifoLane}]] -clear_locs
 
 
create_pblock filterpblock3_13
resize_pblock filterpblock3_13 -add SLICE_X26Y268:SLICE_X27Y273
add_cells_to_pblock filterpblock3_13 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[11].fifoLane}]] -clear_locs
 
 
create_pblock filterpblock3_14
resize_pblock filterpblock3_14 -add SLICE_X26Y262:SLICE_X27Y267
add_cells_to_pblock filterpblock3_14 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[10].fifoLane}]] -clear_locs
 
 
create_pblock filterpblock3_15
resize_pblock filterpblock3_15 -add SLICE_X26Y256:SLICE_X27Y261
add_cells_to_pblock filterpblock3_15 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[9].fifoLane}]] -clear_locs
 
 
create_pblock filterpblock3_16
resize_pblock filterpblock3_16 -add SLICE_X26Y250:SLICE_X27Y255
add_cells_to_pblock filterpblock3_16 [get_cells [list {design_1_i/Filter_16_2_0/inst/dafilter/genblk2[8].fifoLane}]] -clear_locs
 
 
 
 