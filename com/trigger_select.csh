#!/usr/local/bin/tcsh -f

# don't do anything if triggers are not enabled
if ( "1" != "$gtm_test_trigger" ) then
	exit 0
endif

# was a global or name passed in as an arg?
set gvn=""
if ("" != $2) then
	set gvn="=$2"
endif

# if a file name is supplied, use the first form otherwise use
# the second since the -select demands an input file name
if ("" != "$1") then
	$MUPIP trigger -select$gvn $1
	set zstatus=$status
else
	echo "" | $MUPIP trigger -select$gvn
	set zstatus=$status
	echo ""
endif

# rethrow any errors from mupip
exit $zstatus
