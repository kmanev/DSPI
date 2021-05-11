# this file allows you to Globally enable debug in tedtcl for ALL places you use it.
# If you want to enable debug for only some projects, put the ted::DEBUG::enableDebug 
# commands in a file that you source in the beginning of those projects.
#
#Examples:
#
#During development you might want to use these lines in the function to test
# ted::DEBUG::debugThis 1
# ted::DEBUG::debugThis 1 hideUnselected
#
#Generally you should use the following in this file to enable Debug
# ted::DEBUG::enableDebug ted::selectors::selectOutline
# ted::DEBUG::enableDebug ted::selectors::selectOutline 1 hideUnselected