#!/usr/local/bin/tcsh -f
touch ./ver.txt; \rm ./ver.txt
$gtm_exe/mumps -run testver
set testver=`cat ./ver.txt | $tst_awk '{print $2}' | sed 's/\.//g' | sed 's/\-//g'`
if ($testver == $gtm_verno) then
	echo "Passed the version test"
else
	echo "Should be $gtm_verno but is $testver"
endif
