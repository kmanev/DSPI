package require fileutil

namespace eval ted::parser {
	namespace export           \
		first              \
		last               \
		has                \
		timingSummary      \
		meetsTiming        \
		closerToMeetTiming
	##
	# Get the first line starting with needle.
	#
	# @param needle         string the line should start with
	# @param haystack       data string to search in
	#
	# @return               substring starting from the first occurence of $needle to the end of line
	proc first {needle haystack} {
		set start [string first $needle $haystack]
		return [string range $haystack [expr {[string last \n $haystack $start]+1}] [string first \n $haystack\n $start]]
	}

	##
	# Get the last line starting with needle.
	#
	# @param needle         string the line should start with
	# @param haystack       data string to search in
	#
	# @return               substring starting from the last occurence of $needle to the end of line
	proc last {needle haystack} {
		set start [string last $needle $haystack]
		return [string range $haystack [expr {[string last \n $haystack $start]+1}] [string first \n $haystack\n $start]]
	}

	##
	# Check if a substring exists
	#
	# @param needle         string to look for
	# @param haystack       data string to search in
	#
	# @return               boolean indicating weather needle was found in haystack or not

	proc has {needle haystack} {
		return [expr {[string first $needle $haystack] != -1}]
	}

	##
	# Extract timing summary data from a string into a dict
	#
	# @param summary        timing summary string from vivado report
	#
	# @return               dict with wns, tns, whs, ths
	proc timingSummary {summary} {
		set whs {}
		set ths {}
		regexp {WNS=(-?\d+(?:.\d+)) \| TNS=(-?\d+(?:.\d+))(?: \| WHS=(-?\d+(?:.\d+)) \| THS=(-?\d+(?:.\d+)))?} $summary dummy wns tns whs ths
		return [dict create wns $wns tns $tns whs $whs ths $ths]
	}
	
	##
	#
	#
	# As we are only looking at total slacks, this will never be better than 0 (i.e. further improvements after a certain point go unnoticed)
	#proc totalTimingDiff {t1 t2} {
	#	expr {[dict get t2 tns] - [dict get t1 tns]}
	#	return []
	#}
	
	proc meetsTiming {timing} {
		return [expr {[dict get $timing tns] == 0 && [dict get $timing ths] == 0}]
	}
	
	##
	# Checks if one of the timings has improved
	#
	# checks if we are closer to timing closure, to check on actual timing improvements, we
	# would have to check on other methods, as this only looks at the OR if one individual
	# timing gets better (ths, tns, whs, wns). Returns true even if some timings degenerated as
	# long as another timing improved. For this even a timing that met timing before is considered an
	# improvement, even if a timing that causes failure degenerated in the step.
	#
	# @param t1         initial timing
	# @param t2         new timing
	#
	# @return           boolean indicating if tns ths wns or ths has improved
	proc closerToMeetTiming {t1 t2} {
		return [expr {[dict get $t2 tns] > [dict get $t1 tns] || [dict get $t2 ths] > [dict get $t1 ths] || [dict get $t2 wns] > [dict get $t1 wns] || [dict get $t2 whs] > [dict get $t1 whs]}]
	}
}
