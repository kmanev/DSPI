package require struct::set

namespace eval ::ted::placer {
	##
	# Datastructure:
	# list <tuple<list<cells>, list<sites>, [additionalData]>>
	
	##
	# Place cells, guiding the placer through prohibits.
	#
	# additionalData in the placement is ignored by this placer.
	#
	# @param targetsPlacement      list <tuple<list<cells>, list<sites>, [additionalData]>>
	proc placeProhibit {targetedPlacement} {
		foreach placement $targetedPlacement {
			lassign $placement cells sites
			
			set prohibitedSites [::struct::set difference [get_sites -filter {!IS_USED&&!PROHIBIT}] $sites]
			set_property PROHIBIT true $prohibitedSites
			place_design -cells $cells
			set_property PROHIBIT false $prohibitedSites
		}
	}
	
	##
	# Place cells, guiding the placer through pblocks.
	#
	# additionalData in the placement is ignored by this placer.
	#
	# @param targetsPlacement      list <tuple<list<cells>, list<sites>, [additionalData]>>
	proc placePBlock {targetedPlacement {temporarilyClearPblocks false}} {
		set temporaryPblocks {}
		set all_cells        {}
		
		if {$temporarilyClearPblocks} {
			set designPblocks [ted::serialize::serialize [get_pblocks]]
		}
		
		foreach placement $targetedPlacement {
			lassign $placement cells sites
			
			set pblock [::ted::utility::createPblockUnique DUMMY_PBLOCK]
			resize_pblock $pblock -add $sites
			add_cells_to_pblock $pblock $cells
			
			lappend all_cells $cells
			lappend temporaryPblocks $pblock
		}
		
		place_design -cells $all_cells
		delete_pblocks $temporaryPblocks
		
		if {$temporarilyClearPblocks} {
			ted::serialize::deserialize $designPblocks
		}
	}
	
	##
	# Place cells, calculates explicit placements and sidesteps the placer.
	#
	# For each cell an additional data list is required which specifies a target by $::ted::coordinates::coordinate_property_x/y
	# Cells are placed as close to this target as possible, considering the x and y cost specified in the tuple.
	#
	# @param targetsPlacement      list <tuple<list<cells>, list<sites>, list<target_x target_y cost_x cost_y>>>
	#TODO: allow a single target cost specification for all cells in a tuple
	proc placeSearch {targetedPlacement} {
		set configMaxCellsBinarySearch 50000
		
		foreach placement $targetedPlacement {
			lassign $placement cells sites targets
			
			unset -nocomplain candidateBelsCache
			
			foreach celltype [lsort -unique [get_property PRIMITIVE_GROUP $cells]] {
				if {[llength $targets]==1} {
					set cellsToPlace [filter $cells PRIMITIVE_GROUP==$celltype]
					set placementTargets $targets
				} else {
					set cellsToPlace {}
					set placementTargets {}
					
					#TODO: better way to filter targets along with cells?
					foreach target $targets cell $cells typeOfCell [get_property PRIMITIVE_GROUP $cells] {
						if {$typeOfCell eq $celltype} {
							lappend cellsToPlace     $cell
							lappend placementTargets $target
						}
					}
				}
					
				set candidateBels_ptr {}
				
				foreach belType [::ted::architecture::call belTypes_for_cell [lindex $cellsToPlace 0]] {
					if {![info exists candidateBelsCache($belType)]} {
						set candidateBelsCache($belType) [get_bels -of_objects $sites -regexp -filter !IS_USED&&TYPE=~${belType}&&!PROHIBIT&&!IS_RESERVED]
					}
					
					lappend candidateBels_ptr $belType
				}
				
				#do the manhatten search (as binary search?, or do we sort the bels into a grid first for repeated searches with different target distance centerpoints)
				if {[llength $cellsToPlace]<=$configMaxCellsBinarySearch} {
					#fixme update the cached free bells
					place_cell [_binarySearch   $cellsToPlace $candidateBels_ptr $placementTargets]
				} else {
					place_cell [_manhattenSearch $cellsToPlace $candidateBels_ptr $placementTargets]
				}
			}
		}
	}
	
	# TODO: IMPLEMENT
	proc _manhattenSearch {cells candidateBelsPtrArray targets} {
		#build grid
		foreach cell $cells target $targets {
			#manhatten search on grid
		}
	}
	
	##
	# @internal
	# Search for placements near a target using binary search. 
	#
	# Searches for allowed positions near target. Internal function,
	# requires candidateBelsCache in the calling namespace.
	#
	# @param cells                  cells to place
	# @param candidateBelsPtrArray  pointers into a candidate bels cache for allowed placements
	# @param targets                target points to place near and assoiciate cost for each cell (list<tuple<target_x,target_y,cost_x,cost_y>>
	#
	# @return                       list of placements (cell belPlacement) for all cells.
	#fixme to long function to debug...
	#fixme optimize placing same elements near same targets (i.e. if there is space left on the last selected tile, reuse the last found tile)
	proc _binarySearch {cells candidateBelsPtrArray targets} {
		upvar candidateBelsCache candidateBelsCache
		
		set x_property $::ted::coordinates::coordinate_property_x
		set y_property $::ted::coordinates::coordinate_property_y
		
		set placements {}
		
		#update candidateBels /tiles
		# TODO: should we use info exists on candidateBels rather than the empty list check?
		#unset -nocomplain candidateBels
		
		set candidateBels {}
		
		foreach candidateBelPtr $candidateBelsPtrArray {
			if {[llength $candidateBels] == 0} {
				set candidateBels $candidateBelsCache($candidateBelPtr)
			} else {
				lappend candidateBels $candidateBelsCache($candidateBelPtr)
			}
		}
		
		set tiles [get_tiles -of_objects $candidateBels]
		
		foreach cell $cells target $targets {
			if {[llength $tiles] == 1} {
				set tileSubset $tiles
				break
			} elseif {[llength $tiles]==0} {
				::ted::utility::errorOut 0 "Failed to place [llength $cells] cells, as no available sites were found. The cells are [join $cells {, }]"
			}
			
			#search by expanding a box around target
			lassign $target target_x target_y cost_x cost_y
			
			#puts "Cost X: $cost_x Cost Y: $cost_y"
			
			set xFirst [expr {$cost_x<$cost_y}]
			
			set x_max [get_property -max $x_property $tiles]
			set x_min [get_property -min $x_property $tiles]
			
			set y_max [get_property -max $y_property $tiles]
			set y_min [get_property -min $y_property $tiles]
			
			set x_fold_min 0
			set y_fold_min 0
			
			if {$target_x < $x_min} {
				set x_fold_min [expr {$x_min - $target_x}]
			} elseif {$target_x > $x_max} {
				set x_fold_min [expr {$target_x-$x_max}]
			}
			
			if {$target_y < $y_min} {
				set y_fold_min [expr {$y_min - $target_y}]
			} elseif {$target_y > $y_max} {
				set y_fold_min [expr {$target_y-$y_max}]
			}
			
			set x_fold_max [expr {max($x_max-$target_x,$target_x-$x_min)}]
			set y_fold_max [expr {max($y_max-$target_y,$target_y-$y_min)}]
			
			#initial step ignores cost
			set x_fold [expr {($x_fold_max+$x_fold_min)/2}]
			set y_fold [expr {($y_fold_max+$y_fold_min)/2}]
			
			#coarse binary search
			while {$x_fold_min!=$x_fold_max || $y_fold_min!=$y_fold_max} {
				#puts "$x_fold_min : $x_fold : $x_fold_max -- $y_fold_min : $y_fold : $y_fold_max"
				#adjust fold
				if {$xFirst} {
					#y is more expensive
					if {$y_fold_min==$y_fold_max} {
						#actually sweep x
						# for the first iteration where it gets locked, y_fold needs the update
						set y_fold $y_fold_max
						set x_fold [expr {($x_fold_max+$x_fold_min)/2}]
					} else {
						#binary search y, adjust x accordingly
						set y_fold [expr {($y_fold_max+$y_fold_min)/2}]
						set x_fold [expr {int(ceil(double(($y_fold+1)*$cost_y-1)/$cost_x))}]
					}
				} else {
					#x is more expensive
					if {$x_fold_min==$x_fold_max} {
						#actually sweep y
						# for the first iteration where it gets locked, x_fold needs the update
						set x_fold $x_fold_max
						set y_fold [expr {($y_fold_max+$y_fold_min)/2}]
					} else {
						#binary search x, adjust y accordingly
						set x_fold [expr {($x_fold_max+$x_fold_min)/2}]
						set y_fold [expr {int(ceil(double(($x_fold+1)*$cost_x-1)/$cost_y))}]
					}

				}
				
				#look at the rectangular area, no need to exclude the empty center
				set tileSubset [filter $tiles "$x_property>=[expr {${target_x}-${x_fold}}] && $x_property<=[expr {${target_x}+${x_fold}}] && $y_property>=[expr {${target_y}-${y_fold}}] && $y_property<=[expr {${target_y}+${y_fold}}]"]
				
				set candidateTileCount [llength $tileSubset]
				
				#puts "candidate tiles [llength $tileSubset]"
				
				if {$candidateTileCount==0} {
					#update min values
					#WARNING: there might still be a tile with a lower x/y value, but it will not be inside the rect specified by this but to its side.
					#Note: expr required to avoid binary search looping forever (i.e. at min=2, max=3, the update will always be 2, due to rounding, and this would keep going forever)
					#Note2: avoid incrementing past the max in the lock phase
					
					#if we have not locked the expensive yet, do not update the min for the cheaper dimension
					if {$xFirst} {
						if {$y_fold_min==$y_fold_max} {
							set x_fold_min [expr {min($x_fold+1, $x_fold_max)}]
						}
						
						set y_fold_min [expr {min($y_fold+1, $y_fold_max)}]
					} else {
						set x_fold_min [expr {min($x_fold+1, $x_fold_max)}]
						
						if {$x_fold_min==$x_fold_max} {
							set y_fold_min [expr {min($y_fold+1, $y_fold_max)}]
						}
					}
				} elseif {$candidateTileCount==1} {
					#we are done
					break;
				} else {
					#lower max values
					set x_fold_max $x_fold
					set y_fold_max $y_fold
				}
			}
			
			#update tileSubset a final time, since the last increase in min might not be considered, which might leave us with an empty set
			if {[llength $tileSubset]==0} {
				set x_fold $x_fold_min
				set y_fold $y_fold_min
				set tileSubset [filter $tiles "$x_property>=[expr {${target_x}-${x_fold}}] && $x_property<=[expr {${target_x}+${x_fold}}] && $y_property>=[expr {${target_y}-${y_fold}}] && $y_property<=[expr {${target_y}+${y_fold}}]"]
			}
			
			#puts "TILE area $x_fold $y_fold"

			#fine bruteforce search - we now have a frame and need to find the cheapest tile on this frame
#			set iMax  [expr {min(x_fold, y_fold)}]
#			set jMax  [expr {max(x_fold, y_fold)}]
#			
#			for {set i 0} {$i < $iMax} {incr i} {
#				if {$xFirst} {
#					# x axis is cheaper
#					set tileSubset [filter $tiles "$y_property>=[expr {${target_y}-${i}}] && \
#								       $y_property<=[expr {${target_y}+${i}}] && \
#								       ($x_property>=[expr {${target_x}-${x_fold}}] || $x_property<=[expr {${target_x}+${x_fold}}])"]
#				} else {
#					set tileSubset [filter $tiles "$x_property>=[expr {${target_x}-${i}}] && \
#								       $x_property<=[expr {${target_x}+${i}}] && \
#								       ($y_property>=[expr {${target_y}-${y_fold}}] || $y_property<=[expr {${target_y}+${y_fold}}])"]
#				}
#				
#				if {[llength $tileSubset]!=0} {
#					break
#				}
#				
#				for {set j 0} {$j < $jMax} {incr j} {
#					if {$xFirst} {
#						# x axis is cheaper
#						#fixme: fix rounding, complete x expressions
#						set tileSubset [filter $tiles "$y_property>=[expr {${target_y}-${y_fold}}] && \
#									       $y_property<=[expr {${target_y}+${y_fold}}] && \
#									       ($x_property>=[expr {${target_x}-int(double(${i})*${cost_y}/${cost_x})-$j}] || $x_property<=[expr {${target_x}+${x_fold}}])"]
#					} else {
#						#fixme adjust below
#						set tileSubset [filter $tiles "$x_property>=[expr {${target_x}-${i}}] && \
#										$x_property<=[expr {${target_x}+${i}}] && \
#										($y_property>=[expr {${target_y}-${y_fold}}] || $y_property<=[expr {${target_y}+${y_fold}}])"]
#					}
#					
#					if {[llength $tileSubset]!=0} {
#						break
#					}
#				}
#				
#				if {[llength $tileSubset]!=0} {
#					break
#				}
#			}
			
			#placement
#			set tileSubset [filter $tiles "$x_property>=[expr {${target_x}-${x_fold}}] && \
#						       $x_property<=[expr {${target_x}+${x_fold}}] && \
#						       $y_property>=[expr {${target_y}-${y_fold}}] && \
#						       $y_property<=[expr {${target_y}+${y_fold}}])"]]
			
			set tile  [lindex $tileSubset 0]
			set sites [get_sites -of_objects $tile]
			
			#set center [get_tiles -filter $x_property==$target_x&&$y_property==$target_y]
			#mark_objects -color green $center
			#select_objects $tileSubset
			#after [expr {10*1000}]
			#unmark_objects $center
			
			set bel {}
			set otherBelsAvailable false
			
			foreach site $sites {
				set possibleBels [filter $candidateBels NAME=~$site/*]
				
				switch -exact [llength $possibleBels] {
					0 {
						continue;
					}
					1 {
						if {$bel eq {}} {
							set bel [lindex $possibleBels 0]
						} else {
							set otherBelsAvailable true
							break
						}
					}
					default {
						set bel [lindex $possibleBels 0]
						set otherBelsAvailable true
						break;
					}
				}
			}
			
			#puts "candidates pos $tile"
			#puts [join $candidateBels \n]
			
			lappend placements $cell $bel
			
			#update available bels/tiles
			#puts "bel found $bel"
			set candidateBels [filter $candidateBels NAME!=$bel]
			
			if {!$otherBelsAvailable} {
				set tiles [filter $tiles NAME!=$tile]
			}
		}
		
		return $placements
	}
}