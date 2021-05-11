package require math;

##
# Functions for working with rectangles
namespace eval ::ted::rect {
	variable coordinate_property   GRID_POINT                   ;#< Property we use for tile coordinates (generic part, we build the x and y properties from this)
	variable coordinate_property_x ${coordinate_property}_X     ;#< Property we use for tile X coordinates
	variable coordinate_property_y ${coordinate_property}_Y     ;#< Property we use for tile Y coordinates
	
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
			[dict get $container right]  >= [dict get $containee right] \
		}]
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
	#
	proc dropDuplicateSubsets {rects} {
		set compacted [list [lindex $rects 0]]
		
		for {set i 1} {$i < [llength $rects]} {incr i} {
			set appendRect 1
			set rect [lindex $rects $i]
		
			for {set j 0} {$j < [llength $compacted]} {incr j} {
				set compactRect [lindex $compacted $j]
				
				if [contains $compactRect $rect] {
					set appendRect 0
					break
				}
				
				if [contains $rect $compactRect] {
					set compacted [lreplace $compacted $j $j]
				
					#prune the remainder
					for {} {$j < [llength $compacted]} {incr j} {
						set compactRect [lindex $compacted $j]
					
						if [containsRect $rect $compactRect] {
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
	# Extend a rect horizontally up to the tiles with the driving hclk tiles.
	#
	# @param rect       rectangle to extend
	#
	# @return           extended rectangle
	proc extendVerticalToClock {rect} {
		variable coordinate_property_y
		
		set clkTiles [get_tiles -of_objects [get_clock_regions -of_objects [getTiles $rect]] -filter {NAME=~HCLK*}]
		dict set rect top    [::math::max [dict get $rect top   ] [get_property $coordinate_property_y -max $clkTiles]]
		dict set rect bottom [::math::min [dict get $rect bottom] [get_property $coordinate_property_y -min $clkTiles]]
		
		return $rect
	}
	
	##
	# Returns the height of a rect.
	#
	# @param rect           the rect
	#
	# @return               height of the rect
	#
	proc getHeight {rect} {
		return [expr {[dict get $rect top] - [dict get $rect bottom]}]
	}
	
	##
	# Returns the width of a rect.
	#
	# @param rect           the rect
	#
	# @return               width of the rect
	#
	proc getWidth {rect} {
		return [expr {[dict get $rect right] - [dict get $rect left]}]
	}
	
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
	# Computes the bounding box of a list of rects.
	#
	# @param rects              list of rects
	#
	# @return                   minimal bounding rect, containing all rects in the list
	#
	proc boundingBox {rects} {
		set boundingBox [lindex $rects 0]
		
		foreach rect $rects {
			foreach {lowerBound upperBound} {bottom top left right} {
				if { [dict get $rect $lowerBound] < [dict get $boundingBox $lowerBound]} {
					dict set boundingBox $lowerBound [dict get $rect $lowerBound]
				}
				
				if { [dict get $rect $upperBound] > [dict get $boundingBox $upperBound]} {
					dict set boundingBox $upperBound [dict get $rect $upperBound]
				}
			}
		}
		
		return $boundingBox
	}
	
	##
	# Calculates the offset (left, bottom) between two rects.
	#
	# Calculates the offset needed to place the bottom left corner of the source rect ont
	# the bottom left corner of the offset rect
	#
	# @param sourceRect          source rectangle
	# @param offsetRect          relative rectangle
	#
	# @return                    offset (dict with left and bottom) to translate source onto offset
	#
	proc getOffset {sourceRect offsetRect} {
		return [dict create left [expr {[dict get $offsetRect left] - [dict get $sourceRect left]}] bottom [expr {[dict get $offsetRect bottom] - [dict get $sourceRect bottom]}]]
	}
	
	##
	# Gets the rect that is obtained by offesetting the input rect by the input offset.
	#
	# @param rect         starting rect
	# @param offset       offset
	#
	# @return             rect obtained by shifting the input rect by offset
	#
	proc offsetRect {rect offset} {
		set offsetRegion [dict create]
		dict set offsetRegion top    [expr {[dict get $rect top]    + [dict get $offset bottom]}]
		dict set offsetRegion bottom [expr {[dict get $rect bottom] + [dict get $offset bottom]}]
		dict set offsetRegion left   [expr {[dict get $rect left]   + [dict get $offset left]}]
		dict set offsetRegion right  [expr {[dict get $rect right]  + [dict get $offset left]}]
		
		return $offsetRegion
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
	# get the rects bounding a pblock.
	#
	# A pblock can contain different resource types, as each resourcetype has its own rect,
	# a single pblock can return multiple rects, despite being defined as only one rect in
	# Vivado. On top of this, it is legal to define a pblock as multiple rects, resulting
	# in even more rects being returned.
	#
	# @param pblock                 the pblock object/name of the pblock
	#
	# @return                       list of rects bounding the pblock
	#
	proc ofPblock {pblock} {
		variable coordinate_property_x
		variable coordinate_property_y
		
		set rects {}
	
		foreach range [get_property DERIVED_RANGES [get_pblock $pblock]] {
			#again XILINX switched the y axis (in a mathematical sense) but kept the top/right definition
			lassign [split $range :] topLeft bottomRight
			
			set topLeftTile     [get_tiles -of_objects [get_sites $topLeft]]
			set bottomRightTile [get_tiles -of_objects [get_sites $bottomRight]]
			
			lappend rects [                                                                       \
					rectify [ dict create                                                 \
						left   [get_property $coordinate_property_x $topLeftTile]     \
						bottom [get_property $coordinate_property_y $bottomRightTile] \
						top    [get_property $coordinate_property_y $topLeftTile]     \
						right  [get_property $coordinate_property_x $bottomRightTile] \
					] \
				]
		}
		
		return $rects
	}
	
	# Todo: implement a checker that merges pbocks types if applicable:
	# I.e. define two rects for the pblock rects, the specified tile rect, and the next larger tile rect (max values here if the rect goes to the borders i.e. X0 for left,
	# else use the coordinates of the next row/column (tilename_X+1_Y+1)
	# if the larger rect expands past another rect but the other one is smaller or equal we can drop that rect.
	#
	# Pblock grids are SLICE_ DSP48_ RAMB18_ RAMB36_ (see ug912 PBLOCK property)
	#
	proc ofPblockUnified {pblock} {
		foreach range [get_property DERIVED_RANGES $pblock] {
			lassign [split $range :] topLeft bottomRight
			
			
		}
	}
	
	##
	# Returns the rect of an Vivado object.
	#
	# Detects the type X of object and calls the appropriate ofX method to get the rect.
	# The object must support get_property CLASS and its class must be supported.
	#
	# Supported object classes
	#  - clockregion
	#  - pblock
	#  
	# @param object            the object to get the rect of
	#
	# @return                  rect bounding the object
	#
	proc ofObject {object} {
		switch [get_property CLASS $object] {
			clockregion {
				return [ofClockregion $object]
			}
			pblock {
				return []ofPblock $object]
			}
		}
		
		error "The class [get_property CLASS $object] is not supported."
	}
	
	##
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
	# @param rect                 rectangle to get tildes from
	# @param used                 only get sites which have IS_USED equal to this value, set to the empty string {} for dont care. (default {})
	# @param filter               additional filter to apply
	# @param quiet                add quiet, to suppress nothing matches warnings, valid values are {} and -quiet (default {})
	#
	# @return                     list of Vivado tile objects inside the rect
	proc getTiles {rect {used {}} {filter {}} {quiet {}}} {
		if {$filter ne {}} {
			set filter "[filterExpression $rect] && $filter"
		} else {
			set filter [filterExpression $rect]
		}
		
		if {$used eq {}} {
			return [get_tiles -filter $filter {*}$quiet]
		} else {
			return [get_tiles -filter $filter -of_objects [get_sites -filter "IS_USED == $used" {*}$quiet] {*}$quiet]
		}
	}
	
	##
	# Returns the sites contained by the rect.
	#
	# @param rect                 rectangle to get sites from
	# @param used                 only get sites which have IS_USED equal to this value, set to the empty string {} for dont care. (default {})
	# @param filter               specify additional site filters (use the vivado get_sites -filter syntax)
	# @param quiet                add quiet, to suppress nothing matches warnings, valid values are {} and -quiet (default {})
	#
	# @return                     list of Vivado site objects inside the rect
	proc getSites {rect {used {}} {filter {}} {quiet {}}} {
		if {$used eq {}} {
			return [get_sites -of_objects [get_tiles -filter "[filterExpression $rect]" {*}$quiet] -filter $filter {*}$quiet]
		} else {
			if {$filter ne {}} {
				set filter " && ($filter)"
			}
			return [get_sites -of_objects [get_tiles -filter "[filterExpression $rect]" {*}$quiet] -filter "IS_USED == $used $filter" {*}$quiet]
		}
	}
	
	## @internal
	# Helper to get sites in the corners of a rect.
	#
	# Only allows for bottomLeft/topRight sites
	#
	# @param rect           rectangle of which we try to get the extreme sites
	# @param bound          enum: min, max. Get the sites with minimal or maximal RPM_X/Y coordinates
	# @param siteType       only report sites of the specified type
	#
	# @return               Vivado site object in the bottomLeft (bound=min) or topright (bound=max)
	proc _extremeSite {rect bound {siteType {}}} {
		if {$siteType ne {}} {
			set filter "SITE_TYPE =~ $siteType"
		} else {
			set filter {}
		}
		
		set sites [getSites $rect -1 $filter -quiet]
		
		if { ![llength $sites] } {
			return {}
		}
		
		set x [get_property RPM_X $sites -$bound]
		set y [get_property RPM_Y $sites -$bound]
		
		return [get_sites -filter "RPM_X == $x && RPM_Y == $y"]
	}
	
	##
	# Computes the range string for a specific site type in a rect
	#
	# Returns the empty string {} if the sitetype can not be found in the rect
	#
	# @param rect             rect for which to compute the range
	# @param sitetype         site type for which to compute the range
	#
	# @return                 a site range (lowercorener:upercorner)
	proc siteRanges {rect sitetype} {
		set minSite [_extremeSite $rect min $sitetype]
		
		#empty return if the site type is not contained in the rect
		if { $minSite eq {} } {
			return {}
		}
		
		return "[get_property NAME $minSite]:[get_property NAME [_extremeSite $rect max $sitetype]]"
	}
	
	##
	# Create pblock ranges for a rectangle.
	#
	# @param rect             rect to create the ranges for
	# @param sitetypes        list of sitetypes that should be added to the ranges (default {SLICE* DSP48E1 RAMB18E1 RAMB36E1})
	#
	# @return                 list of siteranges (lowercorner:upercorner)
	proc toPblockRanges {rect {sitetypes {SLICE* DSP48E1 RAMB18E1 RAMB36E1}}} {
		#slicel/m =>slice*
		foreach sitetype $sitetypes {
			lappend ranges {*}[siteRanges $rect $sitetype]
		}
		
		return $ranges
	}
	
	##
	# Create a pblock encompassing the rect or add it to the pblock if the pblock already exists.
	#
	# @param rect             the rect to be added to the pblock
	# @param pblock           vivado pblock object, or name of pblock
	#
	# @return                 vivado pblock object that has been created/modified
	proc toPblock {rect pblock} {
		set block [get_pblocks $pblock]
		
		if {$block eq {}} {
			set block [create_pblock $pblock]
		}
		
		resize_pblock $block -add [toPblockRanges $rect]
		return $block
	}
	
}