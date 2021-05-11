package require uuid

namespace eval ::ted {
	#has to be on the top level to trigger on "namespace delete ted"
	variable _cleanupCanary 0
}

namespace eval ::ted::_internal {
	#wipe out statics on reload of package
	if {[namespace exists ::ted::_internal::patchedCommands]} {
		namespace delete ::ted::_internal::patchedCommands
	}
	
	#wipe out statics on reload of package
	if {[namespace exists ::ted::_internal::_static]} {
		::ted::utility::message 0 {Wiping ALL design static variables due to reload.} WARNING
		namespace delete ::ted::_internal::_static
	}
	
	#reserve a namespace for patched commands
	namespace eval ::ted::_internal::patchedCommands {}
	
	# unload hook: list of all hook callbacks
	variable hook_unload [list ]
	
	##
	# Provides the unload hook.
	#
	# This procedure is attached to a "trace variable unset", while the arguments are not used,
	# they are passed in by the trace. Calls unload to do the actual work.
	#
	# @param name1       variable name
	# @param name2       index if the variable is an array
	# @param op          operation triggering the callback
	#
	proc _unload {name1 name2 op} {
		::ted::_internal::unload
	}
	
	##
	# Provides the unload hook.
	#
	# The command clears the unload_hook, just in case.
	#
	proc unload {} {
		#FIXME ted::message causes the following code to not execute
		puts {Unload hook is called}
		#::ted::utility::message 0 "Unload hook is called" STATUS
		puts hooooooker
		
		foreach hookCode $::ted::_internal::hook_unload {
			#puts "foundAHooker $hookCode ..."
			if {[catch [list uplevel #0 $hookCode] result errorData]} {
				ted::message _internal-0 "An error occured while executing the code for an unload hook. (tcl errorcode [dict get $errorData -code])" ERROR
				
				#print the stack trace (marked as ERROR, so it is visble when filtering for ERRORs only)
				if {[dict exists $errorData -errorinfo]} {
					ted::message _internal-0 [dict get $errorData -errorinfo] ERROR
				} else {
					ted::message _internal-0 "Unfortunatly we failed to find a stacktrace." ERROR
				}
				
				#rethrow? rather finish unloading
				#return -options $errorData $result
			}
		}
		
		#clearing hook_unload, just in case
		set ::ted::_internal::hook_unload {}
	}
	
	##
	# Attach code to a hook.
	#
	# @param hook       the hook to attach to, i.e. 'unload' for 'hook_unload'
	# @param code       the code to execute from the hook
	proc attachToHook {hook code} {
		#puts "Attaching '$code' to $hook"
		lappend ::ted::_internal::hook_$hook $code
	}
	
	##
	# Patches a command.
	#
	# Replaces a command by user code. args can be used to specify the argument list (in the same way as for proc),
	# and ::ted::_internal::patchedCommands::<command> can be used to call the previous command from the patched command.
	#
	# This patch command procedure also attaches to the unload hook, restoring the original behaviour when the unload hook is triggered.
	#
	# @param command      name of the command to patch
	# @param code         new code for replacement
	# @param args         argumentlist used by the new command
	# //@param level        1 to patch in the calling namespace, #0 to patch on the top level
	#FIXME does this work if unload is called from another level? Should we just require fully qualified names (i.e. ::command)
	#FIXME allow multiple patches, i.e. on name conflict, add a number to the temporary renamed command
	proc patchCommand {command code args {level 1}} {
		rename $command ::ted::_internal::patchedCommands::$command
		uplevel 1 "proc $command [list $args] [list $code]"
		::ted::_internal::attachToHook unload "rename $command {}; rename ::ted::_internal::patchedCommands::$command $command"
	}
	
	##
	# Extend an ensemble command with new subcommands.
	#
	# code based on http://wiki.tcl.tk/15566
	#
	# @param cmd               command to extend
	# @param subcmd            name of the new subcommand
	# @param subspec           argument list of the new command
	# @param body              function body of the new subcommand.
	proc extendEnsemble {cmd subcmd subspec body} {
		namespace eval [uplevel 1 [list namespace which $cmd]] [string map [list \
			%subcmd  [list $subcmd]  \
			%subspec [list $subspec] \
			%body    [list $body]    \
		] {
			if { \
				[namespace which [namespace tail [namespace current]]] ne                        \
				"[string trimright [namespace current] :]::[namespace tail [namespace current]]" \
			} {
				::rename [::namespace current] [::namespace current]::[::namespace tail [::namespace current]]
				::namespace export *
				::namespace ensemble create -unknown [list ::apply [list {ns subc args} {
					::return [::list ${ns}::[::namespace tail $ns] $subc]
				} [namespace current]]]
			}
			puts [list creating %subcmd in [namespace current]]
			::proc %subcmd %subspec %body
		}]
	}
}

# Arm the canary, so that we do cleanup if "namespace delete ::ted" is called
trace add variable ::ted::_cleanupCanary unset ::ted::_internal::_unload


# Add "package reload x" as a shorthand to unload and reload a package, clearing its namespace in the process.
ted::_internal::extend package reload {packageName} {
	package forget $packageName
	if {[namespace exists ::$packageName]} {
		namespace delete ::$packageName
	}
	package require $packageName
}