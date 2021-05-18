# TedTCL
Developed by **Malte Vesper** (https://www.research.manchester.ac.uk/portal/files/162163305/FULL_TEXT.PDF).

Originally publically released by **Khoa Pham** (https://github.com/khoapham/efcad).

## Using TedTCL

The easiest way to use tedtcl with Vivado is to add the following to your ~/.Xilinx/Vivado/Vivado_init.tcl

    lappend auto_path <path to tedtcl>
    package require ted

Alternativley you could add these lines in your script to load the package when needed rather than at vivado startup.

While the afformentioned method allows you to keep tedtcl wherever you like, you could also place tedtcl into one of
tcls package directories. In that case, you still need to load the package with `package require ted`, but adding its
directory to tcls search path becomes unnecessary.

You could also add the path to tedtcl to the enviornment variable `TCLLIBPATH`. From tcl you  could do

    set ::env(TCLLIBPATH) [list /opt/tcl/site-lib /users/pat/working]

However this is not to usefull, as you would like to set the variable before vivado starts. This could be done in your ~/.profile

	export TCLLIBPATH="/home/ted/srcFPGA/PCIeHLS17.1/tedtcl $TCLLIBPATH"
	
## Documentation

The documentation can be generated by running `doxygen` in the tedtcl folder. This will generate the html documentation, which can
be accessed under tedtcl/doc/html/index.html. Use Doxygen > 1.8.7 (as of this writing centos still ships with 1.8.5), otherwise links to extra pages might break.

There is a lot of coding Tips that were found out while working on this, they are collected in a [special page](\ref codingTips)

## Testing

Tests can be run by sourcing tests/all.tcl, to surpress echoing of the code use `source ./all.tcl -notrace`