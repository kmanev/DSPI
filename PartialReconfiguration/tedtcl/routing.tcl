package require try
package require struct::set

namespace eval ::ted::routing {
	##
	# Adds a load to a net.
	#
	# Adds an FDCE flip flop, so tehe available pins are C, CE, CLR, D. It is recommended to use C or D.
	# General examples for tiles would be:
	#
	# for a pblock
	#   [ted::rect::getTiles [ted::rect::boundingBox [ted::rect::ofPblock [get_pblocks PBlockName]]]]
	# for a clock region
	#   [get_tiles -of_objects [get_clock_regions ClockRegionName]]
	#
	# @param net             the net to which to add the load
	# @param tiles           the tiles in which the cell could be placed.
	# @param pinName         pin to use as a load (default D)
	# @param referenceCell   reference cell to use as load (default FDCE)
	#
	# @return                cell object of the newly created cell
	proc addLoad {net tiles {pinName D} {referenceCell FDCE}} {
		set cell [::ted::utility::createCellUnique $referenceCell loadCell]
		
		connect_net -net $net -hierarchical -objects [get_pins -of_objects $cell -filter "REF_PIN_NAME==$pinName"]
		
		set bel [ted::selectors::getFreeFlopOfTiles $tiles]
		
		if {$bel == {}} {
			::ted::utility::newGroup
			select_objects $tiles
			endgroup
			
			ted::errorOut ROUTING-0 "Could not find a free flop in the specified <selected> Tiles ($tiles)"
		}
		
		set_property BEL $bel $cell
		set_property LOC [get_sites -of_objects $bel] $cell
		
		return $cell
	}
	
	##
	# Block a clockleaf for a pblock
	#
	# Use with a pure \<leaf number\> for top/bot leafes, use with "L\<leaf number\>" (i.e. "L5") to get the L leaves.
	#
	# @param pblock       pblock for which to reserve the leaves
	# @param net          net to use for blocking
	# @param clkLeafNo    the id string (0, 1, 2, ... or L0, L1, L2, ...) of the leaf to block
	#
	# fixme, should this be for tiles?
	# fixme convenience methods : tilesOfPblock, clockingTilesOfPblock
	# fixme set_property loop should generate a list and call set_property once. 
	proc reserveClockLeaf {pblock net clkLeafNo} {
		variable ::ted::rect::coordinate_property_y
		
		set clockRect [ted::rect::extendVerticalToClock [ted::rect::boundingBox [ted::rect::ofPblock $pblock]]]
		set clockRegionHCLKtiles [ted::rect::getTiles $clockRect {} {NAME=~HCLK*}]
		
		#see if the hlck tiles are on the border, if on border do NOT select leaf wires that go up from top tiles/down from bottom tiles
		foreach node [get_nodes -of_objects [filter $clockRegionHCLKtiles "$coordinate_property_y > [dict get $clockRect bottom]"] -filter "NAME=~*/HCLK_LEAF_CLK_B_TOP${clkLeafNo}"] {
			set_property FIXED_ROUTE [list GAP $node] $net
		}
		
		foreach node [get_nodes -of_objects [filter $clockRegionHCLKtiles "$coordinate_property_y < [dict get $clockRect top]"   ] -filter "NAME=~*/HCLK_LEAF_CLK_B_BOT${clkLeafNo}"] {
			set_property FIXED_ROUTE [list GAP $node] $net
		}
	}
	
	##
	# Add loads for leafs.
	#
	# Adds load above/below each clock spline inside a pblock, in each column (currently only in columns with CLBs).
	#
	# @param pblock     pblock for which to add loads
	# @param net        net to add loads to
	#
	# fixme  addLoad should be implemented as a batch operation: find all sites, and create place and connect the load cells in batch
	proc loadClockLeafs {pblock net} {
		variable ::ted::rect::coordinate_property_y
		variable ::ted::rect::coordinate_property_x
		
		set pblockRect [ted::rect::boundingBox [ted::rect::ofPblock $pblock]]
		set clockRect [ted::rect::extendVerticalToClock $pblockRect]
		set clockRegionHCLKtiles [ted::rect::getTiles $clockRect {} {NAME=~HCLK*}]
		
		set bottomMin [dict get $pblockRect bottom]
		set topMax    [dict get $pblockRect top]
		set left      [dict get $pblockRect left]
		set right     [dict get $pblockRect right]
		
		set verticalRects {}
		
		while {[llength $clockRegionHCLKtiles]} {
			set hclkrow [get_property -min $coordinate_property_y $clockRegionHCLKtiles]
			
			set clockRegionRect [ted::rect::ofClockregion [lindex [get_clock_regions -of_objects [filter $clockRegionHCLKtiles "$coordinate_property_y == $hclkrow"]] 0]]
			set clockRegionHCLKtiles [filter $clockRegionHCLKtiles "$coordinate_property_y > $hclkrow"]
			
			set bottom [::math::max $bottomMin [dict get $clockRegionRect bottom]]
			set top    [::math::min $topMax    [dict get $clockRegionRect top   ]]
			
			if {$bottom > $hclkrow} {
				#our pblock starts after the clock row and spans from bottom to min(endOfClockRegion, top)
				lappend verticalRects [ted::rect::rect $top $right $bottom $left]
			} elseif {$bottom < $hclkrow} {
				#exclude the case bottom = hclkrow (dont generate an empty rect)
				if {$hclkrow < $top} {
					lappend verticalRects [ted::rect::rect $hclkrow 0 $bottom 0]
					lappend verticalRects [ted::rect::rect $top 0 $hclkrow 0]
				} else {
					#top < hclkrow && bottom < $hclkrow (the pblock does not span a hclkrow or clock region)
					lappend verticalRects [ted::rect::rect $top 0 $bottom 0]
				}
			}
		}
		
		foreach rect $verticalRects {
			set rect [ted::rect::rect [dict get $rect top] $right [dict get $rect bottom] $left]
			set loadTiles [ted::rect::getTiles $rect {} {TILE_TYPE=~CLB*}]
			
			foreach loadColumn [lsort -unique [get_property $coordinate_property_x $loadTiles]] {
				addLoad $net [filter $loadTiles "$coordinate_property_x==$loadColumn"]
			}
		}
	}
	
	##
	# Route multiple clocks to various tilegroups.
	#
	# The main purpose of this function is to route clocks on the same wire to tilegroups, where the tilegroups,
	# serve as slots for partial reconfiguration.
	#
	# Route clocks constrained to various hclk_wires/leafs to the various tilegroups. Interestingly enough,
	# trying to implicate a node with `FIXED_ROUTE` causes the router to pick an alternative route.
	# However, unrouting the net before routing it seems to leave a hint in the router database, which is picked up by subsequent routes.
	# If you want to try this run this with force set to 0. Setting force will additionally route a blocker net on all other wires giving the
	# router no choice, however in light of the previous findings this seems to be unneccessary effort.
	#
	# in C++ pseudo syntax(could be a typedefinition with using statements, reorderd for human readability):
	# (for tcl assume pair is always a list, where the first element in the list is the first type of the pair, and the second
	# element represents the second pair type. For tuples extend the pair to n elements.)
	#
	#   clockConfiguration    = list<pair<tilegroup, list<clockinformation>>>
	#   clockinformation      = tuple<clocknet, list<hclkindices>, list<leafindices>>
	# 
	# i.e. to have pblock0 set up for clock 0 comming in on hclk wire 1 and going up on the L2 leafs do:
	#
	#   set tileConfiguration [list 
	#     [list
	#       tilegroup0
	#       [list
	#         [list
	#           clock0
	#           [list
	#             1
	#           ]
	#           [list
	#             L2
	#           ]
	#         ]
	#       ]
	#     ]
	#   ]
	#
	#   # flattened:
	#   set tileConfiguration [list [list tilegroup0 [list [list clock0 [list 1] [list L2]]]]]
	#
	# It is easy to specify more clocks comming into the tilegroup, or having the clock route onto more nets by duplicating the entries.
	#
	# IMPORTANT NOTE: this function is designed to be called once and ONLY ONCE for the entire design
	#
	# @param tileConfigurations               pblock configuration, see detailed documentation above. Describes the clocks and the leaf/hclk wires on which to route them for each pblock.
	# @param force                           boolean. weather the router should be forced to use the wires. (default false)
	#
	#fixme we do not create loads for every leaf => currently only on leaf per pblock and clock is supported, as we do not connect the leafs explicitly to the different loads.
	proc routeClocks {tileConfigurations {force false} {loadLeafs true}} {
		#Reorder into the format list<tuple<clock, list<tuple<tilegroup, list<clkhindices>, list<leafindices>>>
		set clockConfiguration [dict create]
		
		foreach tileConfiguration $tileConfigurations {
			foreach {tiles clockinfos} $tileConfiguration {
				
				foreach clockinfo $clockinfos {
					foreach {clocknet hclkindices leafindices} $clockinfo {
						dict lappend clockConfiguration $clocknet [list $tiles $hclkindices $leafindices]
					}
				}
			}
		}
		
		#reserve the nets
		#attempt to make all tiles a collection
		set allTiles [get_tiles -filter {NAME==NoTile}]
		
		dict for {clocknet configurations} $clockConfiguration {
			set clocknet [get_nets $clocknet]
			
			foreach tileConfiguration $configurations {
				foreach {tiles hclkindices leafindices} $tileConfiguration {
					#clocknet to hclk
					
					::ted::routing::routeToBufHs $clocknet $hclkindices [get_clock_regions -of_objects $tiles]
					#syntax oddity: by using lappend like this with collections, the right thing happens without convertint the collection to a
					#list first as the regular `lappend allTiles {*}$tiles` would. The regular approach usually hits the tcl.collectionResultDisplayLimit
					#causing incorrect bahaviour
					lappend allTiles $tiles
					#reserveHwires $clocknet $hclkindices [get_clock_regions -of_objects [ted::rect::getTiles [ted::rect::boundingBox [ted::rect::ofPblock $pblock]]]]
					#clocknet to leafs
					foreach leaf $leafindices {
						::ted::routing::reserveClockLeaf $tiles $clocknet $leaf
						if {$loadLeafs} {
							::ted::routing::loadClockLeafs $tiles $clocknet
						}
					}
				}
			}
		}
		
		#block the rest
		dict for {clocknet configurations} $clockConfiguration {
			set clocknet [get_nets $clocknet]
			
			#Our hint seems sufficient, no locking needed
			if {$force} {
				set locker [getLockerNet]
				::ted::routing::blockFreeClockNets $locker $allTiles
			}
			
			#route_design -pins [get_pins -of_objects $clocknet]
			#cant use -auto_delay as this prevents clock routing
			#cant use -preserve as that cant be used with other options
			#note -nets disables some timing optimizations
			::ted::routing::unroute $clocknet -removeFixed
			route_design -nets $clocknet
			
			if {$force} {
				::ted::routing::unroute $locker -removeFixed
			}
		}
	}
	
	##
	# Unroutes a net.
	#
	# Can unroute a net that was constrained if desired.
	#
	#   -removeFixed       boolean. removes location constrains and unroutes wires with fixed routing as well
	#
	# @param nets              nets to unroute
	# @param args              used for flags, see documentation 
	proc unroute {nets args} {
		ted::utility::argParse {-removeFixed {false}}
		
		if {$removeFixed} {
			set_property IS_ROUTE_FIXED 0 $nets
		}
		
		route_design -unroute -net $nets
	}
	
	##
	# Get the GND net.
	#
	# Creates a driver once, afterwards returns references to the same net
	#
	# @return net object representing GND
	proc getNetGND {{parent {}}} {
		set gndNets [get_nets [::ted::utility::joinPath $parent *] -filter TYPE==GROUND -quiet]
		if {[llength $gndNets]} {
			return [lindex $gndNets 0]
		}
		
		::ted::utility::message 0 {Creating ground net.} INFO
		return [::ted::utility::scopeCode {::ted::routing::_createPhysicalNet GND} $parent]
	}
	
	##
	# Get the VCC net.
	#
	# Creates a driver once, afterwards returns references to the same net
	#
	# @return net object representing VCC
	proc getNetVCC {{parent {}}} {
		set vccNets [get_nets [::ted::utility::joinPath $parent *] -filter TYPE==POWER -quiet]
		if {[llength $vccNets]} {
			return [lindex $vccNets 0]
		}
		
		::ted::utility::message 0 {Creating ground net.} INFO
		return [::ted::utility::scopeCode {::ted::routing::_createPhysicalNet VCC} $parent]
	}
	
	##
	# Create a physical (VCC/GND) net.
	#
	# Since the tool merges all VCC/GND nets it is better to use getNetVCC / getNetGND respectivly,
	# which only create the net and driver cell on their first run, and return it thereafter.
	#
	# @param referenceCell          cell to use as driver, either GND or VCC
	#
	# @return    net object of the created net
	proc _createPhysicalNet {{referenceCell GND}} {
		set allowedCells [list GND VCC]
		
		set cellName CUSTOM_ROUTING_BLOCKER_${referenceCell}_
		set netName  CUSTOM_ROUTING_BLOCKER_${referenceCell}_NET_
		
		if {[lsearch -exact $allowedCells $referenceCell]==-1} {
			error [::ted::formatError "Reference cell $referenceCell is not an allowed cell ($allowedCells)"]
		}
		
		#todo use ted::createCellUnique
		set cell       [::ted::utility::createCellUnique ${cellName} $referenceCell]
		
		#fixme let create unique throw, unless it is made quiet
		if {$cell eq {}} {
			error [::ted::formatError "Failed to create cell to drive locker net."]
		}
		
		#todo use ted::createNetUnique
		set lockerNet [::ted::utility::createNetUnique ${netName}]
		
		#fixme let create unique throw, unless it is made quiet
		if {$lockerNet eq {}} {
			remove_cell $cell
			error [::ted::formatError "Failed to create locker net."]
		}
		
		#fixme: this is not scopedCode safe, as the net name will be overspecified
		#connect_net -hierarchical -net $lockerNet -objects [get_pins -of_objects ${cell}]
		connect_net -dict [list $lockerNet [get_pins -of_objects ${cell}]]
		
		return $lockerNet
	}

	
	##
	# Removes the net(s) and their driver(s).
	#
	# Note: do not use this directly on [getNetGND/VCC] as these are cached. Use removeNetGND/VCC as
	# these also invalidate the cached objects, so that you get proper values from future calls to [getNetGND/VCC]
	#
	# @param nets            list of nets/net to remove (along with its driver cell.
	proc removeNetAndDriver {nets} {
		set cells {}
		
		foreach net $nets {
			lappend cell [get_cells -of_objects [::ted::selectors::getDriver $net]]
		}
		
		::ted::routing::unroute $nets -removeFixed
		remove_cell $cells
		remove_net $nets
	}

	##
	# @internal
	# Blocks the specified nodes.
	#
	# Internal helper to ease the debug implementation
	# Note: Sometimes the Vivado router overrides these blocks, there will be a warning though.
	#
	# @param net              net to use for blocking
	# @param routeSegments    list of ellements that can be assigned as FIXED_ROUTE (i.e. nodes/wires) to block
	proc _blockNodes {net routeSegments} {
		if {[get_property TYPE $net] in {GROUND POWER}} {
		#GND/VCC may not have GAPs => we need to add each segment on its own, causing long runtimes
			set_property FIXED_ROUTE [join [list "\{" [join $routeSegments "\}\{"] "\}"] {}] $net
		} else {
		#we are allowed to have GAPs => create a fast blocker with just one net addition with GAPs
			set_property FIXED_ROUTE "GAP [join $routeSegments { GAP }]" $net
		}
	}
	
	##
	# @internal
	# Trys to block specified nodes, reports nodes that could not be blocked.
	#
	# Used to help with debugging, return list contains a list of failing nodes as the second element.
	#
	# @param net              net to use for blocking
	# @param routeSegments    list of ellements that can be assigned as FIXED_ROUTE (i.e. nodes/wires) to block
	# @param chunksize        for recursion (i.e. no need to specify in manual calls), how many nodes to attempt to block in bulk
	# @param indent           for recursion (i.e. no need to specify in manual calls), indents messages correctly
	#
	# @return             pair<elements till error, list<failing nodes>>
	proc _blockNodesDebug {net routeSegments {chunksize {}} {indent {}}} {
		set top false
		set failedNodes {}
		
		if {$chunksize eq {}} {
			set maxChunkSize 1000
			#set chunksize [expr {min(int(ceil(double([llength $nodes])/10)), $maxChunkSize)}]
			set chunksize [expr {min(int(ceil(pow(10, int(floor(log10([llength $routeSegments])))-1))), $maxChunkSize)}]
			set top true
			set offendingNodes 0
			set disappearedErrors 0
		}
		
		puts "${indent}Called with [llength $routeSegments] and a chunksize of $chunksize"

		set totalRounds [expr {int(ceil(double([llength $routeSegments])/$chunksize))}]
		set chunkRange [expr {$chunksize-1}]
		set round 0
		
		while {[llength $routeSegments]} {
			try {
				while {[llength $routeSegments]} {
					puts "${indent} round [incr round]/$totalRounds"
					_blockNodes $net [lrange $routeSegments 0 $chunkRange]
					set routeSegments [lrange $routeSegments $chunksize end]
				}
				
			} trap {} {result errorDict} {
				if {$result eq {}} {
					puts "assuming interrupt, cancelling"
					return -options $errorDict $result
				}
				
				#on error {}
				if {$chunksize == 1} {
					puts "${indent}=== Found failed Node ==="
					puts "${indent} -> [lindex $nodes 0]!"
					return [list $round [lindex $routeSegments 0]]
				} else {
					lassign [_blockNodesDebug $net [lrange $routeSegments 0 $chunkRange] [expr {max(int(ceil(double($chunksize)/10)),1)}] "${indent}  "] skip failedNode
					
					if {$top} {
						if {$failedNode ne {}} {
							lappend failedNodes $failedNode
							puts "Identified [incr offendingNodes] offending nodes so far."
						} else {
							puts "The error in range [expr {($round-1)*$chunksize}]:[expr {$round*$chunksize-1}] disappeared. ([incr disappearedErrors] errors disappeared)"
							
							puts "skipping the block adjusting skip from $skip to $chunksize"
							set skip $chunksize
						}
						
						puts "Skipping $skip nodes."
						set nodes [lrange $routeSegments $skip end]
						
						set round [expr {$totalRounds-int(ceil(double([llength $routeSegments])/$chunksize))}]
					} else {
						return [list [expr {($round-1)*$chunksize+$skip}] $failedNode]
					}
				}
			}
		}

		if {$top} {
			puts "Found $offendingNodes errors, and had $disappearedErrors errors disappear while trying to pinpint them."
			puts "Offending nets are:\n[join $failedNodes \n]"
		}
		return [list 0 $failedNodes]
	}
	
	##
	# Blocks the specified nodes.
	#
	# Note: Sometimes the Vivado router overrides these blocks, there will be a warning though.
	#
	# Enable debug with ::ted::DEBUG::enableDebug ted::routing::blockNodes
	#
	# @param net              net to use for blocking
	# @param routeSegments    list of ellements that can be assigned as FIXED_ROUTE (i.e. nodes/wires) to block
	# @param args             optional arguments: -excludeClock : exclude all clock nodes, -onlyClock : block only clock nodes
	#
	# @return                 nodes actually blocked
	proc blockNodes {net nodes args} {
		while {[llength $args]} {
			switch [lindex $args 0] {
				-excludeClock {
					set nodes [filter $nodes -regexp [ted::utility::filterNormalize ![ted::architecture::call filter_clock_nodes]]]
					set args [lrange $args 1 end]
				}
				-onlyClock {
					set nodes [filter $nodes -regexp [ted::utility::filterNormalize [ted::architecture::call filter_clock_nodes]]]
					set args [lrange $args 1 end]
				}
				default {
					::ted::utility::errorOut 0 "Unknown option '[lindex $args 0]' passed to blockNodes."
				}
			}
		}
		
		#fixme: should we filter out all nodes that are tied to specific values (CLASS!=NODE||(!IS_GND&&!IS_VCC))
		if {[::ted::DEBUG::debugEnabled ]} {
			#fixme the failing nodes are lost...
			_blockNodesDebug $net $nodes
		} else {
			_blockNodes $net $nodes
		}
		
		return $nodes
	}
	
	##
	# Blocks the free nodes of the specified nodes.
	#
	# Note: Sometimes the Vivado router overrides these blocks, there will be a warning though.
	#
	# Enable debug with ::ted::DEBUG::enableDebug ted::routing::blockNodes, Note debugging output will
	# be skipped if no nodes are considered free. Check the function return value to see which nodes were
	# actually (considered) for blocking.
	#
	# @param net              net to use for blocking
	# @param routeSegments    list of ellements that can be assigned as FIXED_ROUTE (i.e. nodes/wires)
	# @param args             optional arguments: -excludeClock : exclude all clock nodes, -onlyClock : block only clock nodes
	#
	# @return                 list of nodes that are actually blocked
	proc blockFreeNodes {net nodes args} {
		set freeNodes [::struct::set difference \
			$nodes \
			[get_nodes -of_objects [get_nets -of_objects $nodes -quiet] -quiet] \
		]
		
		#fix up for the invisible nets GND/VCC (which are not returned by get_nets -of_objects $nodes)
		set freeNodes [::struct::set difference \
			$freeNodes \
			[get_nodes -of_objects [list [::ted::routing::getNetGND] [::ted::routing::getNetVCC]] -quiet] \
		]
		
		if {[llength $freeNodes]} {
			return [blockNodes $net $freeNodes {*}$args]
		}
		
		return $freeNodes
	}
	
	##
	# Blocks all nodes (wire segments) on tiles which are currently not in use.
	#
	# The LIOB_MONITOR* wires and global wires as well as vcc/gnd are excluded.
	#
	# @param net         net to use as a blocker (should be vcc/gnd (getNetVCC/GND))
	# @param tiles       tiles for which to block
	# @param args             optional arguments: -excludeClock : exclude all clock nodes, -onlyClock : block only clock nodes
	#
	# @return            list of nodes that are actually blocked
	proc blockFreeNodesOnTiles {net tiles args} {
		#TODO use new filter engine for family specific exclusions.
		return [::ted::routing::blockFreeNodes $net [get_nodes -of_objects $tiles -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR*}] {*}$args]
	}
	
	##
	# Find a/all possible paths between a start and one of several/all targets.
	#
	# Either finds a possible path from the start to one of the possible targets or all
	# paths to all targets.
	#
	# @param start        starting node
	# @param targets      list of target nodes
	# @param maxHops      maximum number of hops allowed, set to negative for infinite (default: -1)
	# @param exhaustive   boolean, search for all paths (otherwise the first path found is returned) (default: false)
	#
	# @return             list of paths (path is a list of nodes) found between start and target(s)
	#fixme: add through LUT routing?
	#fixme: does not protect against loops
	proc searchRoutes {start targets {maxHops -1} {exhaustive false}} {
		set leafs [list [list {} $start]]
		set hops 0
		set paths {}
		
		while {$hops!=$maxHops && [llength leafs]} {
			lassign [lindex $leafs 0] path leafNodes
			
			foreach leaf $leafNodes {
				set newLeafs [get_nodes -downhill -of_objects $leaf -quiet]
				
				set reachables [::struct::set intersect $newLeafs $targets]
				
				if {!$exhaustive&&[llength $reachables]} {
					return [list [list {*}$path $leaf [lindex $reachables 0]]]
				}
				
				foreach reachable $reachables {
					lappend paths [list {*}$path $leaf $reachable]
				}
				
				lappend nextLevelLeafs [list [list {*}$path $leaf] $newLeafs]
			}
			
			#puts "..popping [lindex $leafs 0]"
			if {[llength $leafs]>1} {
				#pop
				#set leafs [lreplace $leafs 0 0]
				set leafs [lrange $leafs 1 end]
			} else {
				#go to the next leaf in breath first search
				set leafs $nextLevelLeafs
				set nextLevelLeafs {}
				incr hops
				#puts "Hop $hops"
			}
		}
		
		return $paths
	}
	
	# Implementation alternative: have a searchRoutes with disallowed nodes, that would be better for searches with unbounded hops
	proc searchRouting {starts targets {maxHops 5}} {
		set routeBundles {}
		set indices {}
		
		#todo disallow negative maxHops
		foreach start $starts target $targets {
			set routeBundle [::ted::routing::searchRoutes [list $start] [list $target] $maxHops true]
			
			if {![llength $routeBundle]} {
				::ted::utility::errorOut 0 "Could not find any routing paths between $start and $target with $maxHops or less hops"
			}
			
			lappend routeBundles $routeBundle
			
			lappend indices 0
		}
		
		#set indices [lrepeat [llength $routeBundles] 0]
		
		set currentIndex 0
		#puts [join $routeBundles \n]
		
		while {true} {
			set collision false
			set routeIndex [lindex $indices $currentIndex]
			set path [lindex $routeBundles $currentIndex $routeIndex]
			
			foreach i [::ted::utility::range $currentIndex] {
				#check the path given by this
				set otherPath [lindex $routeBundles $i [lindex $indices $currentIndex]]
				
				#TODO: should we use string equal?
				if {[lindex $path 0] eq [lindex $otherPath 0]} {
					#skip paths with same start
					continue
				}
				
				set collision [llength [::struct::set intersect $path $otherPath]]
				
				if {$collision} {
					break
				}
			}
				
			if {$collision} {
				if {$routeIndex<[llength [lindex $routeBundles $currentIndex]]} {
					#try the next one
					lset indices $currentIndex [expr {+1}]
				} else {
					#backtracking
					lset indices $currentIndex 0
					incr currentIndex -1
					
					if {$currentIndex<0} {
						#no routing found
						#todo: should we throw
						return {}
					}
				}
			} else {
				#look deeper
				incr currentIndex
				
				if {$currentIndex>=[llength indices]} {
					#done
					set paths {}
					
					foreach routeBundle $routeBundles index $indices {
						lappend paths [lindex $routeBundle $index]
					}
					
					return $paths
				}
			}
		}
	}
}