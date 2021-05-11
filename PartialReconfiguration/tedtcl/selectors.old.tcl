package require struct::list

##
# Selectors to ease selecting group of objects from tcl easier
namespace eval ::ted::selectors {
	namespace export             \
		bufhce               \
		clockRegionFilter    \
		clockRegions         \
		clockRegionsY        \
		clockRegionsOfPblock \
		cellsOfModule        \
		tilesOfCells         \
		getLeafCells         \
		getDriver            \
		getNetsOfCell        \
		getFreeLut           \
		getFreeFlop          
	
	##
	# Obtain bufhce sites tor drive bufh nets in certain clock regions
	#
	# @param hnets           the indices of the hnets to use
	# @param clockregions    clockregion objects, of which to return bufhs, defaults to {}, meaning all clock regions (default {})
	#
	# @return                list of bufhce Vivado site objects
	#
	proc bufhce {hnets {clockregions {}}} {
		if {$hnets == {}} {
			return {}
		}
		
		if {$clockregions eq {}} {
			set clockregions [get_clock_regions]
		}
		
		#left and right side
		foreach index $hnets {
			lappend filter "(NAME =~ \"*L$index\") || (NAME =~ \"*R$index\")"
		}
		
		set filter [join $filter " || "]
		set bufhs {}
		
		foreach site [get_sites -filter { SITE_TYPE == BUFHCE } -of_objects $clockregions] {
			if {[llength [get_pips -quiet -of_objects $site -filter $filter]]} {
				lappend bufhs $site
			}
		}
		
		return $bufhs
	}
	
	##
	# Obtain a filter for clockregions specified by their x and y coordinates in a list.
	#
	# The list format is [list x1 y1 x2 y2 ...], you always have to specify x and y of each clock region.
	#
	# @param regionList               a list of X and Y coordinate pairs for the clock regions
	# @param property                 property to filter by
	#
	# @return                         a list of matching Vivado clockregion objects
	#
	proc clockRegionFilterForList {regionList {property CLOCK_REGION}} {
		set regionFilter {}
		
		foreach {x y} $regionList {
			lappend regionFilter "${property} =~ X${x}Y${y}"
		}
		
		return "([join $regionFilter { || }])"
	}
	
	##
	# Obtain a filter for clockregions.
	#
	# @param regions                  a list of clock regions
	# @param property                 property to filter by
	#
	# @return                         a list of matching Vivado clockregion objects
	proc clockRegionFilter {regions {property CLOCK_REGION}} {
		return [clockRegionFilterForList [clockRegionsToList $regions] $property]
	}
	
	##
	# Convert a list of clockregion objects to a clock region coordinate list.
	#
	# @param regions      list of clock region objects
	#
	# @return             list of the clock region objects coordinates [x_0 y_0 x_1 y_1 ...]
	proc clockRegionsToList {regions} {
		set regionList {}

		foreach region $regions {
			lappend regionList [get_property COLUMN_INDEX $region] [get_property ROW_INDEX $region]
		}
		
		return $regionList
	}
	
	##
	# Obtain clockregions selected by a list of x y coordinate pairs.
	#
	# The list format is [list x1 y1 x2 y2 ...], you always have to specify x and y of each clock region.
	#
	# @param regionList               a list of X and Y coordinate pairs for the clock regions
	#
	# @return                         a list of matching Vivado clockregion objects
	proc clockRegions {regionList} {
		if {$regionList == {}} {
			return {}
		}
		
		return [get_clock_regions -filter "[clockRegionFilterForList $regionList NAME]"]
	}
	
	##
	# Obtain clockregions selected by a list of y coordinates
	#
	# @param y               list of y coordinates to select clockregions by
	#
	# @return                a list of matching Vivado clockregion objects
	proc clockRegionsY {y} {
		if {y == {}} {
			return {}
		}

		foreach yIndex $y {
			lappend regionList "*" $yIndex
		}
		
		return [clockRegions $regionList]
	}
	
	##
	# Obtain the clock regions of a pblock
	#
	# @param pblock             pblock (or blocks, or block names)
	#
	# @return                   list of clock regions spanned by the pblock(s)
	proc clockRegionsOfPblock {pblock} {
		return [get_clock_regions -of_objects [get_sites -of_objects [get_pblocks $pblock]]]
	}
	
	##
	# Obtain the tiles of a pblock
	#
	# @param pblock             pblock (or blocks, or block names)
	#
	# @return                   list of tiles spanned by the pblock(s)
	proc tilesOfPblock {pblock} {
		return [get_tiles -of_objects [get_sites -of_objects [get_pblocks $pblock]]]
	}
	
	##
	# Obtain all cells belonging to instances of a module.
	#
	# If the module is a generic vivado appends __parametizedX for every instance with a 
	# different parameterization than the first.
	#
	# @param moduleName                name of the module
	# @param includeParameterizations  flag to include the parameterizations of the cell (default true)
	#
	# @return                          vivado cell list of the modules cells
	proc cellsOfModule {moduleName {includeParameterizations true}} {
		if {$includeParameterizations} {
			set filterExpression "REF_NAME == ${moduleName} || REF_NAME =~ \"${moduleName}__parameterized*\""
		} else {
			set filterExpression "REF_NAME == ${moduleName}"
		}
		
		return [get_cells -hierarchical -filter $filterExpression]
	}
	
	##
	# Returns the tiles used by cells
	#
	# @param cells           vivado cell list
	#
	# @return                vivado tile list of tiles used by the supplied cells
	proc tilesOfCells {cells} {
		return [get_tiles -of_objects [get_sites -of_objects $cells]]
	}
	
	##
	# Get the leaf cells of a cell
	#
	# @param cells          lsit of cells for which to get leafs
	#
	# @return              the leafcells of cell
	proc getLeafCells {cells} {
		set originalTop [current_instance -quiet .]
		
		foreach cell $cells {
			current_instance -quiet
			current_instance $cell
		
			lappend leafs [get_cells -hierarchical -filter {IS_PRIMITIVE && REF_NAME != {VCC} && REF_NAME != {GND}}]
		}
		
		current_instance -quiet
		current_instance $originalTop
		
		return $leafs
	}
	
	##
	# Return all (primitive) cells that are not placed.
	#
	# Note: this excludes GND and VCC as these are generally unplaced.
	# Cells not fixed or placed are considered unplaced. As of this writing there are for defined Status states:
	# PLACED, FIXED, UNPLACED, ASSIGNED
	# As the definition of ASSIGNED is unclear, this is considered as UNPLACED as well.
	#
	# @return             list of unplaced cells
	proc getUnplacedCells {} {
		return [get_cells -filter {IS_PRIMITIVE && (STATUS!=FIXED && STATUS!=PLACED) && (REF_NAME!=GND && REF_NAME!=VCC)} -hierarchical]]
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
	
	##
	# Get the nets of a cell/cells.
	#
	# @param cells            cells of which the nets a gathered
	#
	# @return                 list of nets belonging to the cell(s)
	#fixme documentation on vivados way of joining collections should be in a central place
	proc getNetsOfCell {cells} {
		set originalTop [current_instance -quiet .]
		
		#the following causes vivado do the wrong thing and returns a list of the collections of objects, to prevent this dont set this
		#set nets {}
		
		foreach cell $cells {
			current_instance -quiet
			current_instance $cell
		
			#idealy this would work, however tcl attempts to convert the list to a list of strings this way, so it breaks:
			#lappend nets {*}[get_nets -hierarchical -segments]
			#best way to join lists in tcl 8.6 (https://stackoverflow.com/a/17636938/258418), does fail because of a collection to list of string conversion
			#as well
			#set nets [list {*}$nets {*}[get_nets -hierarchical -segments]]
			
			#slow append
			#foreach net [get_nets -hierarchical -segments] {
			#	lappend nets $net
			#}
			
			#vivado collections do the right thing without expansion
			lappend nets [get_nets -hierarchical -segments]
		}
		
		current_instance -quiet
		current_instance $originalTop
		
		return $nets
	}
	
	##
	# Get a free lut site inside a clock region.
	#
	# Check is complicated to ensure that the LUT5 is actually free (it might be free, but the LUT6 on top of it is used).
	# Currently the PROHIBIT is NOT checked on the LUT6
	#
	# @param clockRegion     clockRegion to check
	# @param pblock          pblock
	#
	# @return                bel of a LUT5 that is free
	proc getFreeLut {{clockRegion {}} {pblock {}}} {
		#todo: should we remember where we started filling a slice and keep going back to it if possible?
		if {$clockRegion != {}} {
			set clockFilter " && ([clockRegionFilter $clockRegion])"
		} else {
			set clockFilter {}
		}
		
		#try for a completly empty site
		if {$pblock == {}} {
			set sites [get_sites -filter "SITE_TYPE=~SLICE* && !IS_USED && !PROHIBIT ${clockFilter}"]
		} else {
			set sites [get_sites -of_objects [get_pblocks ${pblock}] -filter "SITE_TYPE=~SLICE* && !IS_USED && !PROHIBIT ${clockFilter}"]
		}
		
		if {[llength $sites]} {
			return [lindex [get_bels -of_objects [lindex $sites 0] -filter "TYPE==LUT5 && !IS_USED"] 0]
		}
		
		#find all sites where LUT5 && LUT6 are free at the same time
		#get_sites -of_objects [get_bels -of_objects [get_sites -of_objects [get_pblocks pblock_module_0] -filter "SITE_TYPE=~SLICE* && CLOCK_REGION==${clockRegion}"] -filter {TYPE==LUT5 && IS_USED==0}]
		if {$pblock == {}} {
			set lut5s [get_bels -of_objects [get_sites -filter "SITE_TYPE=~SLICE* ${clockFilter}"] -filter {TYPE==LUT5 && IS_USED==0}]
		} else {
			set lut5s [get_bels -of_objects [get_sites -of_objects [get_pblocks ${pblock}] -filter "SITE_TYPE=~SLICE* ${clockFilter}"] -filter {TYPE==LUT5 && IS_USED==0}]
		}
		
		set lut6s {}
		foreach lut5 $lut5s {
			regsub {([A-Z])5LUT} $lut5 "\\16LUT" lut6
			lappend lut6s $lut6
		}
		
		#optimization: what is better:
		# get_bels $lut6s
		# get_bels -of_objects [get_sites $belSites] *6LUT
		set l6usage [get_property IS_USED [get_bels $lut6s]]
		
		for {set i 0} {$i < llength $l6usage} {incr i} {
			if {![lindex $l6usage $i]} {
				return [lindex $lut5s $i]
			}
		}
		
		#no lut found
		return {}
	}
	
	##
	# Get a free Flop site inside a clock region.
	#
	# Checks if the site IS_USED or PROHIBT'ed.
	#
	# @param clockRegion     clockRegion to check
	# @param pblock          pblock
	#
	# @return                bel of a flop that is free
	#fixme should this atleast reuse getFreeFlopOfSites?
	proc getFreeFlop {{clockRegion {}} {pblock {}}} {
		if {$pblock != {} } {
			set pblock [get_pblocks ${pblock}]
		}
		
		if {$clockRegion != {}} {
			set clockFilter " && ([clockRegionFilter $clockRegion])"
		} else {
			set clockFilter {}
		}
		
		#try for a completly empty site (we want to avoid routing issues)
		if {$pblock == {}} {
			set sites [get_sites                       -filter "SITE_TYPE=~SLICE* && !IS_USED && !PROHIBIT ${clockFilter}"]
		} else {
			set sites [get_sites -of_objects ${pblock} -filter "SITE_TYPE=~SLICE* && !IS_USED && !PROHIBIT ${clockFilter}"]
		}
		
		if {[llength $sites]} {
			return [lindex [get_bels -of_objects [lindex $sites 0] -filter "(TYPE == FF_INIT || TYPE ==REG_INIT) && !IS_USED"] 0]
		}
		
		#for the momemnt just hope that we can route to it:
		#todo: should we get a free FF behind a free LUT ?
		if {$pblock == {}} {
			return [lindex [get_bels                                               -filter "(TYPE == FF_INIT || TYPE ==REG_INIT) && !IS_USED ${clockFilter}"] 0]
		} else {
			return [lindex [get_bels -of_objects [get_sites -of_objects ${pblock}] -filter "(TYPE == FF_INIT || TYPE ==REG_INIT) && !IS_USED ${clockFilter}"] 0]
		}
	}
	
	##
	# Find a free flop in the spcified tiles.
	#
	# @param tiles         list of tiles to search for a free BEL
	#
	# @return              bel of a flop that is free
	proc getFreeFlopOfTiles {tiles} {
		return [getFreeFlopOfSites [get_sites -of_objects $tiles]]
	}
	
	##
	# Find a free flop in the spcified sites.
	#
	# @param sites         list of sites to search for a free BEL
	#
	# @return              bel of a flop that is free
	proc getFreeFlopOfSites {sites} {
		#try for a completly empty site (we want to avoid routing issues)
		set freeSites [filter $sites "SITE_TYPE=~SLICE* && !IS_USED && !PROHIBIT"]
		
		if {[llength $freeSites]} {
			return [lindex [get_bels -of_objects [lindex $freeSites 0] -filter "(TYPE == FF_INIT || TYPE ==REG_INIT) && !IS_USED"] 0]
		}

		#for the momemnt just hope that we can route to it:
		#todo: should we get a free FF behind a free LUT ?
		#or get the nets of the input/output pin and check that the result is empty, issue: if the lut before is taken we cant route to the pin..., maybe find a route to any of the tile pins and check that a reachable tile pin is free (no net)?
		return [lindex [get_bels -of_objects $sites -filter "(TYPE == FF_INIT || TYPE ==REG_INIT) && !IS_USED"] 0]
	}
	
	ted::DEBUG::enableDebug ted::selectors::_tileScorer 1 hideUnselected
	
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
	# The process is troubled by the irregular sized tiles, a fix is in Place for BRAM and DSP tiles,
	# however other tiles still remain troublesome, especially since it is hard to determine a tiles actual size.
	# While there are Null Tiles in the rows/columns covered by tile we are not sure where the tile stops, or if 
	# there can be cases where there are additional nulltiles after the end of the tile adjacent to the tile.
	#
	# @param tiles                  select tiles
	# @param includeChipBorder      boolean. assume that the chip is surrounded by selected cells (default false)
	#
	# @return            scorematrix
	proc _tileScorer {tiles {includeChipBorder false}} {
		variable coordinate_property_x $::ted::rect::coordinate_property_x ;#< Property to extract X coordinate
		variable coordinate_property_y $::ted::rect::coordinate_property_y ;#< Property to extract Y coordinate
		
		proc incrementScore {row column} {
			upvar 1 tileScoreMatrix tileScoreMatrix
			
			lset tileScoreMatrix $row $column [expr {[lindex $tileScoreMatrix $row $column]+1}]
		}
		
		proc distributeScore {row column} {
			upvar 1 tileScoreMatrix tileScoreMatrix
			
			if {$row > 0} {
				if {$column > 0} {
					incrementScore [expr {$row-1}] [expr {$column-1}]
				}
				
				incrementScore [expr {$row-1}] $column
				incrementScore [expr {$row-1}] [expr {$column+1}]
			}
			
			if {$column > 0} {
				incrementScore $row [expr {$column-1}]
			}
							
			lset tileScoreMatrix $row $column            [expr {[lindex $tileScoreMatrix $row $column]+10}]
			incrementScore $row [expr {$column+1}]
			
			if {$column > 0} {
				incrementScore [expr {$row+1}] [expr {$column-1}]
			}
							
			incrementScore [expr {$row+1}] $column
			incrementScore [expr {$row+1}] [expr {$column+1}]
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
			distributeScore $row $column
		}
		
		#Fix score for BRAMs/DSPs
		
		#DSP/BRAM Tiles extend 5 Tiles upwards from their original location
		set tileHeight -5
		set increment  [expr {$tileHeight>0?1:-1}]
		set comparator [expr {$tileHeight>0?{<}:{>}}]

		foreach largeTile [filter $tiles -regexp {TYPE=~BRAM_[LR]* || TYPE=~DSP_[LR]*}] {
			set x [get_property ${coordinate_property_x} $largeTile]
			set y [get_property ${coordinate_property_y} $largeTile]
			
			set limit [expr {$y+$tileHeight}]
			
			#dirty harry's for loop
			for {set i [expr {$y+$increment}]} "\$i $comparator \$limit" {incr i $increment} {
				#Since vivado sometimes gives us the null tiles, the score might already be applied,
				#therefore we have to check
				if {[lindex $tileScoreMatrix $i $x] < 10} {
					distributeScore $i $x
				}
			}
		}
		
		if {[ted::DEBUG::debugEnabled]} {
			set startColumn [dict get $boundingBox left]
			
			if {[ted::DEBUG::debugEnabled hideUnselected]} {
				proc render {value} {
					if {$value>9 && $value<18} {
						return [format "%2d" $value]
					} else {
						return {  }
					}
				}
			} else {
				proc render {value} {
					return [format "%2d" $value]
				}
			}
			
			puts "scoreboard:"
			
			#since the scoreboard extends 1row/column past each side of the chip this is fine...
			for {set row [expr {[dict get $boundingBox bottom]-1}]} {$row <= [expr {$rows+1}]} {incr row} {
				puts [join [struct::list map [lrange [lindex $tileScoreMatrix $row] [expr {$startColumn-1}] [expr {$columns+2}]] render] { }]
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
	# The process is troubled by the irregular sized tiles, a fix is in Place for BRAM and DSP tiles,
	# however other tiles still remain troublesome, especially since it is hard to determine a tiles actual size.
	# While there are Null Tiles in the rows/columns covered by tile we are not sure where the tile stops, or if 
	# there can be cases where there are additional nulltiles after the end of the tile adjacent to the tile.
	#
	# @param tiles                  the select tiles for which to find the border
	# @param includeChipBorder      boolean. assume that the chip is surrounded by selected cells (default false)
	#
	# @return list of tiles that are on the border of the selection
	proc selectOutline {tiles {includeChipBorder false}} {
		variable coordinate_property_x $::ted::rect::coordinate_property_x ;#< Property to extract X coordinate
		variable coordinate_property_y $::ted::rect::coordinate_property_y ;#< Property to extract Y coordinate
		
		#DSP/BRAM Tiles extend 5 Tiles upwards from their original location
		#fixme: magic constants
		#fixme: constants in multiple places.
		set tileHeight -5
		set increment  [expr {$tileHeight>0?1:-1}]
		set comparator [expr {$tileHeight>0?{<}:{>}}]
		
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
			
		#Add DSP/BRAM Tiles to selection where needed
		set specialTiles {}
		
		foreach largeTile [filter $tiles -regexp {TYPE=~BRAM_[LR]* || TYPE=~DSP_[LR]*}] {
			set x [get_property ${coordinate_property_x} $largeTile]
			set y [get_property ${coordinate_property_y} $largeTile]
			
			set limit [expr {$y+$tileHeight}]
			
			#dirty harry's for loop
			for {set i [expr {$y+$increment}]} "\$i $comparator \$limit" {incr i $increment} {
				set score [lindex $tileScoreMatrix $i $x]
				
				if {$score > 9 && $score < 18} {
					lappend specialTiles $largeTile
				}
			}
		}
	
		if {[llength $tileFilter] == 0} {
			#fixme: do we need to unpack special tiles? (we get a list of collections with single tiles which causes problems below...)
			return $specialTiles
		} else {
			# very hacky way to combine specialTiles and the result of  [filter ...] into one collection of tiles, and return this
			
			#the syntax here is suspicious, thanks to Xilinx, it seems to be, that specialTiles is a <collection> of tile collections with one tile each
			#this means we can't append it to a list of tiles, AND that the usual "lappend varname Vivado-collection" does not work
			#to get this to work we apparently need to unpack the collection, which we seemingly can do using the $ infront of the list
			return [lappend $specialTiles [filter $tiles ([join $tileFilter {)||(}])]]
		}
	}
	
	##
	# Returns a one tile wide border framing the selected tiles.
	#
	# In contrast to selectOutline, which returns thos tiles *OF THE SELECTED* tiles,
	# this returns the tiles *ARROUND* the selected tiles (i.e. tiles that were not previously selected)
	#
	# @param tiles              tiles for which to compute the border.
	#
	# @return                   tiles framing the selected tiles
	# fixme: should there be an option to keep tiles on the chip border? (they have no neighbours)
	proc extendSelection {tiles} {
		variable coordinate_property_x $::ted::rect::coordinate_property_x ;#< Property to extract X coordinate
		variable coordinate_property_y $::ted::rect::coordinate_property_y ;#< Property to extract Y coordinate
		
		#DSP/BRAM Tiles extend 5 Tiles upwards from their original location
		#fixme: magic constants
		#fixme: constants in multiple places.
		set tileHeight -5
		set increment  [expr {$tileHeight>0?1:-1}]
		set comparator [expr {$tileHeight>0?{<}:{>}}]
		
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
			#while this construction looks perverted, the filter alone drops the vivado collection, which forbids us to join our result with the special tiles in the return statement.
			#in case you are wondering this monster was faster than [get_tiles -filter ([join $tileFilter {)||(}])]]
			set extendedTiles [get_tiles [filter [get_tiles -filter "$coordinate_property_x>=[expr {[dict get $boundingBox left]-1}] && $coordinate_property_x<=[expr {[dict get $boundingBox right]+1}]&&$coordinate_property_y>=[expr {[dict get $boundingBox bottom]-1}] && $coordinate_property_y<=[expr {[dict get $boundingBox top]+1}]"] ([join $tileFilter {)||(}])]]
		} else {
			#we have an empty result
			return {}
		}
			
		#Add DSP/BRAM Tiles to selection where needed
		#set specialTiles $extendedTiles
		set specialTiles {}
		
		#Once we have a proper way to store tileheight this might become obsolete,
		# for now we keep the initial tileheight consistent with selectOutline
		set absTileHeight [expr {abs($tileHeight)}]
		
		if {$tileHeight > 0} {
			set tileEndOffset [expr {$tileHeight-1}]
		} else {
			set tileEndOffset [expr {$tileHeight+1}]
		}
		
		set candidateTiles [get_tiles -regex -filter {TYPE=~BRAM_[LR]* || TYPE=~DSP_[LR]*}]
		
		foreach nullTile [filter $extendedTiles {TYPE==NULL}] {
			set x [get_property ${coordinate_property_x} $nullTile]
			set y [get_property ${coordinate_property_y} $nullTile]
			
			#We only have to fix the case where a long tile is next to a Null tile (going down, as the anchor point of DSP/BRAMs appears to be on the bottom)
			#never the less we try to keep it general.
			#As we only have to fix one side (the case where the BRAM tile is selected, and there is a border towards the end where it has a NullTile works, since the neighbouring
			#tile will be the next bram anchor tile.
			#As the problem tile has an anchor far away, we need to check on its near end if it should be selected.
			foreach candidateTile [filter $candidateTiles "${coordinate_property_x} == $x && ${coordinate_property_y} > [expr {$y-$absTileHeight}] && ${coordinate_property_y} < [expr {$y+$absTileHeight}]"] {
				set limit [expr {$y+$tileHeight}]
				
				#dirty harry's for loop
				for {set i [expr {[get_property $coordinate_property_y $candidateTile]+$increment}]} "\$i $comparator \$limit" {incr i $increment} {
					#set score [lindex $tileScoreMatrix [expr {[get_property $coordinate_property_y $candidateTile]+$tileEndOffset}] $x]
					set score [lindex $tileScoreMatrix $i $x]
					
					if {$score > 0 && $score < 10} {
						lappend specialTiles $candidateTile
						break
					}
				}
			}
		}
	
		#the lsort prevents no tiles matched ... warnings
		#for some perverted reason specialTiles is not a Tile collection, so we have to turn it into one...
		set specialTiles [get_tiles [lsort -unique $specialTiles]]
		
		return [lappend extendedTiles $specialTiles]
	}
}