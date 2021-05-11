package require report
package require struct::matrix
package require struct::set

namespace eval ::ted::analyze {
	##
	# Report how often each tile type is present on the chip.
	#
	# Allows to limit the tile types reported to tiles used /not used on the chip,
	# or used a certain amount. Either use one of the preset modes (all, used, unused) or 
	# an expression of an operator (>,<,>=,<=,=) followed by an integer.
	#
	# @param mode           select tile types to report (all, used, unused, or <expr>)
	# @param quiet          boolean, can be used to surpress output
	#
	# @return               a list of tiletype and occurence pairs (lists)
	proc report_tiles {{mode all} {quiet false}} {
		if {$mode ni {all used unused} && ![regexp {^(=[<>]?|[<>]=?)\d*$} $mode]} {
			::ted::utility::errorOut 0 "Unsupported argument, must be either one of {all, used, unused} or an integer"
		}
		
		switch $mode {
			all {
				set conditional {true}
			}
			used {
				set conditional {$count>0}
			}
			unused {
				set conditional {$count==0}
			}
			default {
				set conditional "\$count $mode"
			}
		}
		
		foreach tiletype [list_property_value -class tile TILE_TYPE] {
			set count [llength [get_tiles -filter "TILE_TYPE==$tiletype" -quiet]]
			
			if $conditional {
				lappend tiletypes [list $tiletype $count]
			}
		}
		
		if {!$quiet} {
			foreach tileinfo $tiletypes {
				puts [format "%-30s : %5d" {*}$tileinfo]
			}
		}
		
		return $tiletypes
	}
	
	##
	# Report all properties that can be changed and have been changed by the user.
	#
	# One can set args to "-all" to report all properties that the user can change.
	#
	# @param object    object to analyze
	# @param args      additional arguments to use for generating report, use "-all" to get ALL user writeable properties
	#
	# @return          list of user changeable properties
	proc report_changed_properties {object args} {
		set user_changeable_properties {}
		
		struct::matrix table
		table add columns 3
		
		::report::report tableFormat [table columns] style report_captionedTable
		
		try {
			table add row [list property type value]
			
			foreach line [lrange [split [report_property -return_string $object {*}$args] \n] 1 end] {
				set value [lassign $line property type readOnly]
				
				if {!$readOnly} {
					#puts [format "%-20s (%6s): %s" $property $type $value]
					table add row [list $property $type $value]
					lappend user_changeable_properties $property
				}
			}
			
			table format 2chan tableFormat
		} finally {
			tableFormat destroy
			table destroy
		}
		
		return $user_changeable_properties
	}
	
	##
	# Calculate possible placement for library cells.
	#
	# Returns a placementMap, unselectableMap, magicMap, and noBelsFound.
	#
	#  - placementMap    : list of pair<libCell, list<bels>> which contains all bel types found, which are 
	#                      valid for placement of libCell (this script might error out (see unselectableMap, 
	#                      and magicMap below) causing incomplete lists.
	#  - unselectableMap : list of pair<libCell, bel> which contains the bel property value of a cell, for
	#                      which [get_bels -of_objects $cell] returns nothing
	#  - magicMap        : list of pair<libCell, bel> which contains the bel that could not be selected 
	#                      by get_bels unless the appropriate primitive is placed on it (i.e. FIFOs are 
	#                      placed on RAM bels, which do not identify as FIFO bels unless a FIFO is placed 
	#                      on them)
	#  - noBelsFound     : list of all cells for which no (useable) Bel positions could be computed.
	#
	# @args         arguments, possibly (-all, -exclude <cellnames>, -include <cellnames>), order matters
	#
	# @return       dictionary containing placementMap, unselectableMap, magicMap, noBelsFound. See description above.
	#fixme report cells that could not be placed because the device does not support them
	proc calculatePlacementMap {args} {
		set placementMap    {}
		set unselectableMap {}
		set magicMap        {}
		set noBelsFound     {}
		
		set libCells {}
		
		if {[lindex $args 0] eq {-all} || ![llength $args]} {
			set libCells [get_lib_cells]
			set args [lrange $args 1 end]
		}
		
		while {[llength $args]} {
			switch -exact [lindex $args 0] {
				-include {
					if {[llength $args] < 2} {
						::ted::utility::errorOut 0 "-include option of calculatePlacementMap must be followed by a list of cells."
					}
					
					set libCells [struct::set union $libCells [lindex $args 1]]
					set args [lrange $args 2 end]
				}
				-exclude {
					if {[llength $args] < 2} {
						::ted::utility::errorOut 0 "-exclude option of calculatePlacementMap must be followed by a list of cells."
					}
					
					set libCells [struct::set difference $libCells [lindex $args 1]]
					set args [lrange $args 2 end]
				}
				default {
					::ted::utility::errorOut 0 "Unknown option '[lindex $args 0]' passed to calculatePlacementMap."
				}
			}
		}
		
		set total    [llength $libCells]
		set progress 0
		
		set unblockedSites [get_sites -filter !PROHIBIT]
		
		foreach libCell $libCells {
			incr progress
			puts "$progress/$total $libCell ==="
			
			set cell [ted::utility::createCellUnique probeCell $libCell 1]
			set_property DONT_TOUCH true $cell
			
			set blockedBels {}
			set belTypeList  {}
			
			set caughtPlacerError false
			
			try {
				place_design -no_timing_driven -no_fanout_opt -no_bufg_opt -cells $cell
			} trap {} {result errorDict} {
				if {$result eq {}} {
					puts "assuming interrupt, cancelling"
					return -options $errorDict $result
				}
				
				set caughtPlacerError true
			}
			
			while {!$caughtPlacerError && ![get_msg_config -id [::ted::vivado::getErrorCodeByTag placer.failed.placeAll] -count]} {
				set bel [get_bels -of_objects $cell]
				
				#efuse_usr on virtex7 is placed in the guy, however, the bel can not be selected, resulting in the script crahsing, we have to guard against this 
				if {$bel ne {}} {
					set belType [get_property TYPE $bel]
				} else {
					#can't select the bel
					lappend unselectableMap $libCell [get_property BEL $cell]
					::ted::utility::message 0 "Found none selectable BEL-TYPE for cell $libCell. Bel proerty of cell yields [get_property BEL $cell]." WARNING
					break
				}
				
				## below code was meant for the case if [get_property BEL $cell] is used instead, however for now additional parsing is avoided,
				## also this would be troublesome for non-selectable BELs (i.e. efuse on zyncultrascaleplus, where get_bels returns nothing)
				#set belSubtypeStart [expr {[string last . $belType]+1}]
				
				#if {$belSubtypeStart} {
				#	set shortBelType [string range $belType $belSubtypeStart end]
				#	puts "Truncating belType from $belType to $shortBelType"
				#	set belType $shortBelType
				#}
				
				unplace_cell $cell
				
				set bels [get_bels -filter TYPE==$belType&&!IS_USED&&!PROHIBIT]
				
				if {$bels ne {}} {
					set_property PROHIBIT true $bels
				} else {
					lappend magicMap $libCell $belType
					::ted::utility::message 0 "Found *magic* BEL-TYPE $belType for cell $libCell. Bel can only be selected by this type if a cell is placed on this cell." WARNING
					break
				}
				
				lappend belTypeList $belType
				
				#bad progress report
				puts "$progress/$total $libCell: [string repeat . [llength $belTypeList]] $belType"
				
				if {[llength $bels]} {
					lappend blockedBels $bels
				} else {
					set blockedBels $bels
				}
				
				try {
					#no_timing_driven causes PROHIBIT to be ignored so we cant use that for faster placement after the first placement
					place_design -no_fanout_opt -no_bufg_opt -cells $cell
				} trap {} {result errorDict} {
					if {$result eq {}} {
						puts "assuming interrupt, cancelling"
						return -options $errorDict $result
					}
					
					set caughtPlacerError true
				}
			}
			
			if {[llength $belTypeList]} {
				lappend placementMap $libCell $belTypeList
				set_property PROHIBIT false $blockedBels
				#sometimes Vivado infers a site prohibit, so we reset it between different elements.
				set_property PROHIBIT false $unblockedSites
			} else {
				lappend noBelsFound $libCell
				::ted::utility::message 0 "Found no BEL-TYPE candidates for cell $libCell." WARNING
			}
			
			::ted::utility::removeCell $cell true
		}
		
		#return $placementMap
		return [dict create placementMap $placementMap unselectableMap $unselectableMap magicMap $magicMap noBelsFound $noBelsFound]
	}
	
	proc serializePlacementMap {placementMap} {
		set result "set placementMap \[dict create \n"
		
		struct::matrix table
		table add columns 3
		
		foreach {primitive bels} $placementMap {
			table add row "\"\t\" \"$primitive\" [format {"[list %s]"} $bels]"
		}
		
		append result [table format 2string] "\n]"
		
		table destroy
		
		return $result
	}
}