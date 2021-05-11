namespace eval ::ted::architecture::virtex7 {
	proc filter_uturn_wires {} {
		return {NAME=~*/*UTURN*&&NAME!~*/DSP_*&&NAME!~*/BRAM_*}
	}
	
	set belTypesByPRIMITIVE_GROUP [create dict		\
		FLOP_LATCH	[list FF_INIT REG_INIT]		\
	]
	
	proc belTypes_for_cell {cell} {
		return [dict get $::ted::architecture::virtex7::belTypesByPRIMITIVE_GROUP [get_property PRIMITIVE_GROUP $cell]]
	}
}