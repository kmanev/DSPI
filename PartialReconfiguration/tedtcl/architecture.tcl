namespace eval ::ted::architecture {
	variable loaded_architectures {}
	
	##
	# Return the name of the architecture used in the current design.
	#
	# @return       name of the architecture used in the current design
	proc getArchitectureName {} {
		return [get_property ARCHITECTURE [get_property PART [current_design]]]
	}
	
	##
	# Load architecture specific functions.
	#
	# @param architecture       architecture to load, defaults to [::ted::architecture::getArchitectureName] (default {})
	proc loadArchitecture {{architecture {}}} {
		variable loaded_architectures
		
		if {$architecture eq {}} {
			set architecture [::ted::architecture::getArchitectureName]
		}
		
		if {$architecture in $loaded_architectures} {
			return
		}
		
		set architecture_file [file join [file dirname [dict get [info frame 0] file]] architecture.${architecture}.tcl]
		
		if {[file exist $architecture_file]} {
			::ted::utility::message 0 "Loaded Architecture $architecture from $architecture_file" STATUS
			uplevel #0 [list source $architecture_file -notrace]
			lappend loaded_architectures $architecture
		} else {
			::ted::utility::message 0 "Architecture file '$architecture_file' not found" ERROR
		}
	}
	
	##
	# Tests if the architecture is loaded already
	#
	# @param architecture           architecture name for which to check if it is loaded
	proc isLoaded {architecture} {
		return [expr {$architecture in $::ted::architecture::loaded_architectures}]
	}
	
	namespace unknown ::ted::architecture::_unknownHandler
	
	proc _unknownHandler {args} {
		set procName [lindex $args 0]
		
		puts "checking $procName"
		
		if {[string range ${procName} 0 [expr {[string first _ ${procName}]-1}]] in {bier hefe}} {
			puts "I recognize you"
		}
		puts "you called $args, it failed as [string range ${procName} 0 [expr {[string first _ ${procName}]-1}]]."
	}
	
	##
	# Call a function for the architecture of the current design
	#
	# @param function            base name of the function
	# @param args                arguments to pass to the function (variadic, i.e. all arguments after function are passed on)
	#
	# @return                    return value of the function that was called
	proc call {function args} {
		set architecture [::ted::architecture::getArchitectureName]
		
		if {![isLoaded $architecture]} {
			loadArchitecture $architecture
		}
		
		return [uplevel 1 [list ::ted::architecture::${architecture}::${function} {*}$args]]
	}
}