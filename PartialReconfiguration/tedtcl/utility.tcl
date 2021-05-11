package require struct::list
package require report
#the outdated struct stack (1.3.3) in vivado generates errors if loaded multiple times, ugly but works
catch {package require struct::stack}
package require textutil
#get tcl 8.6's try finally for tcl 8.5
package require try
package require throw

namespace eval ::ted::utility {
	
	##
	# Start a new undo group and close a previous undo group if it exists.
	#
	proc newGroup {} {
		if {![startgroup -try]} {
			endgroup
			startgroup
		}
	}
	##
	# Namespace to hold static variables.
	#namespace eval ::ted::static {}
	
	##
	# Declare C-Style static variables
	#
	# adapted from http://wiki.tcl.tk/ RS 2005-05-11
	# possibly should add array support (see above site)
	# allows to declare c-style static variables (keep value across function calls)
	#
	# param name          name of the static variable
	# param value         initial value of the static variable
	#
	proc static {name {value ""}} {
		set procName [namespace tail [lindex [info level -1] 0]]
		set ns       [string trim [uplevel 1 {namespace current}] :]
		
		set caller ${ns}::${procName}
		
		## \internal Namespace insisde static created for each function that has static variables
		namespace eval ::ted::static::$caller {}
		
		set qualifiedName ::ted::static::${caller}::$name
		
		if {![info exists $qualifiedName]} {
			set $qualifiedName $value
		}

		uplevel 1 [list upvar #0 $qualifiedName $name]
	}
	
	##
	# Reset all static variables
	proc _resetAllStaticVariables {} {
		if {[namespace exists ::ted::static]} {
			#::ted::utility::message 0 {Wiping ALL global static variables due to reload.} WARNING
			namespace delete ::ted::static
		}
	}
	
	##
	# Declare C-Style static variables per project.
	#
	# adapted from http://wiki.tcl.tk/ RS 2005-05-11
	# possibly should add array support (see above site)
	# allows to declare c-style static variables (keep value across function calls)
	#
	# param name          name of the static variable
	# param value         initial value of the static variable
	#
	proc staticProject {name {value ""}} {
		set procName [namespace tail [lindex [info level -1] 0]]
		set ns       [string trimright [uplevel 1 {namespace current}] :]
		
		set caller          ${ns}::${procName}
		set qualifiedPrefix ::ted::_internal::_static::[get_property ID [current_project]]::${caller}
		
		## \internal Namespace insisde static created for each function that has static variables
		namespace eval ${qualifiedPrefix} {}
		
		set qualifiedName ${qualifiedPrefix}::${name}
		
		if {![info exists $qualifiedName]} {
			set $qualifiedName $value
		}

		uplevel 1 [list upvar #0 $qualifiedName $name]
	}
	
	##
	# Safely extract a value from a dictionary, in case it is not found return default (defaults to 0).
	#
	# @param dictionary           name of the dictionary
	# @param key                  key to access
	# @param default              default to return in case the key is not found in the dictionary, defaults to 0
	#
	# @return                     the value of key in dictionary if it exists, otherwise the default value is returned
	#
	proc get_setting {dictionary key {default 0}} {
		if {[dict exists $dictionary $key]} {
			return [dict get $dictionary $key]
		}
		
		return $default
	}
	
	##
	# Return a default, if the value represents an unaccepted value
	#
	# Use case example: `largestSuffix [get_nets MYFILTER*] MYFILTER` is expected to return an
	# integer, however in case no nets are found it might return an empty result {}, this can be
	# changed to a number by this
	#
	# @param value       value to check
	# @param default     default fallback if value is not accepted
	# @param unaccepted  list of unaccepted value
	#
	# @return            value unless value is an element of the unacepted list, in which case default is returned
	proc either {value {default 0} {unaccepted {{} none null}}} {
		if {$value in $unaccepted} {
			return $default
		}
		
		return $value
	}
	
	##
	# Strip prefix from a list of items
	#
	# Note: Works by removing the first [string length $prefix] characters from every item.
	#       => User has to ensure that all items actually have the prefix
	#
	# @param items          list of items
	# @param prefix         prefix to strip
	#
	# @return               list of items with prefix removed.
	proc getSuffices {items prefix} {
		set start [string length $prefix]
		
		return [::struct::list mapfor item $items {
			string range $item $start end
		}]
	}
	
	##
	# Add file and line number information to an error message.
	#
	# Includes file, linenumber and procedure from where formatError was called.
	#
	# @param message       message to format
	# @param indent        string to use to indent the message (default {  })
	# @param severity      severity of the report (default ERROR)
	#
	# @return              the formated string
	proc formatError {message {indent {  }} {severity ERROR}} {
		set location [info frame -1]
		return "$severity in [::ted::utility::get_setting $location proc {<Code on top level>}] ([::ted::utility::get_setting $location file [dict get $location type]] on line [dict get $location line]):\n[::textutil::indent $message $indent]"
	}
	
	##
	# Print a message to console and Vivados message pane.
	#
	# @param errorNo        error number, should be unique (or uniquely identifying a condition) within the calling namespace
	# @param message        message to print
	# @param severity       severity of the message (one of: ERROR {CRITICAL WARNING} WARNING INFO STATUS)
	# @param indent         how much to indent the message
	proc message {errorNo message {severity INFO} {indent {  }}} {
		set message [uplevel 1 "::ted::utility::formatError {$message} {$indent} {$severity}"]
		send_msg_id TEDTCL.[uplevel 1 {namespace current}]-$errorNo $severity $message
		#FIXME test when we need to use puts here
		#puts $message
	}
	
	##
	# Print an error message to console and Vivados message pane, stop execution after.
	#
	# @param errorNo        error number, should be unique (or uniquely identifying a condition) within the calling namespace
	# @param message        message to print
	# @param indent         how much to indent the message
	proc errorOut {errorNo message {indent {  }}} {
		set message [uplevel 1 "::ted::utility::formatError {$message} {$indent}"]
		send_msg_id TEDTCL.[uplevel 1 {namespace current}]-$errorNo ERROR $message
		error $message
	}
	
	##
	# Generates a list of numbers spanning the range.
	#
	# Generates the range [$start, $end), and takes step width steps.
	# If end is left empty, the range is [0, $start)
	#
	# @param start            start of the range
	# @param end              end of the range (not included)
	# @param step             step size
	#
	# @return                 list of numbers in the range
	proc range {start {end {}} {step {}}} {
		if {![string is integer -strict $start]} {
			::ted::utility::errorOut 0 "Start should be given as integer"
		}
		
		if {$end == {}} {
			set end   $start
			set start 0
		} else {
			if {![string is integer -strict $start]} {
				::ted::utility::errorOut 0 "End should be given as integer"
			}
		}
		
		if {$step == {}} {
			if {$start > $end} {
				set step -1
			} else {
				set step 1
			}
		}
		
		if {$step == 0 || ![string is integer -strict $step]} {
			::ted::utility::errorOut 0 "Step must be an integer other than 0"
		}
		
		if { $start != $end && (($step>0 && $start>$end) || ($step<0 && $start<$end)) } {
			::ted::utility::errorOut 0 "The sign of Range and Step must be equal"
		}
		
		set numberRange {}
		
		if {$step > 0} {
			for {} {$start < $end} {incr start $step} {
				lappend numberRange $start
			}
		} else {
			for {} {$start > $end} {incr start $step} {
				lappend numberRange $start
			}
		}
		
		return $numberRange
	}
	
	##
	# Extract an integer from a string starting with a number.
	#
	# Converts a number (possibly floating point, with leading sign and exponent) to an integer.
	# Returns 0 on failure, number has to be at start of string. If the string does not start with a number it
	# is considered as failure. Base specifiers (i.e. 0x 0b) are NOT supported.
	#
	# @param value               string to parse for a number
	#
	# @return     integer representation of the value
	proc parseInt {value} {
		if {[regexp {^[+-]?(?:[0-9]*\.[0-9]+|[0-9]+\.?)(?:[eE][+-]?(?:[0-9]*\.[0-9]+|[0-9]+\.?))?} $value number]} {
			return [expr {entier($number)}]
		}
		
		return 0
	}
	
	##
	# Execute code scoped to cells or refs.
	#
	# Executes a script as if the specified cells or refs are top.
	# Simulates the vivado behaviour for scoped execution.
	# If both cells and ref are supplied the script is applied to all cells inside each instance of ref.
	#
	# Note: the script is executed once for every cell that should be top
	#
	# @param code                      the code to exute
	# @param cells                     cells which to set as top when sourcing the script
	# @param ref                       reference scope (select all instances of a module)
	# @param includeParameterization   boolean. include parameterized instances for ref cells (default false)
	# @param executeAtRootLevel        boolean indicating at which tcl level the code shall be executed, 
	#                                  if true it is equivalent to typing it in the commandline, 
	#                                  otherwise the code is executed in the scope where scope code is called. default false
	#
	# @return                          return value of last code execution
	# fixme: rewrite ref handling? atleast the include parametrization part is easier with vivado property ORIG_REF_NAME
	#fixme add quiet option as a -quiet position independent
	proc scopeCode {code {cells {}} {ref {}} {includeParameterization true} {executeAtRootLevel false}} {
		set initialScope [current_instance . -quiet]
		
		if {$executeAtRootLevel} {
			set level #0
		} else {
			set level 1
		}
	
		if {$ref == {}} {
			if {$cells == {}} {
				set cellScope [list .]
			} else {
				set cellScope $cells
			}
		} else {
			if {$cells == {}} {
				set cellScope [::ted::selectors::cellsOfModule $ref $includeParameterization]
			} else {
				set cellScope {}
				
				foreach base [::ted::selectors::cellsOfModule $ref $includeParameterization] {
					current_instance
					current_instance base
					lappend cellScope [get_cells $cells]
				}
			}
		}
			
		foreach instance $cellScope {
			#change to top first and then back down again, since the paths are given as absolute but interpreted relative
			current_instance -quiet
			current_instance $instance
			
			puts "executing code for cell $instance"
			
			if {[catch [list uplevel $level $code] result errorData]} {
				#restore scope
				current_instance -quiet
				current_instance $initialScope
				
				#this crashes and prevents the stacktrace
				#::ted::utility::message 1 "An error occured while executing the code. (tcl errorcode [dict get $errorData -code])" ERROR
				
				#print the stack trace
				if {[dict exists $errorData -errorinfo]} {
					puts [dict get $errorData -errorinfo]
				} else {
					puts "Failed to find a stacktrace."
				}
				
				#rethrow
				return -options $errorData $result
			}
			
			puts "code completed"
		}
		
		current_instance -quiet
		current_instance $initialScope
		
		return $result
	}
	
	##
	# Source a script scoped to cells or refs.
	#
	# Executes a script as if the specified cells or refs are top.
	# Simulates the vivado behaviour for scoped execution.
	# If both cells and ref are supplied the script is applied to all cells inside each instance of ref.
	#
	# Note: the script is executed once for every cell that should be top
	#
	# @param script                    the script to source
	# @param ref                       reference scope (select all instances of a module)
	# @param cells                     cells which to set as top when sourcing the script
	# @param includeParameterization   boolean. include parameterized instances for ref cells (default true)
	proc sourceScript {script {cells {}} {ref {}} {includeParameterization true}} {
		::ted::utility::scopeCode "puts \"Executing script $script\"; source $script; puts \"Script $script completed\";" $cells $ref $includeParameterization true
	}
	
	##
	# Execute code on the top level in the design hierarchy.
	#
	# @param code          code to execute
	proc toplevel {code} {
		set oldTop [current_instance . -quiet]
		current_instance
		try {
			uplevel 1 $code
		} finally {
			current_instance $oldTop
		}
	}
	
	##
	# Run a list of script dicts.
	#
	# script dict format:
	#   script                    path to script
	#   cell                      scope the script to these cells (list of cells)
	#   ref                       scope the script to these modules
	#   includeParameterization   include parameterized modules for referenced modules (defaults to 1)
	#
	# @param scriptList           list of script dicts (see description)
	proc runScripts {scriptList} {
		foreach script $scriptList {
			::ted::utility::sourceScript [dict get $script script] [::ted::utility::get_setting $script cell {}] [::ted::utility::get_setting $script ref {}] [::ted::utility::get_setting $script includeParameterizations 1]
		}
	}
	
	##
	# Executes code and reports the number of seconds required to do so on the console using puts.
	#
	# Consider using `time` for timing a short running piece of code over multiple iterations.
	#
	# @param code           code to execute/time
	# @param resolution     one of (seconds, microseconds, milliseconds) specifying the resolution
	#
	# @return return value of executing code
	proc runTimed {code {resolution seconds}} {
		set start [clock $resolution]
		return [try [list uplevel 1 $code] finally {puts "Execution took : [expr {[clock $resolution] - $start}] $resolution"}]
	}
	
	##
	# Create a suffix to make names for net or cell creation unique.
	#
	# Vivado reuires unique names for creating nets and cells. If a name is used for a net it
	# can not be used for a cell and vice versa. This procedure returns a number, that when appended
	# with an underscore "_" to the name passed to it, gurantees a name not used for any cell or net.
	# Furthermore, since the number is numerically larger than any other suffixes for the name, multiple cells/nets
	# can be created without name collisions by simply incrementing the number.
	#
	# If the procedure returns 0, the name passed is currently not used for a cell or net and could be used without a suffix (unless someone chose the suffix "_-1").
	#
	# @param name          net/cell name for which to create a unique suffix
	#
	# @return              number, that if appended to $name by an underscore (${name}_[createUniqueSuffix $name]), generates a unique name.
	proc _createUniqueSuffix {name} {
		#set start [expr {[tcl::mathfunc::max {*}[list {*}[getSuffices [get_cells -regexp ${name}_\\d*] ${name}_] -1]]+1}]
		if {[current_instance . -quiet] ne {}} {
			set fullName [current_instance . -quiet][get_hierarchy_separator]$name
		} else {
			set fullName $name
		}
		
		set maxCell [::tcl::mathfunc::max {*}[::ted::utility::getSuffices [get_cells -regexp ${name}_\\d* -quiet] ${fullName}_] -1]
		set maxNet  [::tcl::mathfunc::max {*}[struct::list map [::ted::utility::getSuffices [get_nets -regexp ${name}_\\d*(\\\[\\d*\\\])? -quiet] ${fullName}_] ::ted::utility::parseInt] -1]
		return [expr {[::tcl::mathfunc::max $maxCell $maxNet]+1}]
	}
	
	##
	# Create cell, GURANTEED.
	#
	# Create cell function, that tries to ensure uniqe naming, as naming conflicts prevent cell creation.
	#
	# Create cells named in the form <name>_x, where x is a number that gurantees that the cell can be created.
	#
	# @param name           name to use for the cells
	# @param reference      reference cell to use (same as create_cell -reference)
	# @param count          number of cells to create
	#
	# @return               cell handles for created cells.
	proc createCellUnique {name reference {count 1}} {
		if {$count == 0} {
			return [list ]
		}
		
		if {$count > 1} {
			foreach i [::ted::utility::range $count] {
				lappend names ${name}_$i
			}
		} else {
			set names $name
		}
		
		set cells [create_cell -reference $reference $names -quiet]
		
		if {[llength $cells] < $count} {
			set start [::ted::utility::_createUniqueSuffix $name]

			set names {}
			
			foreach i [::ted::utility::range $start [expr {$start+$count-[llength $cells]}]] {
				lappend names ${name}_$i
			}
			
			#issue: appending to empty list gives a list with the collection as the first element
			# if the list is not empty the two lists are actually joined.
			if {[llength $cells] > 0} {
				lappend cells [create_cell -reference $reference $names -quiet]
			} else {
				set cells [create_cell -reference $reference $names -quiet]
			}
			
			if {[llength $cells] < $count} {
				::ted::utility::message 0 "Creation of $count cells has been requested. Only $lengthCells cells could be created." {CRITICAL WARNING}
			}
		}
		
		return $cells
	}
	
	##
	# Create net, GURANTEED.
	#
	# Create net function, that tries to ensure unique naming, to avoid naming conflicts, which in turn prevent net creation.
	# Naming pattern is ${name}_i where i is a number to make the naming unique.
	#
	# Nets are named in the form <name>_x, where x is a number trying to make the net name unique.
	#
	# @param name          name of the net to be created
	# @param count         number of nets (/bus wires)
	# @param bus           boolean if a bus net should be created or not
	# @param offset        offsets the start of the indices for a bus
	#
	# @return              handles to the created (bus) nets
	proc createNetUnique {name {count 1} {bus false} {offset 0}} {
		if {$count == 0} {
			return [list ]
		}
		
		if {$bus} {
			set nets [create_net ${name} -quiet -from $offset -to [expr {$offset+$count-1}]]
			
			if {[llength $nets] != $count} {
				set start [::ted::utility::_createUniqueSuffix $name]
				set nets [create_net ${name}_${start} -quiet -from $offset -to [expr {$offset+$count-1}]]
			}
		} else {
			if {$count == 1} {
				set nets [create_net $name -quiet]
			} else {
				foreach i [::ted::utility::range $count] {
					lappend names ${name}_$i
				}
				
				set nets [create_net $names -quiet]
			}
			
			if {[llength $nets] < $count} {
				set start [::ted::utility::_createUniqueSuffix $name]
				unset -nocomplain names
				
				foreach i [ted::utility::range $start [expr {$start+$count-[llength $nets]}]] {
					lappend names ${name}_$i
				}
				
				if {[llength $nets]} {
					lappend nets [create_net $names -quiet]
				} else {
					set nets [create_net $names -quiet]
				}
			}
		}
		
		if {[llength $nets] < $count} {
			::ted::utility::message 0 "Creation of $count nets has been requested. Only [llength $nets] nets could be created." {CRITICAL WARNING}
		}
		
		return $nets
	}
	
	##
	# Create pblock, GURANTEED
	#
	# Create a pblock, if there is a name conflict the name will be made unique.
	#
	# The name format is <name>_x, where x is a number trying to make the net name unique.
	# Like Vivado, this does NOT process a list of names.
	#
	# @param name        name for the pblock
	#
	# @return            pblock object, possibly the name has an _<number> suffix
	proc createPblockUnique {name} {
		set pblock [create_pblock $name -quiet]
		
		if {$pblock eq {}} {
			set suffix [::tcl::mathfunc::max {*}[::ted::utility::getSuffices [get_pblocks -regexp ${name}_\\d* -quiet] ${name}_] -1]
			set suffix [expr {$suffix+1}]
			set pblock [create_pblock ${name}_${suffix} -quiet]
		}
		
		if {$pblock eq {}} {
			::ted::utility::errorOut 0 "Failed to create pblock $name."
		}
		
		return $pblock
	}
	
	##
	# Create port, GURANTEED
	#
	# Create a port, if there is a name conflict the name will be made unique.
	#
	# The name format is <name>_x, where x is a number trying to make the net name unique.
	# If -diff_pair is in the arguments list, this is considered during caluclation of the 
	# number to create a unique suffix. In particular if the optional name for the differential
	# port is specified, this optional name is modified py appending the number to it.
	#
	# i.e. if port `p_0` and `p_neg` exist, a call `createPortUnique p OUT -diff_pair p_neg` will
	# result in the ports `p_1` and `p_neg_1`, however the call `createPortUnique p OUT -diff_pair`
	# will create ports `p_1` and `p_1_N` (note the different positions of the suffix number)
	#
	# Like Vivado, this does NOT process a list of names.
	#
	# @param name        name for the port
	# @param direction   direction of the port (IN, OUT, INOUT)
	# @param args        additional arguments to pass to create_port
	#
	# @return            pblock object, possibly the name has an _<number> suffix
	proc createPortUnique {name direction args} {
		set port [create_port $name -direction $direction {*}$args -quiet]
		
		if {$port eq {}} {
			set suffix [::tcl::mathfunc::max {*}[struct::list map [::ted::utility::getSuffices [get_ports -regexp ${name}_\\d*(\\\[\\d*\\\])? -quiet] ${name}_] ::ted::utility::parseInt] -1]
			
			set diffValueIndex [expr {[lsearch -exact $args -diff_pair ]+1}]
			
			#if {{-diff_pair} in $args} equivalent, as otherwise lsearch would return -1, which would become 0, with the offset additon of 1
			if {$diffValueIndex} {
				if {[string match {-*} [lindex $args $diffValueIndex]]} {
					set diffName ${name}_N
				} else {
					set diffName [lindex $args $diffValueIndex]
				}
				
				set suffix [::tcl::mathfunc::max {*}[struct::list map [::ted::utility::getSuffices [get_ports -regexp ${diffName}_\\d*(\\\[\\d*\\\])? -quiet] ${diffName}_] ::ted::utility::parseInt] $suffix]
				set suffix [expr {$suffix+1}]
				
				if {![string match {-*} [lindex $args $diffValueIndex]]} {
					set args [lreplace $args $diffValueIndex $diffValueIndex [lindex $args $diffValueIndex]_$suffix]
				}
			} else {
				#this looks ugly, however we need to create the right suffix inside the above branch to potentially update args
				set suffix [expr {$suffix+1}]
			}
			
			set port [create_port ${name}_${suffix} -direction $direction {*}$args -quiet]
		}
		
		if {$port eq {}} {
			::ted::utility::errorOut 0 "Failed to create port $name."
		}
		
		return $port
	}
	
	##
	# Remove cells, even if (sub)cells are marked as DONT_TOUCH
	#
	# @param cells     cells to remove
	# @param force     boolean indicating if DONT_TOUCH should be ignored (e.g. removed) (default true)
	proc removeCell {cells {force true}} {
		if {$force} {
			set nonPrimitiveCells [filter $cells !IS_PRIMITIVE]
			
			if {[llength $nonPrimitiveCells]} {
				::ted::utility::scopeCode { set_property DONT_TOUCH false [get_cells -hierarchical -filter DONT_TOUCH] } $nonPrimitiveCells
			}
			
			set_property DONT_TOUCH false [filter $cells IS_PRIMITIVE]
		}
		
		remove_cell $cells
	}
	
	##
	# Tokenizes a filter string.
	#
	# Tokenizes a filter string, currently the tokens are &&,||,!,(,), and literals.
	# A literal can be a propertyname or a propertyname with comparison operator (==,=~,!=,!~,<,>,<=,>=) and
	# a string.
	#
	# Does not verify correctness.
	#
	# @param filterString         filter string to parse
	#
	# @return                     tokenized filterString
	#fixme: add trivial order, i.e. check only for logical links between terminals and not at start of string
	#fixme: any use in splitting the "literals" into the respective parts? (leading !, literal name, operator, value)
	proc _tokenizeFilter {filterString} {
		set tokens {}
		set length [string length $filterString]
		
		for {set pos 0} {$pos<$length} {incr pos} {
			set c [string index $filterString $pos]
			
			if {$c in {( ) !}} {
				lappend tokens $c
			} elseif {[regexp {\s} $c]} {
				#ignore whitespace between tokens, account for entailing braces
				incr pos [string length [regexp -inline -start $pos {\A\s*} $filterString]]
				incr pos -2
				#adjust for loop incr pos
				incr pos -1
				continue
			} elseif {$c in {& |}} {
				if {[string index $filterString [expr {$pos+1}]] eq $c} {
					lappend tokens $c$c
					incr pos
				} else {
					throw {{invalid expression}} "Expected $c$c, found $c[string index $filterString [expr {$pos+1}]]"
				}
			} else {
				#we should have a literal, either one of:
				# 1
				# 0
				# <property>[<operator><string>]
				if {$c in {1 0}} {
					#Assumption: 1 and 0 are the only valid tokens as everything else should start with either a letter or an exclamationmark
					lappend tokens $c
				} else {
					if {![regexp -start $pos {\A[A-z][A-z0-9_]*} $filterString literal]} {
						throw {{invalid expression}} "Expected a literal found: ... [string range $filterString $pos end]"
					}
					
					incr pos     [string length $literal]
					
					lappend tokens $literal
					
					#skip whitespace, account for entailing braces
					incr pos [string length [regexp -inline -start $pos {\A\s*} $filterString]]
					incr pos -2
					
					#\s*(?:!=|==|=~|!~|>=|<=|>|<)?\s*
					if {[regexp -start $pos {\A(!=|==|=~|!~|>=|<=|>|<)} $filterString op]} {
						incr pos [string length $op]
						lappend tokens $op
						
						#skip whitespace, account for entailing braces
						incr pos [string length [regexp -inline -start $pos {\A\s*} $filterString]]
						incr pos -2
						
						switch [string index $filterString $pos] {
							"\{" {
								# {} delimited string
								set value [regexp -inline -start $offset "\A\[^\}\]*\}" $filterString]
								incr pos [string length $expressionEnd]
								lappend tokens $value
							}
							{"} {
								# "" delimited string
								set start $pos
								
								while {$pos < $length} {
									incr pos
									set c [string index $filterString $pos]
									
									if {$c eq {"}} {
										break
									}
									
									if {$c eq "\\"} {
										incr pos
									}
								}
	
								lappend tokens [string range $filterString $start $pos]
								incr pos
							}
							& -
							| -
							default {
								#undelimited string or no string
								if {![regexp -start $pos {\A[^\s&|)]+} $filterString value]} {
									throw {{invalid expression}} "Expected a value after $op, found: ...[string range $filterString $pos end]"
								}
								
								lappend tokens $value
								incr pos [string length $value]
							}
						}
					}
					
					incr pos -1
				}
			}
		}
		
		return $tokens
	}
	
	##
	# Turns a filterstring including the literals 1 and 0 into a representation accepted by vivado.
	#
	# Optimizes the literals 1 and 0 out of a filterstring, so that Vivado can handle these.
	#
	# @param filterString   a filter potentially containing the literals 1 and 0
	#
	# @return               a filterstring that is understood by vivado
	proc filterNormalize {filterString} {
		return [::ted::utility::_rewriteReversePolish [::ted::utility::_optimizeNegation [::ted::utility::_shuntingYard [::ted::utility::_tokenizeFilter $filterString]]]]
	}
	
	##
	# Lookuptable for operator precedence
	#
	# Lookuptable for theoperator precedence of the logical operators (&&, ||, !)
	# inside vivado queries (filter expressions).
	# Currently comparison operators are not supported
	#
	# @param operator     operator to look up
	#
	# @return             integer value representing precedence of the operator (higher value means higher precedence)
	proc _precedence {operator} {
		switch -regexp $operator {
			^(!=|!~|==|=~|<|>|>=|<=)$ {
				return 4
			}
			^!$ {
				return 3
			}
			^&&$ {
				return 2
			}
			^\\|\\|$ {
				return 1
			}
			default {
				return 999
			}
		}
	}
	
	##
	# Rewrite a token list in infix notation to reverse Polish notation.
	#
	# Turns a list of tokens in infix notation into a list of tokens in
	# reverse polish notation.
	#
	# @param tokens        list of tokens in infix notation order
	#
	# @return              list of tokens in reverse polish notation order
	proc _shuntingYard {tokens} {
		::struct::stack stack
		set reversePolish {}
		
		foreach token $tokens {
			switch $token {
				"!" -
				"(" {
					stack push $token
				}
				")" {
					while {[stack size]} {
						set stackElement [stack pop]
						
						if {$stackElement eq {(}} {
							break;
						}
						
						lappend reversePolish $stackElement
					}
				}
				"<"  -
				">"  -
				"==" -
				"=~" -
				"!~" -
				"!=" -
				"<=" -
				">=" -
				"&&" -
				"||" {
					set tokenPrecedence [::ted::utility::_precedence $token]
					
					while {[stack size] && [stack peek] ne "(" && [::ted::utility::_precedence [stack peek]] >= $tokenPrecedence} {
						lappend reversePolish [stack pop]
					}
					
					stack push $token
				}
				default {
					lappend reversePolish $token
				}
			}
		}
		
		while {[stack size]} {
			if {[stack peek] eq {(}} {
				puts "Missmatched braces"
			}
			lappend reversePolish [stack pop]
		}
		
		stack destroy
		
		return $reversePolish
	}
	
	##
	# Turn a filter in reverse polish notation, into a filterstring understood by vivado.
	#
	# Turns a filter in reverse polish notation into a filterstring understood by vivado.
	# Takes special care to optimize the literals 1 and 0 out of the boolean equations as these
	# are not supported by vivado.
	#
	# @param reversePolish      a list holding an expression in reverse polish notation
	#
	# @return                   a query string for vivado's filter function (or -filter parameter of get_* functions)
	proc _rewriteReversePolish {reversePolish} {
		#stack is of pairs: operand lowestPrecedenceOfOperatorOnTopLevel (i.e. not in braces)
		::struct::stack stack
		
		set operandPrecedence 999
		
		foreach token $reversePolish {
			switch -regexp $token {
				^(!=|!~|==|=~|<|>|>=|<=)$ {
					set op2 [stack pop]
					set op1 [stack pop]
					
					stack push [list "[lindex $op1 0]$token[lindex $op2 0]" [::ted::utility::_precedence $token]]
				}
				^&&$ {
					set op2 [stack pop]
					set op1 [stack pop]
					
					if {[lindex $op1 0] eq 0 || [lindex $op2 0] eq 0} {
						stack push [list 0 $operandPrecedence]
					} elseif {[lindex $op1 0] eq 1} {
						stack push $op2
					} elseif {[lindex $op2 0] eq 1} {
						stack push $op1
					} else {
						if {[lindex $op1 1]<[::ted::utility::_precedence &&]} {
							lset op1 0 "([lindex $op1 0])"
						}
						if {[lindex $op2 1]<[::ted::utility::_precedence &&]} {
							lset op2 0 "([lindex $op2 0])"
						}
						
						stack push [list "[lindex $op1 0]&&[lindex $op2 0]" [::ted::utility::_precedence &&]]
					}
				}
				{^\|\|$} {
					set op2 [stack pop]
					set op1 [stack pop]
					
					if {[lindex $op1 0] eq 1 || [lindex $op2 0] eq 1} {
						stack push [list 1 $operandPrecedence]
					} elseif {[lindex $op1 0] eq 0} {
						stack push $op2
					} elseif {[lindex $op2 0] eq 0} {
						stack push $op1
					} else {
						if {[lindex $op1 1]<[::ted::utility::_precedence ||]} {
							lset op1 0 "([lindex $op1 0])"
						}
						if {[lindex $op2 1]<[::ted::utility::_precedence ||]} {
							lset op2 0 "([lindex $op2 0])"
						}
						
						stack push [list "[lindex $op1 0]||[lindex $op2 0]" [::ted::utility::_precedence ||]]
					}
				}
				^!$ {
					set op [stack pop]
					
					switch [lindex $op 0] {
						0 {
							stack push [list 1 $operandPrecedence]
						}
						1 {
							stack push [list 0 $operandPrecedence]
						}
						default {
							if {[lindex $op 1]<[::ted::utility::_precedence !]} {
								stack push [list "!([lindex $op 0])" [::ted::utility::_precedence !]]
							} else {
								stack push [list "![lindex $op 0]" [::ted::utility::_precedence !]]
							}
						}
					}
				}
				default {
					stack push [list $token $operandPrecedence]
				}
			}
		}
		
		set result [lindex [stack pop] 0]
		stack destroy
		
		#special case, allow the expression "1" to return everything
		if { $result eq {1}} {
			return {}
		}
		
		return $result
	}
	
	##
	# Rewrite expression negation !(...) in terms vivado understands inside a reverse polish notation.
	#
	# @param reversePolish       reverse polish notation to rewrite
	#
	# @return                    rewritten reverse polish notation
	proc _optimizeNegation {reversePolish} {
		set pos 1
		
		set operatorInversions [dict create	\
			&&	||		\
			||	&&		\
			==	!=		\
			!=	==		\
			<	>=		\
			>=	<		\
			>	<=		\
			<=	>		\
			=~	!~		\
			!~	=~		\
		]
		
		set comparisonOperators  {== != =~ !~ < <= > >=}
		set operators            [list ! && || {*}$comparisonOperators]
		
		#TODO: we should really have a list of all allowed operators somewhere more global, and not in every function
		#first token should ALWAYS be a literal, so use a dummy
		set last dummy
		
		while {$pos<[llength $reversePolish]} {
			set current [lindex $reversePolish $pos]
			if {$current eq {!} && $last in $operators} {
				#we have a complex ! expression, negate all preceding
				set posUpdate 0
				
				while {$posUpdate < $pos} {
					set current [lindex $reversePolish $posUpdate]
					
					if {$current in $operators} {
						#invert the operator
						lset reversePolish $posUpdate [dict get $operatorInversions $current]
						incr posUpdate
					} else {
						#literal, invert avoiding multiple inversions
						incr posUpdate
						set preceding [lindex $reversePolish $posUpdate]
						if {$preceding in $comparisonOperators || [lindex $reversePolish [expr {$posUpdate+1}]] in $comparisonOperators} {
							#just skip as the comparison operator will be changed accordingly
						} elseif {$preceding eq {!}} {
							#already inverted, remove inversion
							set reversePolish [lreplace $reversePolish $posUpdate $posUpdate]
							incr pos -1
						} else {
							#insert inversion and skip it
							set reversePolish [lreplace $reversePolish $posUpdate -1 !]
							incr posUpdate
							incr pos
						}
					}
				}
				
				#remove !
				set reversePolish [lreplace $reversePolish $pos $pos]
				#incase multiple negation is handled last might need an update (i.e. {a ! !})
				set last [lindex $reversePolish [expr {$pos-1}]]
			} else {
				incr pos
				set last $current
			}
		}
		
		return $reversePolish
	}
	
	##
	# Join multiple elements to a path.
	#
	# Empty elements are automatically removed, allowing general code like:
	#
	#   joinPath $parent cellname
	#
	# which will work even if $parent is empty
	#
	# @param args            variadic, element to be joined to a path
	#
	# @return                fullpath
	proc joinPath {args} {
		#struct::list flatten removes empty elements
		return [join [struct::list flatten $args] [get_hierarchy_separator]]
	}
	
		
	namespace eval reportStyle {
		##
		# Defines a report style for tables
		set definedStyles [::report::styles]
		
		foreach style {report_captionedTable} {
			if {$style in $definedStyles} {
				::report::rmstyle $style
				puts "UPSI: Style $style was still around"
			}
		}
		
		::report::defstyle report_captionedTable {{n 1}} {
			data      set [list {} {*}[lrepeat [expr {[columns]-1}] { | }] {}]
			top       set [list {} {*}[lrepeat [expr {[columns]-1}] {-} { | }] {-} {}]
			#top       set [split "[string repeat "+ - " [columns]]+"]
			topdata   set [data get]
			topcapsep set [top get]
			bottom    set [top get]
			top       enable
			topcapsep enable
			bottom    enable
			tcaption $n
		}
		
		::ted::_internal::attachToHook unload {::report::rmstyle report_captionedTable}
	}
	
	##
	# Remove the first value from a list and return it.
	#
	# Helpful for argParse
	#
	# @param listName        name of the list variable to modify
	#
	# @return                value of the first element, which has been stripped of the list
	proc pop {{listName valueList}} {
		upvar 1 $listName valueList
		set value [lindex $valueList 0]
		set valueList [lrange $valueList 1 end]
		return $value
	}
	
	##
	# Generalized argument parsing.
	#
	# Generalizes argument parsing, by taking a dictionary with argument descriptions.
	#
	# The dictionary has the form:  parameter code
	#
	# where parameter is the exact option that triggers the execution of code to handle the flag.
	# if no code is supplied, a variable with the option name will be set to true or false,
	# depending on the presence of the flag, i.e. a dictionary entry "-boolean {}" would create
	# the variable "boolean" in the calling code (note the missing -), also true and false are
	# accepted to initialize the variable accordingly
	#
	# the code is executed in the scope of the caller of argParse. To make this work,
	# argParse creates a variable (the name can be specified using the parameter valueListName)
	# inside the calling function.
	#
	# The code for argument parsing has access to the valueList, and may modify this, these changes
	# are observed by argParse. It is the responsibility of the called code to remove the argument
	# from the argument list to prevent infinite looping, however this allows to look at the value being
	# handled. If the code wants to handle multiple arguments, it can simply remove multiple arguments from
	# the list. The helper function pop can be used to remove the first value from the list and retrieve its value.
	#
	# For instance the following argParseDict causes an argument of -- to stop the parser, by removing all
	# values from the value list.
	#
	#  {-- {set valueList {}}}
	#
	# Note: make sure ted::utility::pop is used rather than a local pop
	#
	# Default values are applied to all arguments in a first step, and are overwritten by positional arguments as
	# soon as the parser finds them. This allows subsequent -flags to modify these positional arguments. However,
	# flags given before the parser finds the positional arguments will find either the default or invalid values.
	# To avoid this code could be written, that moves non positional arguments to the back of the list, until all
	# positional arguments are found. Example:
	#
	# proc example {{a default} args} {
	# 	ted::utility::argParse {-parseFinished {} parseStarted {} -demoFlag {if {!$parseStarted} {set parseStarted true; lappend valueList -parseFinished}; if {!$parseFinished} { puts "a is $a"; lappend valueList [ted::utility::pop]} else { puts "at the end a is $a"; ted::utility::pop} } -check {puts "A currently is $a"; ted::utility::pop} }
	# }
	#
	# The example uses flags to create two boolean flags, defaulting to false.
	# The -demoFlag code checks the first flag (parse startet), and appends a flag -parseFinished to the end of the arguments if the parsing has not started yet and sets started to true.
	# Every passing of -demoFlag, simply moves it to the end, until parse finished becomes true, which happens as soon as the parser finds th parseFinished flag, that was insert in the beginning.
	# At this point -demoFlag actually evaluates the code of demoFlag
	#
	# @param argParseDict    dictionary describing flags and how to handle them
	#TODO: add a proper way to stop parsing and consider all remaining arguments as positional (flag that is evaluated by argParse?)
	proc argParse {argParseDict {valueListName valueList}} {
		upvar $valueListName valueList
		set valueList {}
		
		#initialize booleans to false
		dict for {key value} $argParseDict {
			if {$value eq {}} {
				set value false
			}
			
			if {$value in {true false}} {
				if {[string equal -length 1 {-} $key]} {
					uplevel [list set [string range $key 1 end] $value]
				} else {
					uplevel [list set $key $value]
				}
			}
		}
		
		set procName [dict get [info frame -1] proc]
		set argList [info args $procName]
		
		set hasArgs [expr {[lindex $argList end] eq {args}}]

		foreach arg [lrange $argList 0 end-$hasArgs] {
			upvar 1 $arg arguments.$arg
			lappend valueList [set arguments.$arg]
		}
		
		if {$hasArgs} {
			upvar 1 args arguments.args
			lappend valueList {*}${arguments.args}
		}
		
		#restore defaults - avoid default for args, as this would be non standard
		#restored aggressively so that flags can overwrite defaults
		foreach arg [lrange $argList 0 end-$hasArgs] {
			if {[info default $procName $arg defaultValue]} {
				set arguments.$arg $defaultValue
			}
		}
		
		set positionalValues {}
		set positionalIndex 0
		set argumentCount [llength $argList]
		
		#foreach value $valueList {}
		while {[llength $valueList]} {
			set value [lindex $valueList 0]
			
			puts "[llength $valueList]: $valueList"
			
			#if {$value eq {--}} {
			#	#stop parsing on --
			#	lappend positionalValues {*}$valueList
			#	break
			#}
			
			if {[dict exists $argParseDict $value]} {
				#parse accordingly
				set action [dict get $argParseDict $value]
				
				if {$action eq {}} {
					set action false
				}
				
				if {$action in {true false}} {
					#just set a boolean flag without the dash
					if {$action} {
						set action false
					} else {
						set action true
					}
					
					if {[string equal -length 1 {-} $value]} {
						uplevel [list set [string range $value 1 end] true]
					} else {
						uplevel [list set $value true]
					}
					
					ted::utility::pop valueList
				} else {
					#TODO: sanity check that action actually modifies value list? or iteration limit?
					uplevel 1 $action
				}
			} else {
				if {$positionalIndex<$argumentCount} {
					if {$hasArgs && $positionalIndex==$argumentCount-1} {
						lappend positionalValues $value
					} else {
						set arguments.[lindex $argList $positionalIndex] $value
						incr positionalIndex
					}
					
					ted::utility::pop valueList
				} else {
					throw {wrong # args} "To many positional arguments. $valueList"
				}
			}
		}
		
		if {$positionalIndex<$argumentCount-$hasArgs} {
			throw {wrong # args} "To few positional arguments to $procName, expected: $procName $argList"
		}
		
		if {$hasArgs} {
			set arguments.args $positionalValues
		}
		
		#remove the value list from the caller. This actually unsets the variable in the caller
		unset valueList
	}
}

#wipe out statics on reload of package
::ted::utility::_resetAllStaticVariables