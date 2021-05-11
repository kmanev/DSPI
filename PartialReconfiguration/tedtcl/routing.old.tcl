package require math

##
# Functions to help with routing
namespace eval ::ted::routing {
	#namespace path [list ::ted {*}[namespace path]]
	
	#variable added [dict create] ;#< collect objects created by router help scripts
	
	variable _NetGND {}
	variable _NetVCC {}
	
	## 
	# Creates a generic locker net.
	#
	# Has to be used with "GAP" in FIXED_ROTUE statements, since it is not based on physical nets.
	#
	# set_property FIXED_ROUTE "GAP $node" [getLockerNet]
	#
	# @return          net object of the newly created locker net
	# fixme should this be name getNetLocker
	#TODO add prefix to created elements
	proc getLockerNet {} {
		set cell [::ted::utility::createCellUnique FDSE CUSTOM_ROUTING_BLOCKER]
		
		if {$cell eq {}} {
			::ted::utility::errorOut 0 "Failed to create cell to drive locker net."
		}

		set lockerNet [::ted::utility::createNetUnique CUSTOM_ROUTING_BLOCKER_NET]
		
		if {$lockerNet eq {}} {
			remove_cell $cell
			::ted::utility::errorOut 0 "Failed to create locker net."
		}
		
		dict lappend added cells $cell
		dict lappend added nets  $lockerNet
		
		connect_net -hierarchical -net $lockerNet -objects [get_pins -of_objects ${cell} -filter {DIRECTION==OUT}]

		#manual placing seems a lot faster than running_place_design
		
		#split up into clockregions, as we needed about 3 secs to run this on one clockregion, compared to 60 secs for all clockregions
		#assuming that we can find a free flop easier, we might save significant time
		foreach clockRegion [get_clock_regions] {
			#Attempt to get only FLOP BELs that are directly connected to tile pins, as the other flops ([A-D]5FF), go through a multiplexer through a site_wire
			#we have no tcl api to detect this, and setting FIXED_ROUTES from a site_wire gives an error
			
			#TODO: should this be a extra routine
			set bel [get_bels -regexp -filter {IS_USED==0 && PROHIBIT==0 && NAME=~.*/.FF} -of_objects $clockRegion]
			
			if {[llength $bel] > 0} {
				break;
			}
		}
		
		if {[llength $bel] == 0} {
			::ted::utility::errorOut 0 "Failed to find available FF position. Running place_design might solve this, but the cost is so high that we rather inform you about this."
		}
		
		place_cell $cell [lindex $bel 0]
		
		incr counter
		return $lockerNet
	}
	

	
	##
	# Reserves a Hwire for a certain net.
	#
	# @param net                  net to reserve the wires for
	# @param hIndices             hwire indices to reserve
	# @param clockregions         clockregions in which to reserve the h wires
	# @param softBlock            boolean. block only, if there is no driver in the bufhce (default true)
	proc reserveHwires {net hIndices clockregions {softBlock true}} {
		set bufhce [ted::selectors::bufhce $hIndices $clockregions]
		
		if {$softBlock} {
			set bufhce [filter $bufhce {!IS_USED}]
			#todo: is it necessary to check if the subsequent net is used?
		}
		
		set pips [get_pips -of_objects $bufhce]
		set pipSegments {}
		
		foreach pip $pips {
			lappend pipSegments [list $pip {*}[get_pips -of_objects $pip]]
		}
		
		set_property FIXED_ROUTE $pipSegments $net
	}
	
	##
	# Route net to bufhs
	#
	# @deprecated     Use ted::routing::reserveHwires instead.
	#
	# @deprecated This instantiates the buffer cells, which is not required, and makes it more complex.
	#              The creation of multiple cells in one call, can connecting all pins in a single call is good design.
	#
	# @param net            the net to route
	# @param hIndices       list of h indices for the h wires to route to
	# @param regions        vivado clockregion objects in which the hrow wires should be connected
	#
	# fixme: the frequent calls to route_design kill perfomance, how about addRoutingLeg (should be renamed to addLeg))
	proc routeToBufHs {net hIndices regions} {
		ted::static counter 0
		
		set grouperCell "CUSTOM_ROUTING_BUFHCE_GROUPER$counter"
		
		create_cell -reference bufh_container${counter} -black_box $grouperCell
		
		foreach site [ted::selectors::bufhce $hIndices $regions] {
			set cellname "${grouperCell}/CUSTOM_ROUTING_BUFHCE_[incr counter]"
			lappend cellnames $cellname
			lappend placementList $cellname $site
		}
		
		set cells [create_cell -reference BUFHCE $cellnames]
		set pins  [ted::addPostfix $cellnames {/I}]
		connect_net -hierarchical -net $net -objects $pins
		place_cell $placementList
		route_design -pins [get_pins $pins]
		
		set pips {}
		lappend pips [get_pips -of_objects [get_sites -of_objects $cells]]
		lappend pips [get_pips -of_objects $pips]
		
		set_property FIXED_ROUTE $pips $net
		#lock_design -level routing $grouperCell
		
		#use this to route to a lut... limit it to a pblock? maybe or combine all filter expressions
		#set site [lindex [get_sites -filter {SITE_TYPE =~ SLICE* && IS_USED == 0 && CLOCK_REGION == X0Y2}] 0]
	}
	
	##
	# Attempts to add a routing leg to a net
	#
	# Attempts to add a (fixed) route between from and to.
	# As this is mainly intended for antenna to pin (for pin to pin you might just let the router do its job)
	# overlap is on by default, as it is required for antenna to pin. For pin to pin turn it off.
	#
	# @param net           net to extend
	# @param from          route from here (node)
	# @param to            route to here (node)
	# @param fix           booelan. indicating whether the route sould be fixed. (default false)
	# @param overlap       booelan. indicating if overlap is allowed (required to be 1 if you have an antenna that you want to connect to a pin) (default true)
	# @param startWithGap  important for in tile routing.
	proc addRoutingLeg {net from to {fix false} {overlap true} {startWithGap false}} {
		set options {}
		
		if {$overlap} {
			lappend options -allow_overlap
		}
		
		if {$fix} {
			set property FIXED_ROUTE
		} else {
			set property ROUTE
		}
		
		set net [get_nets $net]
		
		#Vivado does not like fixed route nets, so we work around this by temporarily unfixing it
		set fixed_route [get_property FIXED_ROUTE $net]
		set_property IS_ROUTE_FIXED 0 $net
		
		set path [find_routing_path -from $from -to $to {*}$options]
		
		if {$path eq {}} {
			puts "WARNING"
			message routing-0 "Failed to find routing path between $from and $to (options: $options)" {CRITICAL WARNING}
		}
		
		if {$startWithGap} {
			set path [linsert $path 0 GAP]
		}
		
		puts $path
		
		set_property $property $path $net
		
		set_property FIXED_ROUTE $fixed_route $net
	}
	
	##
	# Blocks all nodes (wire segments) on tiles which are currently not in use.
	#
	# The LIOB_MONITOR* wires and global wires as well as vcc/gnd are excluded.
	#
	# @param net         net to use as a blocker (should be vcc/gnd (getNetVCC/GND))
	# @param tiles       tiles for which to block
	proc blockFreeNets {net tiles} {
		blockFreeNodes $net [get_nodes -of_objects $tiles -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR*}]
	}
	
	## same as blockFreeNets but ignores clocks,... why would we need this?
	#
	# Using GND or VCC is significantly slower than using a general net, so the usage of getLockerNet is recommended. However, sometimes other nets are moved by the router,
	# in that case using GND or VCC can solve the issue.
	#
	# @param net         net to use for blocking
	# @param tiles       tiles on which to apply the block
	proc blockFreeNetsExceptClock {net tiles} {
		#fixme: not really constrained to the clock the way we would like it
		blockFreeNodes $net [get_nodes -of_objects [filter $tiles {TILE_TYPE!~LIOB18* && TILE_TYPE!~HCLK_*}] -filter {!IS_VCC && !IS_GND && NAME!~*/LIOB_MONITOR*}]
	}
	
	##
	# Blocks all clock nodes (wire segments) on tiles which are currently not in use.
	#
	# Using GND or VCC is significantly slower than using a general net, so the usage of getLockerNet is recommended. However, sometimes other nets are moved by the router,
	# in that case using GND or VCC can solve the issue.
	#
	# @param net         net to use for blocking
	# @param tiles       tiles on which to apply the block
	proc blockFreeClockNets {net tiles} {
		if {[get_property TYPE $net] in {GROUND POWER}} {
		#GND/VCC may not have GAPs => we need to add each segment on its own, causing long runtimes
			set constraints {}
			
			foreach node [struct::set difference \
				[get_nodes -of_objects $tiles -filter {NAME=~CLK_HROW_* || NAME=~*/HCLK_* || NAME=~*/HCLK_LEAF_CLK_B_TOP*}] \
				[get_nodes -of_objects [get_nets -of_objects $tiles] -filter {NAME=~CLK_HROW_* || NAME=~*/HCLK_* || NAME=~*/HCLK_LEAF_CLK_B_TOP*}] \
			] {
				append constraints "{$node}"
			}
			
			set_property FIXED_ROUTE $constraints $net
		} else {
		#we are allowed to have GAPs => create a fast blocker with just one net addition with GAPs
			set_property FIXED_ROUTE \
			"GAP [join [struct::set difference \
				[get_nodes -of_objects $tiles -filter {NAME=~CLK_HROW_* || NAME=~*/HCLK_* || NAME=~*/HCLK_LEAF_CLK_B_TOP*}] \
				[get_nodes -of_objects [get_nets -of_objects $tiles] -filter {NAME=~CLK_HROW_* || NAME=~*/HCLK_* || NAME=~*/HCLK_LEAF_CLK_B_TOP*}] \
			] { GAP }]" \
			$net
		}
	}
	
	##
	# Blocks the free nodes of the specified nodes.
	#
	# Note: Sometimes the Vivado router overrides these blocks, there will be a warning though.
	#
	# @param net              net to use for blocking
	# @param routeSegments    list of ellements that can be assigned as FIXED_ROUTE (i.e. nodes/wires)
	proc blockFreeNodes {net nodes} {
		set freeNodes [struct::set difference \
			$nodes \
			[get_nodes -of_objects [get_nets -of_objects $nodes]] \
		]
		
		if {[get_property TYPE $net] in {GROUND POWER}} {
		#GND/VCC may not have GAPs => we need to add each segment on its own, causing long runtimes
			set_property FIXED_ROUTE [join [list "\{" [join $freeNodes "\}\{"] "\}"] {}] $net
		} else {
		#we are allowed to have GAPs => create a fast blocker with just one net addition with GAPs
			set_property FIXED_ROUTE "GAP [join $freeNodes { GAP }]" $net
		}
	}
	
	##
	# Block the UTurn wires on edges of the chip
	#
	# Works by getting the nodes of the *_TERM_INT* tiles, and filtering out GTH transceiver related nodes.
	#
	# Note
	#
	# Issue:
	#  The clearer expression [get_wires *_UTURN_*] unfortunately does not contain all uturn wires.
	#   lsearch [get_wires *_UTURN_*] T_TERM_INT_X119Y520/T_TERM_UTURN_INT_SW6E3
	#   -1
	#
	# Issue part 2:
	#  A more specific seach returns more wires (and takes longer) ...
	#   llength [get_wires *UTU*]
	#   4260
	#   llength [get_wires *T_TERM_UTURN_*]
	#   WARNING: [Vivado 12-2549] 'get_wires' without an -of_object switch is potentially runtime- and memory-intensive. Please consider supplying an -of_object switch. You can also press CTRL-C from the command prompt or click cancel in the Vivado IDE at any point to interrupt the command.
	#   get_wires: Time (s): cpu = 00:00:19 ; elapsed = 00:00:18 . Memory (MB): peak = 9158.891 ; gain = 0.000 ; free physical = 29526 ; free virtual = 76215
	#   18360
	#
	# @param net       net to use for blocking
	proc blockUTurnWires {net} {
		#blockNodes $net [get_nodes -of_objects [get_tiles -filter {TYPE=~*_TERM_INT*}] -filter {NAME!~GTH* && NAME!~*/CLK* && NAME!~*/CTRL*}]
		#blockNodes $net [get_wires */*_UTURN_* -filter {NAME!~*/BRAM_UTURN*}]
		#blockNodes $net [get_wires -regexp -filter {NAME=~.*/[LR]_TERM_INT_.*}]
		blockNodes $net [get_wires -regexp -filter {(NAME=~[^/]*/.*_UTURN_.* && NAME!~[^/]*/BRAM_.*) || NAME=~.*/[LR]_TERM_INT_.*}]
	}
	
	##
	# Quick test if the blocker insertion was respected by Vivado.
	#
	# Tests if Vivado honored the blocker, by seeing if the router generated Error messages of the form:
	# [Route 35-255] Router failed to honor FIXED_ROUTE property on net <NET>.
	#
	# Note: Works only in scripting mode, as in gui mode a sepeprocess runs theroute, and get_msg_config has no access to it,
	# while the gui gets the errormessages, TCL does not see them
	#
	# Todo: what should the semantics be? Throw, ErrorOut, or just a plain return value?
	proc blockerQuickCheck {} {
		set errorCount [get_msg_config -id "Route 35-255" -count]
		
		if {$errorCount} {
			ted::message routing-0 "FIXED_ROUTE has not been honored by router. Check for \[Route 32-255\] in Messages to see the nets which have been moved."
		}
		
		return $errorCount
	}

	##
	# Route a bus through a specific set of wires
	#
	# Note: strips everything up to the last / from nodes, as that is assuemd to be a tile name.
	#
	# fixme: how do we deal with randomly named ports? => external wire order?
	proc bus_plug {nets nodes tiles} {
		#sort nets by bus number
		set nets [lsort -dictionary $nets]
		set tiles [coordinates::sortXY $tiles]
		#strip of potential tile names of nodes
		set nodes [struct::list mapfor nodeName $nodes {string range $nodeName [expr {1+[string last / nodeName]}] end}]
		
		
		set tileIndex [expr {[llength $tiles]-1}]
		
		for {set netIndex 0} {$netIndex<[llength $nets]} {} {
			if {$tileIndex < 0} {
				error "to few tiles/nodes available for bus_plug on "
			}
			
			set tile [lindex $tiles $tileIndex]
			incr tileIndex -1
			
			foreach nodePart $nodes {
				set node [get_nodes $tile/$nodePart -quiet]
				
				if {[llength $node] == 0} {
					puts "Node $nodePart not found on $tile"
					continue
				}
				
				set net [lindex $nets $netIndex]
				incr netIndex
				
				puts "routing net $net via $node"
				
				#ted::routing::addRoutingLeg $net [get_nodes -of [get_site_pins -of [selectors::getDriver $net]]] $node false true true
				
				#foreach loadNode [get_nodes -of [get_site_pins -of [selectors::getLoads $net]]] {
				#	ted::routing::addRoutingLeg $net $node $loadNode false false false
				#}
				
				#set_property FIXED_ROUTE $node $net
				
				set routing {}
				set driver [get_nodes -of [get_site_pins -of [selectors::getDriver $net]]]
				
				foreach loadNode [get_nodes -of [get_site_pins -of [selectors::getLoads $net]]] {
					lappend routing [list $driver GAP $node GAP $loadNode]
				}
				
				set_property FIXED_ROUTE $routing $net
				
				if {$netIndex >= [llength $nets]} {
					break
				}
			}
		}
	}
	
	##
	# Route a net through a specified node.
	#
	# @param net   net to route via a specific node
	# @param node  the node to route all connections through
	#
	proc routeThrough {net node} {
		set routing {}
		set driver [get_nodes -of [get_site_pins -of [selectors::getDriver $net]]]
		
		foreach loadNode [get_nodes -of [get_site_pins -of [selectors::getLoads $net]]] {
			lappend routing [list $driver GAP $node GAP $loadNode]
		}
		
		set_property FIXED_ROUTE $routing $net
	}
	
	##
	# Create a clock with the specified frequency.
	proc addClock {frequency} {
		
	}
	
	##
	# Insert a cell into a net.
	#
	# @param pin(s)      pin(s) to which the cell should be connected
	# @param bufferType  primitive name for the cell to be inserted
	# @param inPin       name of input pin to use on the cell
	# @param outPin      name of output pin to use on the cell
	#
	# @return            cell object inserted
	proc insertBuffer {pin bufferType inPin outPin} {
		set bufferedNet [get_nets -of_objects $pin]
		
		if {[llength bufferNet]!=1} {
			errorMsg ROUTING-0 "Buffer insertion requires exactly one net into which to insert the buffer. Found [llength bufferNet] nets for the supplied pins. (Pins: $pin)"
		}
		
		set name [get_nets -of_objects $pin]
		set cell [createCellUnique $name $bufferType]
		set net  [createnetUnique  $name]
		
		disconnect_net -pinlist $pin
		
		switch [get_property DIRECTION $pin] {
			IN {
				connect_net -net_object_list [list $bufferedNet [get_pins $cell/$inPin]  $net [list [get_pins $cell/$outPin] {*}$pin]]
			}
			OUT {
				connect_net -net_object_list [list $bufferedNet [get_pins $cell/$outPin] $net [list [get_pins $cell/$inPin]  {*}$pin]]
			}
			default {
				errorOut ROUTING-0 "Pin direction must be either IN or OUT for insertion. Ambiguous pin direction or a mix of pin directions is not possible."
			}
		}
		
		return $cell
	}
	
	proc duplicateRouteRelative {wires offset acceptableTiles} {
		
	}
	
	proc relocateCell {cell offset} {
		
	}
	
	proc copyCell {cell } {
		
	}
	
	proc wireCells {cellA cellB {unwire true}} {
		foreach cell [list $cellA $cellB] {
			ted::scopeCode {
				#get_nets -boundary_type upper -of_objects [get_ports -scoped_to_current_instance]
				lappend ports [list [sortByName [get_ports -scoped_to_current_instance]]]
				#disconnect_nets -objects [list [get_ports -scoped_to_current_instance]]
				if {$unwire} {
					#disconnect_nets -objects [list [lindex $ports end]]
				}
			} $cell
		}
		
		set numPortsCellA [llength [lindex $ports 0]]
		
		if {$numPortsCellA != [llength [lindex $ports 1]]} {
			errorOut ROUTING-0 "Can not connect $cellA to $cellB, ports numbers mismatch ($numPortsCellA vs [llength [lindex $ports 1]])"
		}
		
		set i 0
		
		while {1} {
			#need two lindex expression, as otherwise an attempt to convert the vivado collection to a string is made.
			set buswidth [either [get_property BUS_WIDTH [lindex [lindex $ports 0] $i]] 1]
			set nets [createNetUnique NAMENAMENAMENAME $buswidth]
			
			for {set j 0} {$j < $buswidth} {incr j} {
				lappend connectionList [list NET [list PORTS]]
			}
			
			if {$i == $numPortsCellA} {
				break
			}
		}
		
		connect_net -net_object_list $connectionList
		
		return $ports
	}
	
	proc getNetDirection {net pblock} {
		return [llength [filter [get_pblocks $pblock] "NAME==\"[get_property PBLOCK [ted::selectors::getDriver $net]]\""]]
	}
	
	# tile right of cut is also used as the bottom for the plug.
	proc createPlugWire {net wire tileRightOfCut direction frequency} {
		set yInvert 499
		
		set upperBound 500
		set lowerBound 0
		
		set driver [ted::selectors::getDriver $net]
		set driverNode [get_nodes -of [get_site_pins -of $driver]]
		set driverTile [get_tiles -of $driverNode]
		#set x [get_property INT_TILE_X $driverTile]
		#set y [get_property INT_TILE_Y $driverTile]
		
		set y [lindex [regexp -inline {X\d*Y(\d*)/} $wire] 1]
		set x [lindex [regexp -inline {X(\d*)Y\d*/} $wire] 1]
		
		set y [expr {$y+$yInvert-[get_property INT_TILE_Y $tileRightOfCut]}]
		
		set wireNameEnd [lindex [split $wire / ] end]
		
		#tile right of cut turns into tile closest to the cut on the correct side of the cut
		if {$direction == 1} {
			#set tileRightOfCut [$tileRightOfCut-1]
			#FIXME: this breaks if tile 0 is defined as border
			set tileRightOfCut [get_tiles -regexp -filter "INT_TILE_X==[expr {[get_property INT_TILE_X $tileRightOfCut]-1}] && INT_TILE_Y==[get_property INT_TILE_Y $tileRightOfCut] && TILE_TYPE=~{INT_\[LR\]}"]
		}
		
		
		set shift [expr {([get_property INT_TILE_X $tileRightOfCut]-$x)/$frequency}]
		
		if {$direction == 1} {
			set shift [::tcl::mathfunc::int [::tcl::mathfunc::floor $shift]]
		} else {
			set shift [::tcl::mathfunc::int [::tcl::mathfunc::ceil $shift]]
		}
		
		set pos [expr {$shift*$frequency + $x}]
		
		#turn wires around if out of bound
		#TODO: actually turn around wires
		if {$pos < $lowerBound} {
			
		}
		
		#get the tile and the wire on the tile
		set viaNode [get_nodes -of [get_tiles -regexp -filter "INT_TILE_Y==[expr {$yInvert-$y}] && INT_TILE_X==$pos && TILE_TYPE=~{INT_\[LR\]}"] -filter "NAME=~*_X${pos}Y$y/$wireNameEnd"]
		#set constraint for ALL loads
		
		#for slice clocks we get the same pin several times, but it does not work for clocks, so we filter with lsort to ensure unique loads
		set loads [lsort -unique [get_nodes -of [get_site_pins -of [ted::selectors::getLoads $net]]]]
		set routePath "$driverNode GAP $viaNode "
		puts $viaNode
			
		foreach load [lrange $loads 0 end-1] {
			lappend routePath "GAP $load"
		}
		set routePath "$routePath GAP [lindex $loads end]"
		
		set_property ROUTE $routePath $net
	}
	
	#
	# set wireassinment [list
	#	dict net netname wire wirename direction dir start busstart stop busend frequency freq
	# ]
	#
	# direction: 1: increase tile index, -1 decreas tile index 
	#
	proc createPlug {prefix wireassignment tileRightOfCut} {
		foreach assignment $wireassignment {
			if {[dict exists $assignment start]} {
				#multiplewires
				set net       [dict get $assignment net]
				set wire      [dict get $assignment wire]
				set start     [dict get $assignment start]
				set direction [dict get $assignment direction]
				
				#todo allow for list of frequencies, or replicate frequency if it is single
				set frequency [dict get $assignment frequency]
				
				for {set i $start} {$i <= [dict get $assignment stop]} {incr i} {
					set descriptorIndex [expr {$i-$start}]
					createPlugWire [get_nets "$prefix$net\[$i\]"] [lindex $wire $descriptorIndex] $tileRightOfCut $direction [lindex $frequency $descriptorIndex]
				}
			} else {
				#singlewire
				createPlugWire [get_nets "$prefix[dict get $assignment net]"] [dict get $assignment wire] $tileRightOfCut [dict get $assignment direction] [dict get $assignment frequency]
			}
		}
	}
	
	package require struct::set
	proc getUsedNodesOfTiles {tiles {allowedNodes {}}} {
		return [struct::set::Intersect [get_nodes -of_objects $tiles] [struct::set difference [get_nodes -of_objects [get_nets -of_objects $tiles]] $allowedNodes]]
	}
	
	proc pblockUsedNodes {pblock {allowedNodes {}}} {
		return [getUsedNodesOfTiles [ted::rect::getTiles [ted::rect::boundingBox [ted::rect::ofPblock $pblock]]]]
	}
}