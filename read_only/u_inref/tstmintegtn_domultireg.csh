#!/usr/local/bin/tcsh -f
#
# Utility script invoked by tstmintegtn.csh to
#
# Do MUPIP INTEG -TN_RESET on *.dat in a loop
# This is necessary because MUPIP INTEG -TN_RESET -REG "*" is not supported 
#	(since TN_RESET is not compatible with REGION qualifier)
#

foreach file (*.dat)
	$MUPIP integ -tn_reset $file
end
