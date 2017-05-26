#!/usr/local/bin/tcsh -f
# lists the Prv and Next links of all mjl* files in the current working directory
# This might be useful when debugging, even if it is not used in tests directly
if (! $?MUPIP) then # let's make this script usable from outside the test system as well
	setenv MUPIP 	$gtm_exe/mupip
	setenv grep 	grep
endif

set timestamp = `date +%H%M%S`
foreach mjlfile (`ls -rt *.mjl*`)
	set mjlshowoutput = `echo ${mjlfile}_${timestamp} | sed s/mjl_/mjshow_/g`
	echo "-------- Prev/Next links for mjl $mjlfile"
	$MUPIP journal -forward -show=header $mjlfile >& $mjlshowoutput
	$grep "Prev journal file name" $mjlshowoutput
	$grep "Next journal file name" $mjlshowoutput
end
