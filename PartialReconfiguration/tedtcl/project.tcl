package require report
package require struct::matrix

##
# Helper functions for building a project
namespace eval ::ted::project {
	##
	# Add XDC files
	#
	# @param xdcs          list of xdc dicts
	proc addXDC {xdcs} {
		foreach xdc $xdcs {
			read_xdc [dict get $xdc file]
		}
	}
	
	##
	# Add blockdesigns.
	#
	# blockdesign dict format:
	#    bd             blockdesign file
	#    tcl            tcl script to generate blockdesign (generate i by exporitng the blockdesign)
	#    top            is this bd a top
	#    wrapper        name of the wrapper to
	#
	# @param bds           list of blockdesign dicts
	proc addBDs {bds} {
		set bdList {}
		
		foreach bd $bds {
			set bdfile [dict get $bd bd]
		
			#generate bd from tcl if required
			if {[dict exists $bd tcl]} {
				source [dict get $bd tcl]
			}
			
			lappend bdList $bdfile
			
			if {[::ted::utility::get_setting $bd createWrapper]} {
				set paramList {}
				
				if {[::ted::utility::get_setting $bd top]} {
					lappend paramList -top
				} else {
					error "Unsupported: Create wrapper is enabled but top is false for $bdfile" 
				}
				
				make_wrapper -force -files [get_files $bdfile] {*}$paramList
				add_files -norecurse .srcs/sources_1/bd/BaseSystem/hdl/BaseSystem_wrapper.v
			} else {
				add_files $bdfile
			}
		}
		
		if {[llength $bdList]} {
			generate_target -force {synthesis implementation} [get_files $bdList]
		}
	}

	##
	# Add IP repositories to project.
	#
	# @param iprepos           list of IP repository paths
	proc addIPrepos {iprepos} {
		set_property IP_REPO_PATHS [concat $iprepos [get_property IP_REPO_PATHS [current_fileset]]] [current_fileset]
		update_ip_catalog
	}
	
	##
	# Add IPs to project
	#
	# Ip dict format:
	#    ip           path to xci file of ip
	#
	# @param ips            list of ip dicts
	proc addIPs {ips} {
		set ipList {}
	
		foreach ip $ips {
			lappend ipList [dict get $ip ip]
		}
		
		if {$ipList ne {}} {
			add_files $ipList
			generate_target -force {synthesis implementation} $ipList
		}
	}
	
	##
	# Add systemverilog files to project.
	#
	# @param sv               list of systemverilog file paths
	proc addSystemVerilog {sv} {
		if {$sv ne {}} {
			add_files $sv
			set_property FILE_TYPE SystemVerilog [get_files $sv]
		}
	}
	
	##
	# Add verilog files to project.
	#
	# @param v               list of verilog file paths
	proc addVerilog {v} {
		if {$v ne {}} {
			add_files $v
			set_property FILE_TYPE Verilog [get_files $v]
		}
	}

	##
	# Build a project from a sources dict.
	#
	# This calls the different add methods for the following entries in the sources dict:
	#
	#   bd                     addBDs
	#   ip                     addIPs
	#   ipRepos                addIPrepos
	#   sv                     addSystemVerilog
	#   v                      addVerilog
	#   xdc                    addXDC
	#
	#  See the according add* methods to see how to format the different entries
	#
	# @param sources                 sources dict, see description
	# @param part                    fpga part
	# @param name                    project name (defaul builder_project)
	# @param path                    path to write project data to (default {})
	# @param inMemory                create an in memory project? boolean (default true)
	# @param boardPart               the board being used, relevant if using board ip (default {})
	#fixme should be in memory an optional -in_memory flag?
	proc makeProject {sources part {name "builder_project"} {path "."} {inMemory true} {boardPart {}}} {
		if { $inMemory } {
			create_project -in_memory -force -part $part $name $path
		} else {
			create_project  -force -part $part $name $path
		}
		
		set project [current_project]
		#enable source managment
		set_property source_mgmt_mode All $project
		
		#Todo: should we add PATH_MODE RelativeOnly

		if {$boardPart ne {}} {
			set_property "board_part" $boardPart $project
		}
		
		addIPrepos       [dict get $sources ipRepos]
		addSystemVerilog [dict get $sources sv]
		addVerilog       [dict get $sources v]
		addIPs           [dict get $sources ip]
		
		#update_compile_order
		
		addBDs           [dict get $sources bd]
		addXDC           [dict get $sources xdc]
	}
	
	##
	# \internal
	# Runs an implementation step
	#
	# Sources the sources \<step\>.pre scripts (can be scoped, see ted::utility::runScripts),
	# runs the command with flags, sources the the sources \<step\>.post scripts (scopeable again)
	# and writes a checkpoint.
	#
	# Updates the sources dict (therefore pass by reference) with timing information
	#
	# @param step           step name in sources dict
	# @param command        vivado command
	# @param sourcesReg     name of sources dict, see ted::project::build documentation for information (not the value, as we access it with upvar)
	# @param index          index to prefix to the checkpoint file name (default 0)
	# @param checkpointDir  directory into which checkpoints are written (default .)
	# @param prefix         checkpoint file prefix (default {})
	# @param digits         nr of digits to use for writing the checkpoint (default 2)
	# @param postfix        postfix for the checkpoint file name (default {})
	#
	proc _step {step command sourcesRef {index 0} {checkpointDir .} {prefix {}} {digits 2} {postfix {}}} {
		upvar $sourcesRef sources
		::ted::utility::static lastSave 0
		
		if {[::ted::utility::get_setting $sources $step.run 1]} {
			set start [clock seconds]
			::ted::utility::runScripts  [::ted::utility::get_setting $sources $step.pre   {}]
			$command {*}[::ted::utility::get_setting $sources $step.flags {}]
			::ted::utility::runScripts  [::ted::utility::get_setting $sources $step.post  {}]
			dict set sources timing current ${prefix}[format %0${digits}d $index]_$step${postfix} [expr {[clock seconds] - $start}]
			puts "$step took [dict get $sources timing current ${prefix}[format %0${digits}d $index]_$step${postfix}] seconds"
			
			set checkpointGlobal [::ted::utility::get_setting $sources checkpoints      on]
			set checkpointStep   [::ted::utility::get_setting $sources $step.checkpoint -]
			
			if {
				$checkpointGlobal eq {on!} ||
				(
					$checkpointGlobal ne {off!} &&
					(
						$checkpointStep in {on on!} ||
						(
							$checkpointStep eq {-} &&
							$checkpointGlobal ne {off}
						)
					)
				)
			} {
				#Write the checkpoint:
				#  always
				#    if it is localy explicitly enabled (on! @ step.checkpoint)
				#    if the global setting is one of the non integer enum values (on on! off of!)
				#  after the interval elapsed
				#    in all other cases
				if {
					$checkpointStep   eq {on!}            ||
					$checkpointGlobal in {off of! on on!} ||
					[ted::parseInt $checkpointGlobal] <= [expr {[clock seconds] - $lastSave}]
				} {
					write_checkpoint -force [file join $checkpointDir "${prefix}[format %0${digits}d $index]_${step}${postfix}.dcp"]
					set lastSave [clock seconds]
				}
			}
		}
	}
	
	##
	# Run a standard build
	#
	# Runs a standard build consisting of the following steps:
	#   synth            synth_design
	#   opt              opt_design
	#   place            place_design
	#   postPlaceOpt     phys_opt_design
	#   route            route_design
	#   postRouteOpt     phys_opt_design
	#   bitstream        write_bitstream
	#
	# Every step can be skipped by specifing \<stepname\>.run 0 in the sources dict.
	# Furthermore scripts can be sourced for steps by specifying a list of script dicts in
	# the sources dict with the key \<stepname\>.pre or \<stepname\>.post to run the scripts before
	# or after the respective step.
	#
	# postPlaceOpt and postRouteOpt can be run repeatedly, to set the number of operations use the key \<stepname\>.iterations.
	# Set it to -1 to run until timing is met or no further improvements are made.
	# \<stepname\>.optimizeMore is a boolean indicating if optimization should be continued after timing is already met.
	# \<stepname\>.log is used to specify the temporary logfile which is used by tedtcl to parse the output of the step. This way we don't need to waste time on
	# running report_*.
	#
	# See ted::utility::runScripts for a description of the script dict.
	#
	# Checkpoints are written to the checkpoint dir, which is specified in the sources dict under
	# checkpointDir and defaults to Checkpoints.
	#
	# The Bitstreamdir can be specified by using the bitstreamDir key of the sources dict,
	# it defaults to bitstreams
	#
	# Adds information about how long each step took to the sources dict under the timing key.
	# To retrieve this querry dict get $sources timing current <stepname>
	#
	# Hint: `tail -f vivado.log | grep seconds` gives a good overview about which step took how long during he process,
	# A nicely formatted overview is printed to the console after completion.
	#
	# list of configuration options:
	#
	# option                | note
	# ----------------------|-----
	# <stepname>.run        | boolean: execute the step
	# <stepname>.pre        | list of scripts to run before the step
	# <stepname>.post       | list of scripts to run after the step
	# <stepname>.checkpoint | save a checkpoint/don't save a checkpoint (- for use global setting) (on|off|on!|off!|-). The exclarmation mark variants can be used to ignore the global timer.
	# checkpoints           | on!|on|off|off!|<integer> controls checkpoint writing on a global level, integer does not write a checkpoint unless last checkpoint is longer than X seconds ago, off!/on! overwrites <stepname>.checkpoint settings. Exclamation mark variant takes precedent over step settings (undefined interpreted as on)
	#
	# @param sourcesRef            name of sources dict see above (pass by reference)
	# @param buildDir              prepends a directory before the (hopefully relative) checkpoint/bitstream directories specified in sources. (default {})
	proc build {sourcesRef {buildDir {}}} {
		set start [clock seconds]
		
		upvar $sourcesRef sources
		
		#do the directives brake out custom passed flags? (should we ommit the directives?)
		
		#save current timing
		if {[dict exists $sources timing current]} {
			dict set sources timing last [dict merge [dict get $sources timing last] [dict get $sources timing current]]
		}
		
		dict set sources timing [dict create current [dict create]]
		
		set checkpointDir [file join $buildDir [::ted::utility::get_setting $sources checkpointDir Checkpoints]]
		set bitstreamDir  [file join $buildDir [::ted::utility::get_setting $sources bitstreamDir bitstreams]]
		set i -1
		set digits 2
		
		file mkdir $checkpointDir
		file mkdir $bitstreamDir

		try {
			#should we: -flatten_hierarchy full
			_step synth synth_design sources [incr i] $checkpointDir
	
			#the following should be default enabled: -retarget -propconst -sweep -bufg_opt -shift_register_opt -bram_power_opt
			#seems to be for routability: -muxf_remap -carry_remap
			#test? -resynth_seq_area
			#either different options or retarget
			_step opt opt_design sources [incr i] $checkpointDir
			if {![::ted::utility::get_setting $sources opt.run 1] && [::ted::utility::get_setting $sources synth.run 1]} {
				puts "WARNING: running synthesis requires optimizations for further steps. Stopping now. To run further steps enable optimization"
				#reasoning: got unroutable nets when not running opt_design
				return
			}
			
				#power_opt_design
				#write_checkpoint -force [file join $pathPrefix $checkpointDir "02_post_synthesis_power_opt.dcp"]
				
			#alternative directive ExtraTimingOpt ExtraPostPlacementOpt
			#could run -post_place_opt at any point after placement, but needs rerouting of the nets of affected cells
			#place_design -directive Explore -fanout_opt -timing_summary
			_step place place_design sources [incr i] $checkpointDir
			
				#power_opt_design
				#write_checkpoint -force [file join $pathPrefix $checkpointDir "04_post_place_power_opt.dcp"]
		
			#_step postPlaceOpt phys_opt_design $sources [incr $i] $checkpointDir
			incr i
			if {[::ted::utility::get_setting $sources postPlaceOpt.run 1]} {
				iterateOpt [::ted::utility::get_setting $sources postPlaceOpt.iterations 1] sources postPlaceOpt $buildDir [::ted::utility::get_setting $sources postPlaceOpt.optimizeMore 0] [::ted::utility::get_setting $sources postPlaceOpt.log _phys_opt_log.txt] [format %0${digits}d $i]_
			}
			_step route        route_design    sources [incr i] $checkpointDir
			#_step postRouteOpt phys_opt_design $sources [incr $i] $checkpointDir
			incr i
			if {[::ted::utility::get_setting $sources postRouteOpt.run 1]} {
				iterateOpt [::ted::utility::get_setting $sources postRouteOpt.iterations 1] sources postRouteOpt $buildDir [::ted::utility::get_setting $sources postRouteOpt.optimizeMore 0] [::ted::utility::get_setting $sources postRouteOpt.log _phys_opt_log.txt] [format %0${digits}d $i]_
			}
			
			#we can run multiple iterations here
			#could add another round of place_design -post_place_opt => phys_opt_design => route_design #apparently particularly effective on a routed design
			
			if {[::ted::utility::get_setting $sources bitstream.run 1]} {
				#use the builddir in the bitstream dir path
				set sourcesCopy [dict merge $sources]
				
				set flags [::ted::utility::get_setting $sources bitstream.flags {}]
				lappend flags [file join $bitstreamDir [::ted::utility::get_setting $sources bitstreamFile Bitstream.bit]]
				#always write the bitstream
				lappend flags -force
				
				dict set sourcesCopy bitstream.flags $flags
				
				set_property BITSTREAM.GENERAL.CRC DISABLE [current_design]
				_step bitstream    write_bitstream sourcesCopy [incr i] $checkpointDir
			}
			
			#could use interactive phys opt design, to transfer physical optimizations to a pre placement netlist
			#check out directives and co for phys_opt and route
		} finally {
			set stepTotalTime 0
			
			dict for {key value} [dict get $sources timing current] {
				set stepTotalTime [expr {$stepTotalTime + $value}]
			}
			
			dict set sources timing current {Sum of steps} $stepTotalTime
			dict set sources timing current Total [expr {[clock seconds] - $start}]
			
			report_build_timings sources
		}
	}
	
	##
	# Iterativly run build.
	#
	# @param sourcesRef        reference to sources array to pass to ted::project::build
	# @param adjust            function to adjust, should return true if no further iterations should be taken, false otherwise
	# @param iterationLimit    limit the number of iterations, -1 for no limit (default -1)
	# @param buildDir          build directory to pass to ted::project::build
	proc iterate {sourcesRef adjust {iterationLimit -1} {buildDir {}}} {
		upvar $sourcesRef sources
		
		#!= allows for negative numbers to implement no iteration limit
		for {set i 0} {$i != $iterationLimit} {incr i} {
			uplevel 1 $prebuild
			build $sources $buildDir
			if {[uplevel 1 $adjust]} {
				break
			}
		}
	}
	
	##
	# Iterativly call phys_opt_design
	#
	# @param maxIterations      limit the maximum number of iterations (default: -1)
	# @param sourcesRef         name of sources dict (see ted::project::build), pass by referenece (name in calling namespace) (default {})
	# @param stepname           stepname passed to _step (prepended with Iter, after the first call)
	# @param buildDir           directory to use for building /prefix to relative path (last parameter) (default {})
	# @param optimizeMore       continue optimizing after the design meets timing (default: false)
	# @param path               path for the tempfile used to write the logs to (default _phys_opt_log.txt)
	# @param prefix             prepend this prefix to the checkpoints
	# fixme: optimizeMore is currently ignored by the tool, should we tighten constraints optimize more and relax after?
	proc iterateOpt {{maxIterations -1} {sourcesRef {}} {stepname phys_opt_iterative} {buildDir {}} {optimizeMore false} {path _phys_opt_log.txt} {prefix {}}} {
		if {$sourcesRef eq {}} {
			set sources [dict create]
		} else {
			upvar $sourcesRef sources
		}
		
		set checkpointDir [file join $buildDir [::ted::utility::get_setting $sources checkpointDir Checkpoints]]
		set i -1
		set iterations 0
		
		file mkdir $checkpointDir
		
		if {[file pathtype $path] == {relative}} {
			set $path [file join $buildDir $path]
		}
		
		if {$maxIterations} {
			#redirect output to file
			dict lappend sources ${stepname}.flags     > $path
			dict lappend sources ${stepname}Iter.flags > $path
			
			::ted::utility::run {
				_step $stepname phys_opt_design sources [incr i] $checkpointDir $prefix
			} finally {
				#parse in file to get command output for parsing
				set data [fileutil::cat $path]
				#make sure the data appears in the vivado log
				puts $data
			}
			
			if {[string first {Estimated Timing Summary} $data]!=-1} {
				puts "Running iterative in post placement mode"
				set timingString {INFO: [Physopt 32-619] Estimated Timing Summary | }
			} else {
				puts "Running iterative in post route mode"
				set timingString {INFO: [Physopt 32-668] Current Timing Summary | }
			}
			
			#check if timing is already closed, in that case we wont get a timing string to parse.
			if {[parser::has {INFO: [Vivado_Tcl 4-383] Design worst setup slack (WNS) is greater than or equal to 0.000 ns. Skipping all physical synthesis optimizations.} $data]} {
				#todo activly force this by overconstraining if optimize more is specified?
				puts "Timing already met, optimizations will be skipped"
				return
			}
			
			set initialTiming [parser::timingSummary [parser::first $timingString $data]]
			set lastTiming $initialTiming
			#INFO: [Physopt 32-669] Post Physical Optimization Timing Summary | 
			#INFO: [Physopt 32-603] Post Physical Optimization Timing Summary | 
			set currentTiming [parser::timingSummary [parser::last  {] Post Physical Optimization Timing Summary | } $data]]
			
			#iterationLimit, do we meet timing, were there optimizations
			#in some cases there are other messages for optimizations, so we look at the timing changes as well
			#example of a different optimization message: Critial path length was reduced through logic transformation
			while {
				[incr iterations] != $maxIterations && 
				($optimizeMore || ![parser::meetsTiming $currentTiming]) && 
				(
					[string first {Optimization improves timing on the net} $data] != -1 ||
					[parser::closerToMeetTiming $lastTiming $currentTiming]
				)
			} {
				::ted::utility::run {
					_step ${stepname}Iter phys_opt_design sources [incr i] $checkpointDir $prefix
				} finally {
					set data [fileutil::cat $path]
					#make sure the data appears in the vivado log
					puts $data
					set lastTiming $currentTiming
					set currentTiming [parser::timingSummary [parser::last  {] Post Physical Optimization Timing Summary | } $data]]
				}
			}
			
			puts "Timing before optimizations: $initialTiming"
			puts "Timing after  optimizations: $currentTiming"
		}
		
		puts "Ran $iterations phys opt steps."
	}
	
	##
	# Print a summary of the build timings
	#
	# @param sourcesRef           reference to the sources dict
	proc report_build_timings {sourcesRef} {
		upvar $sourcesRef sources
		
		proc timeFormat {seconds} {
			return "[expr {$seconds/3600}][clock format $seconds -format ":%M:%S" -gmt true]"
		}
		
		struct::matrix table
		table add columns 2
		
		::report::report tableFormat [table columns] style report_captionedTable
		
		try {
			table add row [list step time]
		
		
			dict for {key value} [dict get $sources timing current] {
				table add row [list $key [timeFormat $value]]
			}
		
			table format 2chan tableFormat
		} finally {
			tableFormat destroy
			table destroy
		}
	}
	
	
}