package require struct::list

namespace eval ::ted::rect {
	variable coordinate_property   GRID_POINT                   ;#< Property we use for tile coordinates (generic part, we build the x and y properties from this)
	variable coordinate_property_x ${coordinate_property}_X     ;#< Property we use for tile X coordinates
	variable coordinate_property_y ${coordinate_property}_Y     ;#< Property we use for tile Y coordinates
	
	variable interconnect_coordinate_property   INT_TILE
	variable interconnect_coordinate_property_x ${interconnect_coordinate_property}_X
	variable interconnect_coordinate_property_y ${interconnect_coordinate_property}_Y
	
	##
	# Creates a rect.
	#
	# Shorthand convenience constructor.
	#
	# @param top        top
	# @param right      right
	# @param bottom     bottom
	# @param left       left
	proc rect {top right bottom left} {
		return [dict create    \
			top    $top    \
			right  $right  \
			bottom $bottom \
			left   $left   \
		]
	}
	
	##
	# Ensure that a rect conforms to our assumptions.
	#
	# Ensures that for a rect top>bottom and right>left. Swaps sides in case this is not true.
	# Enforcing this eases a lot of code, i.e. the width calculation becomes a simple subtraction.
	#
	# @param rect           the rect
	#
	# @return               the "rectified" rect (i.e. the same rect, but ensuring that it is specified in a norm conform way)
	#
	proc rectify {rect} {
		if {[dict get $rect left] > [dict get $rect right]} {
			puts "Warning left>right, swapping"
			set left [dict get $rect left]
			dict set rect left  [dict get $rect right]
			dict set rect right $left
		}

		if {[dict get $rect bottom] > [dict get $rect top]} {
			puts "Warning bottom>top, swapping"
			set bottom [dict get $rect bottom]
			dict set rect bottom  [dict get $rect top]
			dict set rect top $bottom
		}
		
		return $rect
	}
	
	##
	# Test if container contains containee.
	#
	# Tests if the rect containee is contained inside container.
	#
	# @param container               supposedly containing rect
	# @param containee               supposedly contained rect
	#
	# @return                        boolean, true if container contains containee
	#
	proc contains {container containee} {
		return [expr {\
			[dict get $container bottom] <= [dict get $containee bottom] && \
			[dict get $container top]    >= [dict get $containee top]    && \
			[dict get $container left]   <= [dict get $containee left]   && \
			[dict get $container right]  >= [dict get $containee right]     \
		}]
	}
	
	##
	# get the rect bounding a clockregion.
	#
	# @param clockregion            the clockregion object
	#
	# @return                       bounding rect of the clockregion
	#
	proc ofClockregion {clockregion} {
		variable coordinate_property_x
		variable coordinate_property_y
		
		#xilinx flipped the coordinate system, but kept the definition of top and bottom
		set tile_top_right [get_tiles [get_property BOTTOM_RIGHT_TILE $clockregion]]
		set tile_bot_left  [get_tiles [get_property TOP_LEFT_TILE     $clockregion]]
		
		return [rectify \
			[dict create \
				left   [get_property $coordinate_property_x $tile_bot_left]  \
				bottom [get_property $coordinate_property_y $tile_bot_left]  \
				top    [get_property $coordinate_property_y $tile_top_right] \
				right  [get_property $coordinate_property_x $tile_top_right] \
			] \
		]
	}
	
	##
	# @internal
	# Return a list of rects, given by the ranges describing the pblock.
	#
	# dropSubsets can be used to remove rects that ar contained by other rects.
	# See ofPblock for a user friendly implementation that does this.
	#
	# @param pblock          pblock object or name, which to turn into rects
	#
	# @return                a list of rects describing the pblock
	proc _ofPblock {pblock} {
		variable coordinate_property_x
		variable coordinate_property_y
		
		set rects {}
	
		foreach range [get_property DERIVED_RANGES [get_pblock $pblock]] {
			#again XILINX switched the y axis (in a mathematical sense) but kept the top/right definition
			lassign [split $range :] topLeft bottomRight
			
			set topLeftTile     [get_tiles -of_objects [get_sites $topLeft]]
			set bottomRightTile [get_tiles -of_objects [get_sites $bottomRight]]
			
			lappend rects [                                                                       \
					::ted::rect::rectify [ dict create                                    \
						left   [get_property $coordinate_property_x $topLeftTile]     \
						bottom [get_property $coordinate_property_y $bottomRightTile] \
						top    [get_property $coordinate_property_y $topLeftTile]     \
						right  [get_property $coordinate_property_x $bottomRightTile] \
					] \
				]
		}
		
		return $rects
	}
	
	##
	# Return a list of rects bounding the pblock rects.
	#
	# A pblock can contain different resource types, as each resourcetype has its own rect,
	# a single pblock can return multiple rects, despite being defined as only one rect in
	# Vivado. On top of this, it is legal to define a pblock as multiple rects, resulting
	# in even more rects being returned.
	#
	# The function adds interconnect tiles, this process might result in unintended hroizontal extension
	# if large tiles (DSP/BRAM/...) cross the border of the pblock.
	#
	# @param pblock          pblock object or name, which to turn into rects
	#
	# @return                a list of rects describing the pblock
	proc ofPblock {pblock} {
		set rects [::struct::list map [::ted::rect::_ofPblock $pblock] ::ted::rect::extendToINTtiles]
		set rects [::ted::rect::dropSubsets $rects]
		return [::ted::rect::combineHorizontalOverlap $rects]
	}
	
	##
	# @deprecated
	# To inaccurate and no general use.
	#
	# Convert a list of tiles to a rect.
	#
	# Returns a rect that spans arround all tiles, the rect might contain more tiles than were in the original selection,
	# if the original selction was not a rectangle (i.e. just selecting two corner tiles can give a rectangle, but all tiles
	# in the implicit two other corners and inbetween will be spanned by the returned rect).
	#
	# @param tiles               list of tile objects
	#
	# @return                    a rect, that contains all tiles in the list
	proc ofTiles {tiles} {
		variable coordinate_property_x
		variable coordinate_property_y
		
		return [rectify \
			[dict create \
				left   [get_property -min $coordinate_property_x $tiles] \
				right  [get_property -max $coordinate_property_x $tiles] \
				bottom [get_property -min $coordinate_property_y $tiles] \
				top    [get_property -max $coordinate_property_y $tiles] \
			] \
		]
	}
	
	##
	# Removes all rects of a list, that are contained by other rects in the list.
	#
	# Removes rects from a list, that would fall inside larger rects already present
	# in the list.
	#
	# @param rects           list of rects to prune
	#
	# @return                pruned list of rects
	proc dropSubsets {rects} {
		set compacted [list [lindex $rects 0]]
		
		for {set i 1} {$i < [llength $rects]} {incr i} {
			set appendRect 1
			set rect [lindex $rects $i]
		
			for {set j 0} {$j < [llength $compacted]} {incr j} {
				set compactRect [lindex $compacted $j]
				
				if [::ted::rect::contains $compactRect $rect] {
					set appendRect 0
					break
				}
				
				if [::ted::rect::contains $rect $compactRect] {
					set compacted [lreplace $compacted $j $j]
				
					#prune the remainder
					for {} {$j < [llength $compacted]} {incr j} {
						if [::ted::rect::contains $rect [lindex $compacted $j]] {
							set compacted [lreplace $compacted $j $j]
						}
					}
					
					break
				}
			}
			
			if {$appendRect} {
				lappend compacted $rect
			}
		}
		
		return $compacted
	}
	
	##
	# Combine horizontal overlap between rects.
	#
	# Combines horizontal overlapping rects in a list of rects.
	#
	# @param rects       list of rects
	#
	# @return            list of rects where horizontal overlap have been combined into single rects
	proc combineHorizontalOverlap {rects} {
		#Sort by top, bottom, left => equal height rects are sorted by their left cornor points
		proc _compareCornorPoints {a b} {
			set topA [dict get $a top]
			set topB [dict get $b top]
			
			set bottomA [dict get $a bottom]
			set bottomB [dict get $b bottom]
			
			set leftA [dict get $a left]
			set leftB [dict get $b left]
			
			#hopefully most common case first
			#fixme: consider bottom before left
			if {$topA==$topB} {
				if {$bottomA==$bottomB} {
					if {$leftA<$leftB} {
						return -1
					} elseif {$leftA>$leftB} {
						return 1
					} else {
						return 0
					}
				} else {
					if {$bottomA<$bottomB} {
						return -1
					} else {
						return 1
					}
				}
			} else {
				if {$topA<$topB} {
					return -1
				} else {
					return 1
				}
			}
		}
		
		set rects [lsort -command ::ted::rect::_compareCornorPoints $rects]
		set currentRect [lindex $rects 0]
		set mergedRects {}
		
		foreach rect [lrange $rects 1 end] {
			if {[dict get $currentRect top]!=[dict get $rect top] || [dict get $currentRect bottom]!=[dict get $rect bottom]} {
				lappend mergedRects $currentRect
				set currentRect $rect
			} else {
				if {[dict get $currentRect right]>=[dict get $rect left]} {
					#overlap or subset rect
					if {[dict get $currentRect right]<[dict get $rect right]} {
						#true overlap
						dict set currentRect right [dict get $rect right]
					}
				} else {
					#gap
					lappend mergedRects $currentRect
					set currentRect $rect
				}
			}
		}
		
		lappend mergedRects $currentRect
		
		return $mergedRects
	}
	
	##
	# Extend a rect to include interconnect tiles.
	#
	# As only the bounding box is extended, this may result in additional tiles to be added to the rect.
	# Such an unintended extension happens if a large tile (e.g. BRAM) sticks out of the rect. The procedure will extend
	# the bounding box to include the large tile, thus also including all tiles in the added rows which fall inside the rect.
	#
	# @param rect              rect to extend
	#
	# @return           rect containing the tiles of the input rect and the corresponding interconnect.
	proc extendToINTtiles {rect} {
		return [ted::rect::ofTiles [ted::selectors::extendToInterconnect [ted::rect::getTiles $rect]]]
		#NOTE: original approach does not work as INT_TILE property is not reliable
		#assumption INT tiles only in y direction
		#variable coordinate_property_x
		#variable coordinate_property_y
		
		#variable interconnect_coordinate_property_x
		
		#set leftInterconnectX  [get_property -min ${interconnect_coordinate_property_x} [get_tiles -filter "${coordinate_property_x}==[dict get $rect left ]&&INT_TILE_X!=-1"]]
		#set rightInterconnectX [get_property -max ${interconnect_coordinate_property_x} [get_tiles -filter "${coordinate_property_x}==[dict get $rect right]&&INT_TILE_X!=-1"]]
		
		#dict set rect left  [get_property -min ${coordinate_property_x} [get_tiles -filter "${interconnect_coordinate_property_x}==${leftInterconnectX}"]]
		#dict set rect right [get_property -max ${coordinate_property_x} [get_tiles -filter "${interconnect_coordinate_property_x}==${rightInterconnectX}"]]
		
		#return $rect
	}
	
	##
	# Returns a filter expression to filter tile objects by
	#
	# @param rect           the rectangle in which tiles should be
	#
	# @return               the filter expression that can be passed to -filter of get_tiles to filter out the tiles inside the rect
	proc filterExpression {rect} {
		variable coordinate_property_x
		variable coordinate_property_y
		
		return "$coordinate_property_x >= [dict get $rect left] && $coordinate_property_x <= [dict get $rect right] && $coordinate_property_y >= [dict get $rect bottom] && $coordinate_property_y <= [dict get $rect top]"
	}
	
	##
	# Returns the tiles contained by the rect.
	#
	# @param rects                rectangle or list of rectangles to get tildes from
	# @param used                 only get sites which have IS_USED equal to this value, set to the empty string {} for dont care. (default {})
	# @param filter               additional filter to apply
	# @param quiet                add quiet, to suppress nothing matches warnings, valid values are {} and -quiet (default {})
	#
	# @return                     list of Vivado tile objects inside the rect
	proc getTiles {rects {used {}} {filter {}} {quiet {}}} {
		#turn a single rect into a list of rects
		if {[dict exists $rects right]} {
			set rects [list $rects]
		}
		
		set tiles {}
		
		foreach rect $rects {
			if {$filter ne {}} {
				set filter "[filterExpression $rect] && $filter"
			} else {
				set filter [filterExpression $rect]
			}
			
			if {$used eq {}} {
				lappend tiles [get_tiles -filter $filter {*}$quiet]
			} else {
				lappend tiles [get_tiles -filter $filter -of_objects [get_sites -filter "IS_USED == $used" {*}$quiet] {*}$quiet]
			}
		}
		
		return $tiles
	}
}