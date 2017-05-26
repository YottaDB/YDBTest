#!/usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 5 255 4096 8192
$echoline
echo "Invalid trigger names"
$gtm_exe/mumps -run invalidnames
foreach bad ( bad*check*.trg )
	$MUPIP trigger -trig=$bad -noprompt >>& invalidnametest.txt
	if (0 == $?) then
		echo "$bad FAIL"
		$head -n1 $bad | tee -a invalid.fail
	endif
	rm $bad
end
echo "Failures `$grep -c '^;' invalid.fail`"
echo "Number of times MUPIP rejected invalid names `$grep -c GTM-E-MUNOACTION invalidnametest.txt`"
$gtm_exe/mumps -run run^invalidnames

$gtm_tst/com/dbcheck.csh -extract
