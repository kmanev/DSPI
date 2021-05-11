package require tcltest

::tcltest::configure -testdir [file dirname [file normalize [info script]]]
::tcltest::configure -singleproc true

# this would work if called in batch mode, otherwise it might be dangerous (i.e. picking up arguments passed to vivado
#::tcltest::configure {*}$::argv

::tcltest::runAllTests