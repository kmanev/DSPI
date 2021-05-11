## Depreceated code
namespace eval deprecated {
	##
	# Deprecated routing:: functions
	namespace eval routing {
		##
		# Routes a clock onto a hwire.
		#
		# @deprecated     Use ted::routing::routeOntoHwires instead.
		#
		# @deprecated While showing how to add a single load in the right spot, and using ted::routing::addRoutingLeg
		#              to nicely ensure a proper fixed route, the general use case of locking a wire onto a specific hclk line
		#              requires to lock the leafs as well, which in turn requires one load per leaf, therefore this is outdated
		#
		# Command places a load with loadClock, to allow bitstream generation.
		#
		# @param net           clock net to route
		# @param hIndice       the indice of the hnet to route to
		# @param clockregions  for which clock regions to route onto the hwire
		# @param pblock        a pblock into which the load should be placed
		#
		# @return              returns the cells that have been loaded
		proc routeToHwire {net hIndice clockregions {pblock {}}} {
			set pips [get_pips -of_objects [ted::selectors::bufhce $hIndice $clockregions]]
			set pipSegments {}
			set start [get_nodes -of_objects [get_site_pins -of_objects [ted::selectors::getDriver $net]]]
			
			foreach pip $pips {
				lappend pipSegments [list $start GAP $pip {*}[get_pips -of_objects $pip]]
			}
			
			set_property FIXED_ROUTE $pipSegments $net
			
			set loadCells {}
			
			foreach clockRegion $clockregions {
				# [list $clockRegion] protects us against decaying the clock region object into a string in lower functions,
				# which is not usabel for functions like get_property
				# 
				# https://stackoverflow.com/q/46623288/258418
				# https://forums.xilinx.com/t5/Vivado-TCL-Community/TCL-get-broken-in-combination-with-foreach/td-p/799063
				set loadedCell [loadClock $net [list $clockRegion] $pblock]
				set start  [get_nodes -of_objects [get_pips -of_objects [get_pips -of_objects [ted::selectors::bufhce $hIndice $clockRegion]]] -downhill]
				set target [get_nodes -of_objects [get_site_pins -of_objects [get_pins -of_objects $loadedCell -filter {IS_CLOCK}]]]
				#todo fixme remove the fixation of the routing leg (last parameter should be 0)
				addRoutingLeg $net $start $target 1
				
				lappend loadCells $loadedCell
			}
			
			return $loadCells
		}
		
		##
		# Idea was to force the router to pick a route by blocking all possible branches. Might have to be reactivated, if we cant get this done with
		# set_property fixed_route + route_design -preserve or in another way
		#
		# We might have to make sure that the blocker is not directly at the branch but one leg done, to ensure that we dont have short circuits preventing the router from finding the intended solution
		#
		#walking the route works, however it complains about the gaps in the GND net, change this to another net?, do we have to leave a gap of one element between the net we want to block and another net?
		#
		# @deprecated the implementation is incomplete, and completing it correctly seems very complex and unnecessary at this point in time
		proc lock_nodes {start route} {
			set nextnode $start
			set segmentIndex 0
			set lastPipLeg {}
			
			set lockNodes {}
		
			foreach leg $route {
				set found 0
	
				foreach node [get_nodes -downhill -of_objects $nextnode] {
					if {[string match "*/${leg}" [get_property NAME $node]]} {
						puts $node
						set lastPipLeg {}
						incr segmentIndex
						
						set nextnode $node
						#lock remaining & break
						#flag that we found our next node (dont want to get caught in an infinite loop)
						set found 1
					} else {
						#lock
						if { [get_nets -of_objects $node] == {} } {
							puts "Adding $node"
							lappend lockNodes $node
						}
					}
					
				}
				
				if {!$found} {
					puts "trying pips"
					
					foreach pip [get_pips -of_objects $nextnode] {
						if {[string match "*${lastPipLeg}->>${leg}" [get_property NAME $pip]]} {
							puts "found a pip: $pip"
							set lastPipLeg $leg
							
							incr segmentIndex
							#lock remaining & break
							set nextnode $pip
							set found 1
						} else {
							#lock
						}
					}	
				}	
				
				if {!$found} {
					puts "error: Could not find leg $leg on node $nextnode"
					return
				}
				
				#if { $segmentIndex == [llength $route]-2 } {
				#	puts "victory"
				#	return
				#}
			}
			
			set_property FIXED_ROUTE "GAP [join $lockNodes { GAP }]" [getLockerNet]
			puts done
		}
	
		##
		# Adds a load to a clock (can be used to prevent antennas).
		#
		# @deprecated use ted::routing::addLoad
		#
		# @deprecated addLoad is more general and similar effects can be achieved by using either [get_tiles -of_objects [get_clock_regions ClockRegionName]] or
		#              [ted::rect::getTiles [ted::rect::boundingBox [ted::rect::ofPblock PBlockObject]]]
		#
		# Can also be used to load other nets, in that case it might be advisable though
		# to just create the load cell, and let the tools place the load freely.
		#
		# @param net                  the clock net to load
		# @param clockRegion          potentially a clock region in which the loading cell should be placed
		# @param pblock               a pblock, in which the load should be placed
		#
		# @return                     cell object, of the load cell that has been placed (easier to turn cell to bel, other path msut be bel -> site -> cell, which can be ambiguous)
		proc loadClock {net {clockRegion {}} {pblock {}}} {
			ted::static counter 0
			set cell [create_cell -reference FDCE clockLoad_${counter}]
			
			incr counter
			
			connect_net -net $net -hierarchical -objects [get_pins -of_objects $cell -filter {REF_PIN_NAME == C}]
			
			#selectors::getFreeLutBel $clockRegion $pblock
			
			set bel [ted::selectors::getFreeFlop $clockRegion $pblock]
			
			set_property BEL $bel $cell
			set_property LOC [get_sites -of_objects $bel] $cell
			
			return $cell
		}
		
		##
		# Making only the previously fixed parts of a route fixed
		proc __possibleUsefulPatter {} {
			set fixedBefore [get_property FIXED_ROUTE $net]
			if {!$fix} {
				set_property IS_ROUTE_FIXED 0 $net
				set_property FIXED_ROUTE $fixedBefore $net
			}
		}
	}
	
	##
	# Deprecated partial:: functions
	namespace eval partial {
		##
		# Prevents constant propagation and optimizations (depreceated / unsafe).
		#
		# @deprecated Since the tools can perform some constant propargation during synthesis this method is unsafe.
		# The prefered way is to modify the rtl, with the dummyCOnnector.sv
		#
		# Use case: if you have a dummy connection for a partial module,
		# this conneciton might get tied to 0. As the tools see this as a constant,
		# they might optimize out some donestream logic that is needed, once we connect a proper driver
		# to the net that generates non constant inputs.
		# Output pins ending in nirvana might be optimized away, as their result is unused. This might propagate
		# upstream, resulting in logic that is supposed to drive the partial design being stripped.
		#
		# Works by attaching flip flops to the pins that are marked as DONT_TOUCH.
		#
		# Uses the fact that constant propagation (-propconst) is part of opt_design, AFTER synthesis.
		# This also explains why you should run this BEFORE opt_design
		#
		# @param pins             pins to drive/whose output need to be made nonexpandable
		# @param pblock           pblock into which the generated flip flops should be constrained (default {})
		proc preventPrematureOptimization {pins {pblock {}}} {
			ted::static id 0
			set netPrefix PREMATURE_OPTIMIZATION_PREVENTION_NET_${id}_
			set cellPrefix PREMATURE_OPTIMIZATION_PREVENTION_CELL_${id}_
			
			#add ff for every cell, mark them dont touch
			#connect them to the endpoints
			#set outPins             [filter $pins {DIRECTION == OUT}]
			set inPins              [filter $pins {DIRECTION == IN && IS_CONNECTED == 0}]
			
			#set outPinsPreconnected [filter $pins {IS_CONNECTED == 1 && DIRECTION == OUT}]
			set inPinsPreconnected  [filter $pins {IS_CONNECTED == 1 && DIRECTION == IN}]
			
			set inNet  ${netPrefix}_IN
			set outNet ${netPrefix}_OUT
			
			set originalScope [current_instance .]
			set pathPrefix $originalScope[get_hierarchy_separator]
			
			set i 0
			set j 0
			
			foreach outpin [filter $pins {DIRECTION == OUT}] {
				
				set net [get_nets -quiet -of_objects $outpin]
				
				if {[llength $net]} {
					set cellName ${cellPrefix}_OUT_PRE_${i}
					lappend cells $cellName
					lappend connections $net [list $pathPrefix$cellName/D]
					incr i
				} else {
					set cellName ${cellPrefix}_OUT_${j}
					lappend outPins $outpin
					lappend cells $cellName
					lappend connections "$pathPrefix$outNet\[$j\]" [list $pathPrefix$cellName/D]
					incr j
				}
			}
			
			#for {set i 0} {$i < [llength $outPins]} {incr i} {
			#	set cellName ${cellPrefix}_OUT_${i}
			#	lappend cells $cellName
			#	lappend connections "$pathPrefix$outNet\[$i\]" [list [lindex $outPins $i] $pathPrefix$cellName/D]
			#}
			
			for {set i 0} {$i < [llength $inPins]} {incr i} {
				set cellName ${cellPrefix}_IN_${i}
				lappend cells $cellName
				lappend connections "$pathPrefix$inNet\[$i\]"  [list [lindex $inPins $i] $pathPrefix$cellName/Q]
			}
			
			#for {set i 0} {$i < [llength $outPinsPreconnected]} {incr i} {
			#	set cellName ${cellPrefix}_OUT_PRE_${i}
			#	lappend cells $cellName
			#	lappend connections [get_nets -of_objects [lindex $outPinsPreconnected $i]] [list $pathPrefix$cellName/D]
			#	#[lindex $outPinsPreconnected $i]
			#}
			
			for {set i 0} {$i < [llength $inPinsPreconnected]} {incr i} {
				set cellName ${cellPrefix}_IN_PRE_${i}
				lappend cells $cellName
				lappend connections [get_nets -of_objects [lindex $inPinsPreconnected $i]] [list $pathPrefix$cellName/Q]
				#[lindex $inPinsPreconnected $i]
			}
			
			create_net -from [expr {[llength $outPins] - 1}] -to 0 $outNet
			create_net -from [expr {[llength $inPins]  - 1}] -to 0 $inNet
			
			set cells [create_cell -reference FDCE $cells]
	
			ted::toplevel {
				connect_net -hierarchical -net_object_list $connections
				set_property DONT_TOUCH 1 [get_cells $cells]
				
				if {$pblock != {}} {
					add_cells_to_pblock $pblock $cells
					}
			}
			#current_instance $originalScope
		}
	}
	
	## Deprecated selectors:: functions
	namespace eval selectors {
		##
		# Faster version of get_tiles -filter {} for filter with lots of ||.
		#
		# @depreciated as this very special use case, the snippet is here for documentation. In case you suspect a
		# speedup just copy the line
		#
		# Sample expression for which it can be faster "(x==1&&y1)||(x==2&&y==2)||..."
		#
		# During testing we noted that with Vivado 17.1 get_tiles -filter {(x==1&&y1)||(x==2&&y==2)||...} is much
		# slower (over 10x, we aborted the command after 700secs), than filter [get_tiles] {(x==1&&y1)||(x==2&&y==2)||...}
		# this is the convenience wrapper.
		#
		# @param filterExpression           filter expression to apply
		# @param flags                      flags to `filter` command (i.e. -regexp)
		#
		# @return            a set of filtered tiles
		proc getTilesFast {filterExpression {flags {}}} {
			return [filter [get_tiles] $filterExpression {*}$flags]
		}
		
		##
		# Adds Null-tiles for tiles that span multiple rows to a tile selection.
		#
		# @depreciated While we could select additional tiles, that are not part of the initial tile selection,
		#              these tiles get removed when we append them. I.e. despite adding several tiles, the returned collection
		#              is unchanged.
		#
		# Currently supported tiles: DSP, BRAM
		#
		# Adds Null tiles to a tile selection containg BRAMs and DSPs. As Brams and DSPs
		# span 5 rows, but the Tile reports only for one Gridpoint, we end up having gaps in a
		# square grid. Xilinx provides Null Tiles in the slots spanned by the BRAMs/DSPs, This command
		# adds them to the selection.
		proc regularizeTileselection {tiles} {
			variable coordinate_property_x $::ted::rect::coordinate_property_x ;#< Property to extract X coordinate
			variable coordinate_property_y $::ted::rect::coordinate_property_y ;#< Property to extract Y coordinate
			
			#DSP/BRAM Tiles extend 5 Tiles upwards from their original location
			set tileHeight -5
			set lowOffset  [expr {$tileHeight>0?1:$tileHeight+1}]
			set highOffset [expr {$tileHeight>0?$tileHeight-1:-1}]
			set i 0
			puts "Got [llength $tiles] tiles"
			foreach largeTile [filter $tiles -regexp {TYPE=~BRAM_[LR]* || TYPE=~DSP_[LR]*}] {
				set y [get_property ${coordinate_property_y} $largeTile]
				
				set nullTiles [get_tiles -filter "${coordinate_property_x}==[get_property ${coordinate_property_x} $largeTile] && (${coordinate_property_y}>=[expr {$y+${lowOffset}}] && ${coordinate_property_y}<=[expr {$y+${highOffset}}])"]
				puts adding:[llength $nullTiles]
				lappend $tiles $nullTiles
				incr i
			}
			
			puts "ran $i iterations. Got [llength $tiles] tiles"
			
			return $tiles
		}		
	}
}