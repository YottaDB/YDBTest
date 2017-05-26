#!/usr/local/bin/tcsh -f
#
# returns 1 if $gtm_exe points to a version that is <= V4.4-004
# returns 0 otherwise
#
# post V4.4-004, the gde format was changed.
# this script is useful in the filter test to determine which of the two gde formats the current gtm_exe understands.
#
if ( "V4" == `echo $gtm_exe:h:t|cut -c1-2` ) then
	exit 1
else
	exit 0
endif
