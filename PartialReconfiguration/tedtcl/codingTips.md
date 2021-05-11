# Coding Tips {#codingTips}

Vivado has a lot of peculiar behaviour, to save you the trouble of finding out about these behaviours they are listed here. Should you find that a behaviour is no longer present in a newer Version of Vivado please mark it here.

## Get_* -of_objects acceptance

Sometimes it is not clear what commands can be called on what objects, the following matrix should help. I.e. `get_tiles -of_objects $pblock` does not work. However, as `get_sites -of_objects $pblock` does work, one can run `get_tiles -of [get_sites -of_objects $pblock]` to get the tiles related to the pblock. This does not include the interconnect, for that have a look at tedtcl.

<!--
|                      | bels | bel_pins | cells | clocks | nets | nodes | pblocks | pins | pips | site_pins | site_pips | sites | tiles | wires |
|----------------------|------|----------|-------|--------|------|-------|---------|------|------|-----------|-----------|-------|-------|-------|
| get_bel_pins         |**1** |  0       |  0    |  0     |**1** |  0    |  0      |**1** |  0   |  0        |  0        |**1**  |  0    |  0    |
| get_bels             |  0   |  0       |**1**  |  0     |**1** |  0    |  0      |  0   |  0   |  0        |  0        |**1**  |**1**  |  0    |
| get_cells            |  0   |  0       |  0    |  0     |**1** |  0    |**1**    |**1** |  0   |  0        |  0        |**1**  |  0    |  0    |
| get_clock_regions    |  0   |  0       |**1**  |  0     |  0   |  0    |  0      |  0   |  0   |  0        |  0        |**1**  |  0    |  0    |
| get_clocks           |  0   |  0       |**1**  |  0     |**1** |  0    |  0      |**1** |  0   |  0        |  0        |  0    |  0    |  0    |
| get_generetad_clocks |  0   |  0       |**1**  |  0     |**1** |  0    |  0      |**1** |**1** |  0        |  0        |  0    |  0    |  0    |
| get_nets             |  0   |  0       |**1**  |**1**   |  0   |**1**  |  0      |**1** |  0   |**1**      |  0        |**1**  |**1**  |  0    |
| get_nodes            |  0   |  0       |  0    |  0     |**1** |**1**  |  0      |  0   |  0   |**1**      |  0        |  0    |**1**  |**1**  |
| get_pblocks          |  0   |  0       |**1**  |  0     |  0   |  0    |  0      |  0   |  0   |  0        |  0        |**1**  |  0    |  0    |
| get_pins             |  0   |  0       |**1**  |**1**   |**1** |  0    |  0      |  0   |  0   |  0        |  0        |  0    |  0    |  0    |
| get_pips             |  0   |  0       |  0    |  0     |**1** |**1**  |  0      |  0   |**1** |  0        |  0        |**1**  |**1**  |**1**  |
| get_site_pins        |  0   |**1**     |  0    |  0     |**1** |**1**  |  0      |**1** |  0   |  0        |  0        |**1**  |  0    |  0    |
| get_site_pips        |  0   |  0       |  0    |  0     |  0   |  0    |  0      |**1** |  0   |  0        |  0        |**1**  |  0    |  0    |
| get_sites            |**1** |**1**     |**1**  |  0     |**1** |  0    |**1**    |  0   |  0   |**1**      |  0        |  0    |**1**  |  0    |
| get_tiles            |**1** |**1**     |  0    |  0     |**1** |**1**  |  0      |  0   |**1** |**1**      |  0        |**1**  |**1**  |**1**  |
| get_wires            |  0   |  0       |  0    |  0     |**1** |**1**  |  0      |  0   |**1** |  0        |  0        |  0    |**1**  |  0    |
-->

<table>
<tr><th>           </th><th> get_bel_pins      </th><th> get_bels          </th><th> get_cells         </th><th> get_clock_regions </th><th> get_clocks        </th><th> get_generetad_clocks </th><th> get_nets          </th><th> get_nodes         </th><th> get_pblocks       </th><th> get_pins          </th><th> get_pips          </th><th> get_site_pins     </th><th> get_site_pips     </th><th> get_sites         </th><th> get_tiles         </th><th> get_wires         </th></tr>
<tr><td> bels      </td><td class="highlight">1</td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                    </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td class="highlight">1</td><td class="highlight">1</td><td> 0                 </td></tr>
<tr><td> bel_pins  </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                    </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td class="highlight">1</td><td> 0                 </td><td class="highlight">1</td><td class="highlight">1</td><td> 0                 </td></tr>
<tr><td> cells     </td><td> 0                 </td><td class="highlight">1</td><td> 0                 </td><td class="highlight">1</td><td class="highlight">1</td><td class="highlight">1   </td><td class="highlight">1</td><td> 0                 </td><td class="highlight">1</td><td class="highlight">1</td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td class="highlight">1</td><td> 0                 </td><td> 0                 </td></tr>
<tr><td> clocks    </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                    </td><td class="highlight">1</td><td> 0                 </td><td> 0                 </td><td class="highlight">1</td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td></tr>
<tr><td> nets      </td><td class="highlight">1</td><td class="highlight">1</td><td class="highlight">1</td><td> 0                 </td><td class="highlight">1</td><td class="highlight">1   </td><td> 0                 </td><td class="highlight">1</td><td> 0                 </td><td class="highlight">1</td><td class="highlight">1</td><td class="highlight">1</td><td> 0                 </td><td class="highlight">1</td><td class="highlight">1</td><td class="highlight">1</td></tr>
<tr><td> nodes     </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                    </td><td class="highlight">1</td><td class="highlight">1</td><td> 0                 </td><td> 0                 </td><td class="highlight">1</td><td class="highlight">1</td><td> 0                 </td><td> 0                 </td><td class="highlight">1</td><td class="highlight">1</td></tr>
<tr><td> pblocks   </td><td> 0                 </td><td> 0                 </td><td class="highlight">1</td><td> 0                 </td><td> 0                 </td><td> 0                    </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td class="highlight">1</td><td> 0                 </td><td> 0                 </td></tr>
<tr><td> pins      </td><td class="highlight">1</td><td> 0                 </td><td class="highlight">1</td><td> 0                 </td><td class="highlight">1</td><td class="highlight">1   </td><td class="highlight">1</td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td class="highlight">1</td><td class="highlight">1</td><td> 0                 </td><td> 0                 </td><td> 0                 </td></tr>
<tr><td> pips      </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td class="highlight">1   </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td class="highlight">1</td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td class="highlight">1</td><td class="highlight">1</td></tr>
<tr><td> site_pins </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                    </td><td class="highlight">1</td><td class="highlight">1</td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td class="highlight">1</td><td class="highlight">1</td><td> 0                 </td></tr>
<tr><td> site_pips </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                    </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td></tr>
<tr><td> sites     </td><td class="highlight">1</td><td class="highlight">1</td><td class="highlight">1</td><td class="highlight">1</td><td> 0                 </td><td> 0                    </td><td class="highlight">1</td><td> 0                 </td><td class="highlight">1</td><td> 0                 </td><td class="highlight">1</td><td class="highlight">1</td><td class="highlight">1</td><td> 0                 </td><td class="highlight">1</td><td> 0                 </td></tr>
<tr><td> tiles     </td><td> 0                 </td><td class="highlight">1</td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                    </td><td class="highlight">1</td><td class="highlight">1</td><td> 0                 </td><td> 0                 </td><td class="highlight">1</td><td> 0                 </td><td> 0                 </td><td class="highlight">1</td><td class="highlight">1</td><td class="highlight">1</td></tr>
<tr><td> wires     </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td> 0                    </td><td> 0                 </td><td class="highlight">1</td><td> 0                 </td><td> 0                 </td><td class="highlight">1</td><td> 0                 </td><td> 0                 </td><td> 0                 </td><td class="highlight">1</td><td> 0                 </td></tr>
</table>

While some of these functions do not throw an error, they return a wrong result, i.e. `get_sites -of_objects $siteObject` returns an empty result,
which is clearly wrong. These cases were also marked as zeros in the table above.

The code used to test these is as follows:

```tcl
set commands [list bel_pins bels cells clock_regions clocks generated_clocks nets nodes pblocks pins pips site_pins site_pips sites tiles wires]
set t <object to test>

foreach cmd $commands {
   puts get_$cmd
   catch {
      puts [get_$cmd -of $t]
   } result errorData
   if {[dict get $errorData -code] == 1} {
       puts ErroredOut
  }
}
```

## Issues with Vivado Collections

All of Vivado's get_* commands return so called `collections`. Which are basically specialized `list` wrappers, that defer the string materialization as long as possible.

For performance reasons `collections` limit the number of elements they list when converted to a string (this limit is set via the parameter `tcl.collectionResultDisplayLimit` and can be disabled via `set_param tcl.collectionResultDisplayLimit 0`).

Unfortunately the implementation is borken and many commands do not work as expected, below is a list of issues identified:

`$collection` is a place holder for a vivado collection

| Command | Construct | Workaround | Description |
|---------|-----------|------------|-------------|
|`lindex`|`lindex [list $collection]` 0 $x|`lindex [lindex [list $collection] 0] $x`| Tcl allows to use `lindex` on multidimensional lists by specfiying one index for each dimension from which a subelement should be extracted. `lindex` only works with collection if the collection is not wrapped inside a deeper dimension.|
|`lappend`|`lappend myList {*}$collection`|`lappend myList $collection`| Normally lappend expect its arguments as `lappend <nameOfListVar> <firstElement> <secondElement> ... <nThElement>`, thus `lappend myList $otherlist` should result in a list where the last element is `$otherList` and the list unpacking operator `{*}` would be needed to append the elements (rather than the list), for Vivado collections this logic does not hold.|
|`in`,`ni`|`x in $collection`|`set isIn false; foreach item $collection { if {$item eq x} { set isIn true; break } }`|Usually `in`/`ni` test if an element is (not) part of a list, however, due to the `tcl.collectionResultDisplayLimit` this might not work with `collections`|
|`list-indexing single element`|`foreach e $collection-with-only-one-element {}`|If a command returns a single element, wrap it in a list|Usually single elements are considered as a list, for this reason `lindex OK 0 0 ... 0` returns `OK`, however if this is applied to a vivado collection the object decays into a string, i.e. `foreach e [get_* ...] {...}` behaves differently depending on how many elements are returned by `get_* ...`, in case it is more than one element, `e` can be used like an object, but if only a single element is returned, `e` will become a string, operations requiring an object will fail. Tested with `get_nodes`|
|`get_selected_objects`|`get_tiles -of_objects [get_selected_objects]`|Use `get_*` commands whereever possible if you experience crashes|It turns out that Vivado occasionally crashes on valid commands without an appaarent reason. Investigation yielded that if `-of_objects` is used with a collection created by `get_selected_objects` crashes are VERY frequent|

## Undocumented features

### Routing
#### GAP
If a segment is set to `GAP` this allows you to have GAPs in set\_property `ROUTE`/`FIXED_ROUTE` that the router will fill in. This will add `NoTile/GAP` as nodes to the route. There also seem to be `NoTile/NoWire` segments, however their purpose is not yet clear.

### Parameters
Some parameters are not listed when running `list_param`, yet erromessages point to them:

| Property | Warning |
|----------|---------|
|`route.enableGlobalHoldIter`            | WARNING: [Route 35-459] Router was unable to fix hold violation on 848 pins. This could be due to a combination of congestion, blockages and run-time limitations. Resolution: You may try high effort hold fixing by turning on param route.enableGlobalHoldIter |
|`route.enableHoldExpnBailout`           | https://forums.xilinx.com/t5/Welcome-Join/How-to-reduce-router-runtime-in-vivado/td-p/700498 |
|`logicopt.BUFGinsertMaxCountUltrascale`|https://forums.xilinx.com/t5/Implementation/How-to-set-options-in-the-implementation-run/td-p/715358|
|`logicopt.BUFGinsertMaxCount7Series`    |https://forums.xilinx.com/t5/Implementation/How-to-set-options-in-the-implementation-run/td-p/715358|
|`logicopt.thresholdBUFGperRegion`       |https://forums.xilinx.com/t5/Implementation/How-to-set-options-in-the-implementation-run/td-p/715358|

Below is a script adapted from UG904 listing implementation strategies and directives, with slight modifications. The main reason it is here, as it allows proper copy and paste unlike the PDF.
Unfortunately, we are not aware of getting the undocumented parameters listed above, as `list_params` comes up blank.

```tcl
create_project p1 -force -part xc7vx690tffg1761-2

puts "Strategies:\n"
puts "Synthesis:"
join [list_property_value strategy [get_runs synth_1] ] \n
puts "\nImplementation:"
join [list_property_value strategy [get_runs impl_1] ] \n

#get synth_design directives
set run [get_runs synth_1]

foreach s [list synth] {
	puts "${s}_design Directives:"
	puts [join [list_property_value STEPS.${s}_DESIGN.ARGS.DIRECTIVE $run] \n]
}

#get impl directives
set run [get_runs impl_1]

foreach s [list opt place phys_opt route] {
	puts "${s}_design Directives:"
	puts [join [list_property_value STEPS.${s}_DESIGN.ARGS.DIRECTIVE $run] \n]
}

close_project -delete
```


### TCL Commands

| Command | Effect | Note |
|---------|--------|------|
|`send_msg_id`        | Allows to send error messages that are visible in the message pane. `help send_msg_id` in Vivado describes the usage. | In tedtcl ted::errorOut is a function handling fatal errors look at it for example usage.|
|`enable_beta_device`| Enables beta devices. Seems to last only for one open_checkpoint command.|Takes device name (with wildcard *) as parameter|