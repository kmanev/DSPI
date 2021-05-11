namespace eval ::ted::coordinates {
	variable coordinate_property_x $::ted::rect::coordinate_property_x ;#< Property to extract X coordinate
	variable coordinate_property_y $::ted::rect::coordinate_property_y ;#< Property to extract Y coordinate

	##
	# Get a filter to get a object
	#
	# @param x             x coordinate of object
	# @param y             y coordinate of object
	#
	# @return                filter string to use with the vivado get_* -filter X functions
	proc coordinateFilter {x y} {
		return "$::ted::coordinates::coordinate_property_x==$x && $::ted::coordinates::coordinate_property_y==$y"
	}
}