package require struct::set
package require struct::list

##
# Helper functions for partial reconfigurable designs
namespace eval ::ted::partial {
	namespace export              \
		getTileDifferences    \
		getPblockOutlierTiles
	
	namespace path [list ::ted {*}[namespace path]]
	
	##
	# Returns the tiles that are different in two rects.
	#
	# To ensure that the rects have the same size the second rect is passed as an offset (see rect::getOffset)
	#
	# @param rect               the rect in which to search
	# @param offset             the offset at which tiles are compared
	#
	# @return                   list of tiles of the source rect that are different/do not exist in the offset rect
	#
	proc getTileDifferences {rect offset} {
		set differences {}
		
		set CountMissing     0
		set CountDifferences 0
		
		foreach tile [rect::getTiles $rect] {
			set targetTile [get_tiles -quiet -filter "GRID_POINT_X == [expr {[get_property GRID_POINT_X $tile] + [dict get $offset left]}] && GRID_POINT_Y == [expr {[get_property GRID_POINT_Y $tile] + [dict get $offset bottom]}]"]
			
			if {[llength $targetTile] == 0} {
				incr CountMissing
				lappend differences $tile
			} elseif {[get_property TILE_TYPE_INDEX $tile] != [get_property TILE_TYPE_INDEX $targetTile]} {
				incr CountDifferences
				lappend differences $tile
			}
		}

		puts "Found ${CountDifferences} differences, encountered ${CountMissing} missing tiles (i.e. could not find matching offset tile)."
		
		return $differences
	}
	
	##
	# Returns tiles used inside a pblock that should not be used
	#
	# @param pblock         pblock to check
	# @param legalOutliers  list of tiles which are expected to be used (i.e. proxylogic) (default {})
	proc getPblockOutlierTiles {pblock {legalOutliers {}}} {
		set usedTiles {}
		
		set pblockRects [ted::rect::ofPblock $pblock]
		
		foreach rect $pblockRects {
			set usedTiles [::struct::set union $usedTiles [ted::rect::getTiles $rect 1 {} -quiet]]
		}
		
		if {$legalOutliers != {}} {
			#set legalTiles [filter $legalOutliers [ted::rect::filterExpression [lindex $pblockRects 0]]]
			
			#foreach rect [lrange $pblockRects 1 end] {
			#	set $legalTiles [::struct::set union $legalTiles [filter $legalOutliers [ted::rect::filterExpression $rect]]]
			#}
			
			#return [::struct::set difference $usedTiles $legalTiles]
			set legalTiles {}
			
			foreach rect $pblockRects {
				lappend legalTiles [filter $legalOutliers [ted::rect::filterExpression $rect]]
			}
			
			return [::struct::set difference $usedTiles [::struct::set union {*}$legalTiles]]
		}
		
		return $usedTiles
	}
	
	##
	# Writes tiles that are different between pblocks to files.
	#
	# The files are named \<pblock1\>_X_\<pblock2\>.pblockDiff
	# As this is a lengthy process, that only needs to be repeated as pblocks change,
	# there is currently only a version of this command available that saves this to a file
	#
	# @param pblocks          list of pblocks to differentiate
	# @param outputDir        directory prefix into which to write the lists of different files
	proc computePblockIncompatibilities {pblocks {outputDir .}} {
		set i 0
		set pblocks [lsort $pblocks]
		
		foreach pblock $pblocks {
			set pblockRect [ted::rect::boundingBox [ted::rect::ofPblock $pblock]]
			
			for {set j [incr i]} {$j < [llength $pblocks]} {incr j} {
				set secondaryPblock [lindex $pblocks $j]
				puts "Computing differences between $pblock and $secondaryPblock"
				ted::writeListFile [file join $outputDir "${pblock}_X_${secondaryPblock}.pblockDiff"] [getTileDifferences $pblockRect [ted::rect::getOffset $pblockRect [ted::rect::boundingBox [ted::rect::ofPblock $secondaryPblock]]]]
			}
		}
	}
	
	##
	# Set prohibit constraints for the tiles not allowed.
	#
	# Pblock differences are compute intenive. Therefore we precompute them using ted::partial::computePblockIncompatibilities,
	# This function works only if the precomputed data is available.
	#
	# As we only compute the differences to pblock with a higher order,
	# we only know the tiles that need to be prohibited in the first pblock.
	# Therefor we implement the blocking in the first available pblock, and return it.
	# Your script should then assign the partial module to that pblock for implementation, as the constraints
	# are not applied to the other pblocks in the list.
	#
	# @param pblocks               list of module pblocks, for which the module should be compatible
	# @param directory             directory from which the precomputed difference files are read (default .)
	#
	# @return                      pblock that has been prepared
	proc blockTileDifferences {pblocks {directory .}} {
		set pblocks [lsort $pblocks]
		set targetPblock [lindex $pblocks 0]
		
		foreach pblock [lrange $pblocks 1 end] {
			set differences [ted::readListFile [file join $directory ${targetPblock}_X_${pblock}.pblockDiff]]
			if {[llength $differences]} {
				set_property PROHIBIT 1 [get_tiles $differences]
			}
		}
		
		return $targetPblock
	}
	
	##
	# Block cells, that are occupied by outliers in other pblocks.
	#
	# @param pblockSpecs          list of {pblock {list-of-legal-outliers}} pairs
	proc blockPblockOutliers {pblockSpecs} {
		foreach {pblock legalOutliers} $pblockSpecs {
			lappend rectAndOutliers [ted::rect::boundingBox [ted::rect::ofPblock $pblock]] [getPblockOutlierTiles $pblock $legalOutliers]
		}
		
		foreach {rect tiles} $rectAndOutliers {
			foreach {otherRect dump} $rectAndOutliers {
				set offset [ted::rect::getOffset $rect $otherRect]
				
				ted::coordinates::blockRelativeTiles $tiles $offset
			}
		}
	}
	
	##
	# Returns nets used inside a pblock that should not be used.
	#
	# WARNING: This wont work for GND/VCC as get_nets GROUNDNETNAME / get_selected_objects do
	# not work on GND/VCC and we alos failed to get these nets back from get_nets -of_objects \<PINWITHGND\>
	#
	# @param pblock         pblock to check
	# @param legalNets      list of nets which are expected to be used (i.e. proxylogic) (default {})
	#
	# @return               list of nets that should not route through the pblock
	proc getPblockOutlierNets {pblock {legalNets {}}} {
		set nets [get_nets -segments -of_objects [rect::getTiles [rect::boundingBox [rect::ofPblock $pblock]]]]
		
		return [struct::set difference $nets $legalNets]
	}
	
	##
	# Export pblocks.
	#
	# Returns the TCL script needed to recreate pblocks.
	#
	# @param pblocks              list of pblock names or objects to export. leave empty to export all pblocks (default {})
	# @param humanReadable        boolean indicating if some of the command should be split for easier reading/understanding.
	#
	# @return                     TCL script (as string) to recreate pblocks.
	proc export_pblocks {{pblocks {}} {humanReadable true}} {
		set exportString {}
	
		foreach pblock [get_pblocks {*}$pblocks] {
			append exportString "#PBLOCK: $pblock\n"
			append exportString "set pblock \[create_pblock $pblock\]\n"
			append exportString "\n"
			
			set properties    {CONTAIN_ROUTING EXCLUDE_PLACEMENT PARENT PARTPIN_SPREADING RESET_AFTER_RECONFIG SNAPPING_MODE}
			set propertyWidth [ted::maxStringLength $properties]
			
			foreach property $properties {
				set propertyValue [get_property $property $pblock]
				
				if {$propertyValue ne {}} {
					append exportString "set_property [format %-*s $propertyWidth $property] [format %-20s $propertyValue] \$pblock\n"
				}
			}
			
			append exportString "\n"

			if {!$humanReadable} {
				#todo: should we use [list x] over {x}?
				append exportString "resize_pblock \$pblock -add \{[lsort [get_property GRID_RANGES $pblock]]\}\n"
				append exportString "add_cells_to_pblock \$pblock \[get_cells \[list [get_cells -quiet -of_objects $pblock]\]\]\n"
			} else {
				set rects [lsort [get_property GRID_RANGES $pblock]]
				
				foreach gridType [get_property GRIDTYPES $pblock] {
					set l [string length $gridType]
					
					proc siev {x} "return \[expr \{\[string compare -length $l \$x $gridType\]==0\}\]"
					
					struct::list split $rects ::ted::partial::siev gridRects rects
					
					append exportString "resize_pblock \$pblock -add \{$gridRects\}\n"
				}
				
				if {[llength $rects]} {
					append exportString "resize_pblock \$pblock -add \{$rects\}\n"
				}
				
				append exportString "\n"
				
				set currentHierarchy {}
				set cellGroup        {}
				set toplevelCells    {}
				
				set cells [lsort [get_cells -quiet -of_objects $pblock]]
				
				if {[llength $cells]} {
					foreach cell $cells {
						if {[regexp {(.*)/.*} $cell . hierarchy]} {
							if {$hierarchy eq $currentHierarchy} {
								lappend cellGroup $cell
							} else {
								if {[llength $cellGroup]} {
									append exportString "add_cells_to_pblock \$pblock \[get_cells \[list $cellGroup\]\]\n"
								}
								set cellGroup $cell
								set currentHierarchy $hierarchy
							}
						} else {
							lappend toplevelCells $cell
						}
					}
					
					if {[llength $cellGroup]} {
						append exportString "add_cells_to_pblock \$pblock \[get_cells \[list $cellGroup\]\]\n"
					}
					
					if {[llength $toplevelCells]} {
						append exportString "add_cells_to_pblock \$pblock \[get_cells \[list $toplevelCells\]\]\n"
					}
				} else {
					#fixme should we put this as a proper info
					puts "Info: no cells assigned to pblock"
				}
			}
		}
		
		return $exportString
	}
}