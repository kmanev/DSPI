namespace eval ::ted::serialize {
	proc serialize {objects} {
		set serialization {}
		
		foreach obj $objects {
			switch [get_property CLASS $obj] {
				pblock {
					lappend serialization pblock [serialize_pblock $obj]
				}
				default {
					#todo:option to degrade this to warning
					ted::utility::errorOut 0 "Object $obj has unknown class [get_property CLASS $obj]. Serialization failed."
				}
			}
		}
		
		return $serialization
	}
	
	proc deserialize {serialization} {
		foreach {objectType description} $serialization {
			#make sure we know the object type
			switch $objectType {
				pblock {
					deserialize_pblock $description
				}
				default {
					#todo:option to degrade this to warning
					ted::utility::errorOut 0 "Objecttype $objectType is unknown. Deserialization failed."
				}
			}
		}
	}
	
	proc serialize_pblock {pblock} {
		set attributes {}
		
		foreach attribute {CONTAIN_ROUTING EXCLUDE_PLACEMENT PARTPIN_SPREADING RESET_AFTER_RECONFIG SNAPPING_MODE} {
			dict set attributes $attributes [get_property $attributes $pblock]
		}
		
		#fix invalid enum value
		if {[dict get $attributes SNAPPING_MODE] eq {}} {
			dict set attributes SNAPPING_MODE OFF
		}
		
		return [dict create                                    \
			name        [get_property NAME   $pblock]      \
			parent      [get_property PARENT $pblock]      \
			ranges      [get_property GRID_RANGES $pblock] \
			attributes  $attributes                        \
			cells       [get_cells -of_objects $pblock]    \
		]
	}
	
	proc deserialize_pblock {pblock_description} {
		set pblock [create_pblock [dict get $pblock_description name] -parent [dict get $pblock_description parent]]
		resize_pblock $pblock -add [dict get $pblock_description ranges]
		
		dict for {property value} [dict get $pblock_description attributes] {
			set_property $property $value $pblock
		}
		
		#fixme do we have to turn cells to objects again
		add_cells_to_pblock $pblock [dict get $pblock_description cells]
		
		return $pblock
	}
}