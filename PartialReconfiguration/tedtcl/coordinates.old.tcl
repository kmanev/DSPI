package require struct::list

namespace eval ted::coordinates {
	namespace export             \
		coordinates          \
		relativeFilter       \
		blockRelativeTiles
	
	variable coordinate_property_x $::ted::rect::coordinate_property_x ;#< Property to extract X coordinate
	variable coordinate_property_y $::ted::rect::coordinate_property_y ;#< Property to extract Y coordinate
	
	##
	# get coordinates dict for an object.
	#
	# @param obj                 object with grid coordinates (i.e. tile or site)
	#
	# @return                    dict with coordinates of object
	proc gridCoordinates {obj} {
		variable coordinate_property_x
		variable coordinate_property_y
		
		return [dict create left [get_property $coordinate_property_x $obj] bottom [get_property $coordinate_property_y $obj]]
	}

	##
	# Get a filter to get a object
	#
	# @param x             x coordinate of object
	# @param y             y coordinate of object
	#
	# @return                filter string to use with the vivado get_* -filter X functions
	proc coordinateFilter {x y} {
		return "$::ted::rect::coordinate_property_x == $x && $::ted::rect::coordinate_property_y == $y"
	}
	
	##
	# Get a filter to get a relative object
	#
	# @param obj             vivado object with grid properties
	# @param offset          offset (see ted::rect::getOffset)
	#
	# @return                filter string to use with the vivado get_* -filter X functions
	proc relativeFilter {obj offset} {
		set coords [gridCoordinates $obj]
		set x [expr {[dict get $coords left  ] + [dict get $offset left  ]}]
		set y [expr {[dict get $coords bottom] + [dict get $offset bottom]}]
		return "$::ted::rect::coordinate_property_x == $x && $::ted::rect::coordinate_property_y == $y"
	}
	
	##
	# Get tiles relative to the selected tiles.
	#
	# @param tiles        base tile set
	# @param offset       offset (see ted::rect::getOffset)
	#
	# @return             list of the relative tiles, which are offset by the specified offset from the initial tiles.
	proc getRelativeTiles {tiles offset} {
		set relativeTiles {}
		
		foreach tile $tiles {
			lappend relativeTiles [get_tiles -filter [relativeFilter $tile $offset]]
		}
		
		return $relativeTiles
	}
	
	##
	# Block offset tiles.
	#
	# Blocks tiles shifted by an offset to the input tiles.
	# Can be used to block tiles that are used by the static system in one pblock in other pblocks,
	# to make their footprints compatible.
	#
	# @param tiles                   list of tiles to block
	# @param offset                  offset dict (see ted::rect)
	proc blockRelativeTiles {tiles offset} {
		set_property PROHIBIT 1 [get_sites -of_objects [getRelativeTiles $tiles $offset]]
	}
	
	##
	# Sort objects by their X and Y coordinates
	#
	# Note: consider "lsort -dictionary $objects" for objects with the coordinates in ther names (i.e. 
	proc sortXY {objects} {
		foreach object $objects x [get_property $::ted::rect::coordinate_property_x $objects] y [get_property $::ted::rect::coordinate_property_y $objects] {
			lappend xyAnnotated [list $object $x $y]
		}
		
		return [struct::list mapfor x [lsort -integer -index 1 [lsort -integer -index 2 $xyAnnotated]] {lindex $x 0}]
	}
	
	##
	# Sort objects based on Manhatten distance
	proc sortManhattenDistance {centerX centerY objects} {
		foreach object $objects x [get_property $::ted::rect::coordinate_property_x $objects] y [get_property $::ted::rect::coordinate_property_y $objects] {
			lappend distanceAnnotated [list $object [expr {abs($x-$centerX)+abs($y-$centerY)}]]
		}
		
		return [struct::list mapfor x [lsort -integer -index 1 $distanceAnnotated] {lindex $x 0}]
	}
}