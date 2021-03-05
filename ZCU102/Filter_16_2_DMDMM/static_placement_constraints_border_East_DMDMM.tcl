create_pblock pb_inst_MacroConnEast;
resize_pblock [get_pblocks pb_inst_MacroConnEast] -add SLICE_X41Y180:SLICE_X42Y299
add_cells_to_pblock [get_pblocks pb_inst_MacroConnEast] [get_cells */MacroConnEast*/*];
set_property EXCLUDE_PLACEMENT true [get_pblocks pb_inst_MacroConnEast];

