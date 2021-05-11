package provide ted 2.0

## Add tcl extensions to autopath if they are not present
foreach module [glob -type d -directory [file join [file dirname [dict get [info frame 0] file]] tcllib] *] {
	if {$module ni $::auto_path} {
		set ::auto_path [linsert $::auto_path 0 $module]
		
		puts "Added module [file tail $module] to auto_path"
	}
}