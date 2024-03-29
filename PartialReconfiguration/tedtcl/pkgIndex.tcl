# Tcl package index file, version 1.1
# This file is generated by the "pkg_mkIndex" command
# and sourced either when an application starts up or
# by a "package unknown" script.  It invokes the
# "package ifneeded" command to set up package-related
# information so that packages will be loaded automatically
# in response to "package require" commands.  When this
# script is sourced, the variable $dir must contain the
# full path name of this file's directory.

#NOTE: this file needs to be generated manually, as the loading order is important.
# suggested load order:
#   utility.tcl         a lot depends on this, it depends on nothing
#   rect.tcl            a lot depends on it, while it does depend on nothing
#    ... remainder
#   debug.settings.tcl  load this last, as we want to override defaults with this.
# todo: can we automatically create a dependency graph?

package ifneeded ted 2.0 "
[list source [file join $dir tedtcl.tcl]]
[list source [file join $dir _internal.tcl]]
[list source [file join $dir analyze.tcl]]
[list source [file join $dir debug.tcl]]
[list source [file join $dir utility.tcl]]
[list source [file join $dir architecture.tcl]]
[list source [file join $dir placer.tcl]]
[list source [file join $dir vivado.errors.tcl]]
[list source [file join $dir rect.tcl]]
[list source [file join $dir coordinates.tcl]]
[list source [file join $dir parser.tcl]]
[list source [file join $dir project.tcl]]
[list source [file join $dir routing.tcl]]
[list source [file join $dir selectors.tcl]]
[list source [file join $dir partial.tcl]]
[list source [file join $dir debug.settings.tcl]]
"