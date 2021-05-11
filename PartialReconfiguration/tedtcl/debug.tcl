namespace eval ::ted::DEBUG {
	# todo: debug of subfeature ALL should return true if a global debug is turned on.
	# => do not rely on debugEnabled "ALL" to return the actual level of the subfeature ALL, but the maximum of (debugLevel "yourFunction::ALL", GLOBAL_DEBUG_LEVEL"
	
	#wipe out debug settings on reload
	if {[namespace exists ::ted::DEBUG::static]} {
		namespace delete ::ted::DEBUG::static
	}
	
	##
	# Enable debugging in the current function.
	#
	# This shortcut is meant for development of tedtcl, if you are an enduser using
	# enableDebug(function, verbosity, subfeature) in debug.settings.tcl
	#
	# @param verbosity              verbosity level to enable
	# @param subfeature             subfeature for which to enable debugging
	proc debugThis {{verbosity 999} {subfeature "ALL"}} {
		set procName [namespace tail [lindex [info level -1] 0]]
		set ns       [string trimright [uplevel 1 {namespace current}] :]
		
		set caller ${ns}::${procName}
		
		enableDebug $caller $verbosity $subfeature
	}
	
	##
	# Enable debugging for a function.
	#
	# Sets a debug flag which can be used by function internal debug code.
	# The file debug.settings.tcl would be one possible place to do this.
	#
	# @param function             fully qualified function name
	# @param verbosity            debug level to set (default: 999)
	# @param subfeature           subfeature for which to enable debug
	proc enableDebug {function {value 999} {subfeature "ALL"}} {
		## \internal Namespace insisde static created for each function that has static variables
		namespace eval ::ted::DEBUG::static::$function {}
		
		set ::ted::DEBUG::static::${function}::$subfeature $value
	}
	
	##
	# Check if Debug is enabled for the current function.
	#
	# //currently disabled param verbosity  the debug level which should be enabled
	# @param subfeature                 subfeature to check for
	# @param specific                   ignore the all flag when querying the debug state of the feature
	#
	# @return                     debug level that is enabled or 0 if it is not enabled
	#{verbosity -1}
	proc debugEnabled {{subfeature "ALL"} {specific false}} {
		set procName [namespace tail [lindex [info level -1] 0]]
		set ns       [string trimright [uplevel 1 {namespace current}] :]
		
		set qualifiedName ::ted::DEBUG::static::${ns}::${procName}
		
		if {[info exists "${qualifiedName}::$subfeature"]} {
			return [set "${qualifiedName}::$subfeature"]
			#if {$value < 0} {
			#	return $qualifiedName
			#}
			
			#return [expr {$value <= $qualifiedName}]
		}
		
		if {!$specific && [info exists "${qualifiedName}::ALL"]} {
			return [set "${qualifiedName}::ALL"]
		}
		
		return 0
	}
}