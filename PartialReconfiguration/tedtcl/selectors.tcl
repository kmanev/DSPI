namespace eval ::ted::selectors {
	#fixme: in ULTRASCALE get_tiles -of INTERCONNECT TILE returns SOME of the attached logic tiles: => addInterconnect is broken (i.e. extends the selection to far)
	##
	# Extend the selection to include interconnect for the contained logic.
	#
	# Also adds logical tiles (null tiles).
	#
	# @param tiles       tile selection to extend
	#
	# @return            previously selected tiles and corresponding interconnect/logic
	proc addInterconnect {tiles} {
		# 1. add tiles related to tile, if $tiles is a NULL Tile ONLY the logical connected tile will be returned
		# 2. (re)add NULL tiles and interconnect if only a NULL tile of a tile cluster (logic, interconnect, nulltiles) was supplied
		return [get_tiles -of_objects [get_tiles -of_objects $tiles]]
	}
	
	##
	# Add NULL tiles to selection.
	#
	# Adds Nulltiles to selection, so that the selection has all logical tiles for the
	# square grid.
	#
	# @param tiles       tile selection to extend
	#
	# @return            extended tileset including logical 1x1 tiles (NULL tiles)
	proc addLogicalTiles {tiles} {
		#allow list of tile names
		set tiles [get_tiles $tiles]
		
		#Note that the result of get_tiles is NOT unpacked with {*}, a Vivado quirk
		return [lappend tiles [get_tiles -of_objects $tiles -filter {TILE_TYPE==NULL} -quiet]]
	}
	
	##
	# Add physical tiles to a seleciton.
	#
	# Add the physical tiles belonging to null tiles to the selection.
	#
	# @param tiles       tile selection to extend
	#
	# @return            extended tileset including physical tiles for null tiles (i.e. BRAM/DSP)
	#
	proc addPhysicalTiles {tiles} {
		#allow list of tile names
		set tiles [get_tiles $tiles]
		
		#Note that the result of get_tiles is NOT unpacked with {*}, a Vivado quirk
		return [lappend tiles [get_tiles -of_objects [filter $tiles {TILE_TYPE==NULL} -quiet]]]
	}
	
	##
	# Return the leaf pin (cell pin) driving a net.
	#
	# This gets the pin driving a net across hierarchy boundaries.
	#
	# @param net             net (takes net objects, or the name of a net as a string)
	#
	# @return                Vivado pin object driving the net
	proc getDriver {net} {
		#run get_nets to ensure that we have all segments of the net
		return [get_pins -of_objects [get_nets -segments $net] -filter {IS_LEAF && DIRECTION == {OUT}}]
	}
	
	##
	# Return the load pins (cell pins) driven by net.
	#
	# This gets the pins loading a net across hierarchy boundaries.
	#
	# @param net             net (takes net objects, or the name of a net as a string)
	#
	# @return                list of Vivado pin objects driven by the net
	proc getLoads {net} {
		#run get_nets to ensure that we have all segments of the net
		return [get_pins -of_objects [get_nets -segments $net] -filter {IS_LEAF && DIRECTION == {IN}}]
	}
	
	ted::DEBUG::enableDebug ted::selectors::_tileScorer 1 hideUnselected
	#ted::DEBUG::enableDebug ted::selectors::_tileScorer
	
	##
	# @internal Create a tile score matrix.
	#
	# Computes a score for tiles, by giving 10 points for each tile that is selected,
	# and 1 point to every surrounding tile.
	# Scorematrix is used for selection modifying functions (selectOutline/extendSelection)
	#
	# Assumes that tile grid min in X and Y is 0.
	#
	# Due to the Xilinx grid system the includeChipBorder option seems to have no effect.
	# The border tiles seem to have larger neighbours, thus getting less points. Even with the
	# additional points from the border, they are not considered fully surrounded, and therefore
	# they remain selected.
	#
	# @param tiles                  select tiles
	# @param includeChipBorder      boolean. assume that the chip is surrounded by selected cells (default false)
	#
	# @return            scorematrix
	proc _tileScorer {tiles {includeChipBorder false}} {
		variable coordinate_property_x $::ted::rect::coordinate_property_x ;#< Property to extract X coordinate
		variable coordinate_property_y $::ted::rect::coordinate_property_y ;#< Property to extract Y coordinate
		
		proc _incrementScore {row column} {
			upvar 1 tileScoreMatrix tileScoreMatrix
			
			lset tileScoreMatrix $row $column [expr {[lindex $tileScoreMatrix $row $column]+1}]
		}
		
		proc _distributeScore {row column} {
			upvar 1 tileScoreMatrix tileScoreMatrix
			
			if {$row > 0} {
				if {$column > 0} {
					_incrementScore [expr {$row-1}] [expr {$column-1}]
				}
				
				_incrementScore [expr {$row-1}] $column
				_incrementScore [expr {$row-1}] [expr {$column+1}]
			}
			
			if {$column > 0} {
				_incrementScore $row [expr {$column-1}]
			}
							
			lset tileScoreMatrix $row $column            [expr {[lindex $tileScoreMatrix $row $column]+10}]
			_incrementScore $row [expr {$column+1}]
			
			if {$column > 0} {
				_incrementScore [expr {$row+1}] [expr {$column-1}]
			}
							
			_incrementScore [expr {$row+1}] $column
			_incrementScore [expr {$row+1}] [expr {$column+1}]
		}
		
		set boundingBox [ted::rect::ofTiles $tiles]

		set columns [dict get $boundingBox right]
		set rows    [dict get $boundingBox top]
		
		set tileScoreMatrix [lrepeat [expr {$rows+2}] [lrepeat [expr {$columns + 2}] 0]] ;# +2 (additional column, plus offset of 1
		
		if {$includeChipBorder} {
			set chipDimensions [ted::rect::ofTiles [get_tiles]]

			#edges
			if {[dict get $boundingBox bottom] == [dict get $chipDimensions bottom]} {
				lset tileScoreMatrix [dict get $chipDimensions bottom] [lrepeat [expr {$columns + 2}] 3]
			}
			
			if {[dict get $boundingBox top] == [dict get $chipDimensions top]} {
				lset tileScoreMatrix [dict get $chipDimensions top] [lrepeat [expr {$columns + 2}] 3]
			}

			if {[dict get $boundingBox left] == [dict get $chipDimensions left]} {
				for {set row [dict get $boundingBox bottom]} {$row<=$rows} {incr row} {
					lset tileScoreMatrix $row [dict get $chipDimensions left] 3
				}
			}
			
			if {[dict get $boundingBox right] == [dict get $chipDimensions right]} {
				for {set row [dict get $boundingBox bottom]} {$row<=$rows} {incr row} {
					lset tileScoreMatrix $row [dict get $chipDimensions right] 3
				}
			}

			#corners
			foreach {vertical horizontal} {bottom left bottom right top left top right} {
				if {[dict get $boundingBox $vertical] == [dict get $chipDimensions $vertical] && [dict get $boundingBox $horizontal] == [dict get $chipDimensions $horizontal]} {
					lset tileScoreMatrix [dict get $chipDimensions $vertical] [dict get $chipDimensions $horizontal] 5
				}
			}
		}
		# Every tile gets 1 point for every neighbouring tile that belongs to the selection. It also gets 10 points for being part of the selection
		foreach row [get_property $coordinate_property_y $tiles] column [get_property $coordinate_property_x $tiles] {
			_distributeScore $row $column
		}
		
		if {[ted::DEBUG::debugEnabled]} {
			set startColumn [dict get $boundingBox left]
			
			if {[ted::DEBUG::debugEnabled hideUnselected]} {
				proc _render {value} {
					if {$value>9 && $value<18} {
						return [format "%2d" $value]
					} else {
						return {  }
					}
				}
			} else {
				proc _render {value} {
					return [format "%2d" $value]
				}
			}
			
			puts "scoreboard:"
			
			#since the scoreboard extends 1row/column past each side of the chip this is fine...
			for {set row [expr {[dict get $boundingBox bottom]-1}]} {$row <= [expr {$rows+1}]} {incr row} {
				puts [join [struct::list map [lrange [lindex $tileScoreMatrix $row] [expr {$startColumn-1}] [expr {$columns+2}]] _render] { }]
			}
		}

		return $tileScoreMatrix
	}
	
	##
	# Select the border tiles of a set of tiles.
	#
	# A border tile is any tile that is not surrounded by 8 tiles that are selected as well.
	#
	# Assumes that tile grid min in X and Y is 0.
	#
	# Due to the Xilinx grid system the includeChipBorder option seems to have no effect.
	# The border tiles seem to have larger neighbours, thus getting less points. Even with the
	# additional points from the border, they are not considered fully surrounded, and therefore
	# they remain selected.
	#
	# @param tiles                  the select tiles for which to find the border
	# @param includeChipBorder      boolean. assume that the chip is surrounded by selected cells (default false)
	# @param physicalTiles          boolean. Adds physical tiles to selection, necessary since NULL tiles have no wires crossing them and do not show up in the gui (default true)
	#
	# @return list of tiles that are on the border of the selection
	proc selectOutline {tiles {includeChipBorder false} {physicalTiles true}} {
		variable coordinate_property_x $::ted::rect::coordinate_property_x ;#< Property to extract X coordinate
		variable coordinate_property_y $::ted::rect::coordinate_property_y ;#< Property to extract Y coordinate
		
		set tiles [ted::selectors::addLogicalTiles $tiles]
		
		set tileScoreMatrix [_tileScorer $tiles $includeChipBorder]
		
		set boundingBox [ted::rect::ofTiles $tiles]
		
		set columns [dict get $boundingBox right]
		set rows    [dict get $boundingBox top]
		
		set tileFilter {}
		
		for {set row [dict get $boundingBox bottom]} {$row<=$rows} {incr row} {
			for {set column [dict get $boundingBox left]} {$column<=$columns} {incr column} {
				set score [lindex $tileScoreMatrix $row $column]
				
				#add all tiles that where in the original set (they get 10 points), that do not have 8 neighbours
				if {$score > 9 && $score < 18} {
					lappend tileFilter [::ted::coordinates::coordinateFilter $column $row]
				}
			}
		}
		
		if {$physicalTiles} {
			#adding physical tiles, so that flyover wires, etc are correctly detected.
			return [ted::selectors::addPhysicalTiles [filter $tiles ([join $tileFilter {)||(}])]]
		} else {
			return [filter $tiles ([join $tileFilter {)||(}])]
		}
			# very hacky way to combine specialTiles and the result of  [filter ...] into one collection of tiles, and return this
			
			#the syntax here is suspicious, thanks to Xilinx, it seems to be, that specialTiles is a <collection> of tile collections with one tile each
			#this means we can't append it to a list of tiles, AND that the usual "lappend varname Vivado-collection" does not work
			#to get this to work we apparently need to unpack the collection, which we seemingly can do using the $ infront of the list
			#return [lappend $specialTiles [filter $tiles ([join $tileFilter {)||(}])]]
	}
	
	##
	# Returns a one tile wide border framing the selected tiles.
	#
	# In contrast to selectOutline, which returns thos tiles *OF THE SELECTED* tiles,
	# this returns the tiles *ARROUND* the selected tiles (i.e. tiles that were not previously selected)
	#
	# @param tiles              tiles for which to compute the border.
	# @param physicalTiles      boolean. Adds physical tiles to selection, necessary since NULL tiles have no wires crossing them and do not show up in the gui (default true)
	#
	# @return                   tiles framing the selected tiles
	# fixme: should there be an option to keep tiles on the chip border? (they have no neighbours)
	proc extendSelection {tiles {physicalTiles true}} {
		variable coordinate_property_x $::ted::rect::coordinate_property_x ;#< Property to extract X coordinate
		variable coordinate_property_y $::ted::rect::coordinate_property_y ;#< Property to extract Y coordinate
		
		set tiles [ted::selectors::addLogicalTiles $tiles]
		
		set tileScoreMatrix [_tileScorer $tiles 0]
		
		set boundingBox [ted::rect::ofTiles $tiles]
		
		set columns [dict get $boundingBox right]
		set rows    [dict get $boundingBox top]
		
		set tileFilter {}
		
		for {set row [expr {[dict get $boundingBox bottom]-1}]} {$row<=[expr {$rows+1}]} {incr row} {
			for {set column [expr {[dict get $boundingBox left]-1}]} {$column<=[expr {$columns+1}]} {incr column} {
				set score [lindex $tileScoreMatrix $row $column]
				
				#add all tiles that where in the original set (they get 10 points), that do not have 8 neighbours
				if {$score > 0 && $score < 10} {
					lappend tileFilter [::ted::coordinates::coordinateFilter $column $row]
				}
			}
		}
		
		if {[llength $tileFilter]} {
			#in case you are wondering this monster was (significantly) faster than [get_tiles -filter ([join $tileFilter {)||(}])]]
			set outline [filter [get_tiles -filter "$coordinate_property_x>=[expr {[dict get $boundingBox left]-1}] && $coordinate_property_x<=[expr {[dict get $boundingBox right]+1}]&&$coordinate_property_y>=[expr {[dict get $boundingBox bottom]-1}] && $coordinate_property_y<=[expr {[dict get $boundingBox top]+1}]"] ([join $tileFilter {)||(}])]
			
			if {$physicalTiles} {
				return [ted::selectors::addPhysicalTiles $outline]
			} else {
				return $outline
			}
		} else {
			#we have an empty result
			return {}
		}
	}
}