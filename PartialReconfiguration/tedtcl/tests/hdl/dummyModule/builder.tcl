#user configuration

#lappend auto_path  tedtcl
package require ted

set basePath ""

set srcdir(hdl)  .

#####################################
set sources [dict create]

dict set sources top			dummyHead
dict set sources checkpointDir	Checkpoints

dict lappend sources bd			
dict lappend sources ip		
dict lappend sources ipRepos	
dict lappend sources sv			\
									$srcdir(hdl)/top.sv
dict lappend sources v			
dict lappend sources xdc		

#dict lappend sources synth.post \
#									[dict create script ./src/xdc/static_post_synthesis.tcl]

dict lappend sources place.pre		
dict lappend sources route.pre	
dict lappend sources route.post	
dict lappend sources synth.flags        -top [dict get $sources top] -directive Default
dict lappend sources opt.flags          
dict lappend sources place.flags        
dict lappend sources postPlaceOpt.flags 
dict lappend sources route.flags        -preserve -tns_cleanup
dict lappend sources postRouteOpt.flags 
dict lappend sources bitstream.flags    {}

#Limit checkpointing to only every 15 minutes
#dict set sources checkpoints      900

dict set sources postPlaceOpt.iterations -1
dict set sources postRouteOpt.iterations -1

dict set sources project.create		1

dict set sources synth.run			1
dict set sources opt.run			1
dict set sources place.run			1
dict set sources postPlaceOpt.run	0
dict set sources route.run			1
dict set sources postRouteOpt.run	0
dict set sources bitstream.run		0

#####################################

set part      xc7vx690tffg1761-2
set boardPart "xilinx.com:vc709:part0:1.8"

if {[ted::utility::get_setting $sources project.create 1]} {
	set inMemory 1
	ted::project::makeProject $sources $part "myProject" "./Project/inMemory" $inMemory $boardPart
}

ted::project::build sources build
