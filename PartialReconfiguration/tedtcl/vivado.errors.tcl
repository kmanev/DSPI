namespace eval ::ted::vivado {
	set ERROR_TAG_INDEX     0
	set ERROR_CODE_INDEX    1
	set ERROR_MESSAGE_INDEX 2
	
	# tag errorCode message
	set errorList [list \
		[list placer.failed.placeAll		{Common 17-69}		{Command failed: Placer could not place all instances}] \
	]
	
	##
	# Get an error description by tag.
	#
	# @param tag    tag to search for
	#
	# @return       errordescritpion (tuple<tag, code, message>)
	proc getErrorByTag {tag} {
		return [lsearch -inline -index $::ted::vivado::ERROR_TAG_INDEX -exact $::ted::vivado::errorList $tag]
	}
	
	##
	# Get an error code by tag.
	#
	# Use this to hide dependance on error messages when filtering for error messages.
	# example: check if placer failed to place all instances
	#     get_msg_config -id [::ted::vivado::getErrorCodeByTag placer.failed.placeAll] -count
	#
	# @param tag    tag to search for
	#
	# @return       errorcode
	proc getErrorCodeByTag {tag} {
		return [lindex [::ted::vivado::getErrorByTag $tag] $::ted::vivado::ERROR_CODE_INDEX]
	}
	
	##
	# Get an error description by code.
	#
	# @param code    code to search for
	#
	# @return       errordescritpion (tuple<tag, code, message>)
	proc getErrorByCode {code} {
		return [lsearch -inline -index $::ted::vivado::ERROR_TAG_INDEX -exact $::ted::vivado::errorList $code]
	}
}