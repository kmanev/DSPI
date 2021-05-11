namespace eval ::ted::architecture::zynquplus {
	proc filter_uturn_wires {} {
		return {(NAME=~"INT_.*TERM_.*/(SOUTH|EAST|WEST|NORTH)BUSOUT_.*")}
	}
	
	proc filter_clock_nodes {} {
		#Slow: 54 seconds - ordering by frequency did not help
		#(INTENT_CODE_NAME==NODE_GLOBAL_VDISTR||INTENT_CODE_NAME==NODE_GLOBAL_VROUTE||INTENT_CODE_NAME==NODE_GLOBAL_HDISTR||INTENT_CODE_NAME==NODE_GLOBAL_HROUTE||INTENT_CODE_NAME==NODE_GLOBAL_BUFG||INTENT_CODE_NAME==NODE_GLOBAL_LEAF)
		#fast: 17 sec - ordering by frequency did not help
		#INTENT_CODE_NAME~=(NODE_GLOBAL_VDISTR|NODE_GLOBAL_VROUTE|NODE_GLOBAL_HDISTR|NODE_GLOBAL_HROUTE|NODE_GLOBAL_BUFG|NODE_GLOBAL_LEAF)
		return {(INTENT_CODE_NAME=~"(NODE_GLOBAL_VDISTR|NODE_GLOBAL_VROUTE|NODE_GLOBAL_HDISTR|NODE_GLOBAL_HROUTE|NODE_GLOBAL_BUFG|NODE_GLOBAL_LEAF)")}
	}
	
	#FLOP_LATCH	[list {[A-H]FF2?}]
	
	#set belTypesByPRIMITIVE_TYPE [dict create		\
	#	CLB.LUT.LUT6_2	[list {SLICE[LM]_[A-H]6LUT}]	\
	#	CLB.LUT.LUT6	[list {SLICE[LM]_[A-H]6LUT}]	\
	#]
	
	# output from [ted::analyze::serializePlacementMap [dict get [ted::analyze::calculatePlacementMap ] placementMap]],
	# handoptimized to group some Bels by regexps
	# LUT6_2 is a macro and has been added manually
	set belTypesByREF_NAME [dict create                      \
		AND2B1L         [list EFF AFF AFF2]              \
		BSCANE2         [list BSCAN1]                    \
		BUFG_PS         [list BUFCE_BUFG_PS]             \
		BUFGCE          [list BUFCE_BUFCE]               \
		BUFGCE_DIV      [list BUFGCE_DIV_BUFGCE_DIV]     \
		BUFGCTRL        [list BUFGCTRL_BUFGCTRL]         \
		DCIRESET        [list DCIRESET]                  \
		DNA_PORTE2      [list DNA_PORT]                  \
		DSP_A_B_DATA    [list DSP_A_B_DATA]              \
		DSP_ALU         [list DSP_ALU]                   \
		DSP_C_DATA      [list DSP_C_DATA]                \
		DSP_M_DATA      [list DSP_M_DATA]                \
		DSP_MULTIPLIER  [list DSP_MULTIPLIER]            \
		DSP_OUTPUT      [list DSP_OUTPUT]                \
		DSP_PREADD      [list DSP_PREADD]                \
		DSP_PREADD_DATA [list DSP_PREADD_DATA]           \
		FDCE            [list {[A-h]FF2?}]               \
		FDPE            [list {[A-h]FF2?}]               \
		FDRE            [list {[A-h]FF2?}]               \
		FDSE            [list {[A-h]FF2?}]               \
		FRAME_ECCE4     [list FRAME_ECC]                 \
		HARD_SYNC       [list HARD_SYNC_SYNC_UNIT]       \
		ICAPE3          [list ICAP_TOP]                  \
		IDELAYCTRL      [list BITSLICE_CONTROL_BEL]      \
		LDCE            [list {[A-h]FF2?}]               \
		LDPE            [list {[A-h]FF2?}]               \
		LUT1            [list {SLICE[LM]_[A-H](6|5)LUT}] \
		LUT2            [list {SLICE[LM]_[A-H](6|5)LUT}] \
		LUT3            [list {SLICE[LM]_[A-H](6|5)LUT}] \
		LUT4            [list {SLICE[LM]_[A-H](6|5)LUT}] \
		LUT5            [list {SLICE[LM]_[A-H](6|5)LUT}] \
		LUT6            [list {SLICE[LM]_[A-H]6LUT}]     \
		MASTER_JTAG     [list MASTER_JTAG]               \
		MMCME4_ADV      [list MMCM_MMCM_TOP]             \
		MUXF7           [list F7MUX]                     \
		MUXF8           [list F8MUX]                     \
		MUXF9           [list F9MUX]                     \
		OR2L            [list AFF AFF2]                  \
		PLLE4_ADV       [list PLL_PLL_TOP]               \
		RAMD32          [list SLICEM_H6LUT]              \
		RAMD64E         [list SLICEM_H6LUT]              \
		RAMS32          [list SLICEM_H6LUT]              \
		RAMS64E         [list SLICEM_H6LUT]              \
		RAMS64E1        [list SLICEM_H6LUT]              \
		RIU_OR          [list RIU_OR_BEL]                \
		STARTUPE3       [list STARTUP]                   \
		SYSMONE4        [list SYSMONE4_SYSMONE4]         \
		TX_BITSLICE_TRI [list TRISTATE_TX_BITSLICE]      \
		USR_ACCESSE2    [list USR_ACCESS]                \
		                                                 \
		LUT6_2          [list {SLICE[LM]_[A-H]6LUT}]     \
	]
	
	proc belTypes_for_cell {cell} {
		return [dict get $::ted::architecture::zynquplus::belTypesByREF_NAME [get_property REF_NAME $cell]]
	}
}