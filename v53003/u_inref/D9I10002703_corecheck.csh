#!/usr/local/bin/tcsh -f

# Helper script for D9I10002703 subtest
# Assumes <envvar> environment variable is appropriately set
# $1 is the image of interest i.e. "gtm" or "dse" etc.

set imagevar = $1
# Check for corefiles
set corefile=${envvar}_CORE.lis
find . -type f -a \( -name 'core*' -o -name 'gtmcore*' \) -print >&! $corefile
set stat = $status
if ($stat) then
	echo "TEST-E-ERRORS_FIND, Could not determine if core files were generated for envvar=<$envvar> : imagevar=<$imagevar>"
	echo $stat
	cat $corefile
else if (! -z $corefile) then
	echo "TEST-E-CORES, Core files found for envvar=<$envvar> : imagevar=<$imagevar>"
	cat $corefile
	chmod a+r `cat $corefile`
	foreach file (`cat $corefile`)
		mv $file $file:h/${imagevar}_${envvar}_$file:t
	end
endif
