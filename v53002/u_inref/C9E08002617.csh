#!/usr/local/bin/tcsh
#
# C9E08-002617 [Narayanan] GTMASSERT in get_symb_line.c in some $ETRAP testcases
#

$gtm_tst/com/dbcreate.csh mumps
cp $gtm_tst/$tst/inref/test*.m .	# needed by test1^c002617
unsetenv gtm_etrap

foreach realtnum (0 1 2 3 4 5 6)
	if ($realtnum == 6) then
		set tnum = 5
		set popstr = "WITH gtm_ztrap_form = popadaptive"
		setenv gtm_ztrap_form popadaptive
		# Run test5 (in turn TestTrap) with popadaptive setting. In V53001, it used to assert fail.
	else
		set tnum = $realtnum
		set popstr=""
		unsetenv gtm_ztrap_form
	endif
	echo "---------------------------------------------------------------------------------------------------"
	echo "          Testing mumps -run test${tnum}^c002617 $popstr "
	echo "---------------------------------------------------------------------------------------------------"
	echo ""
	$gtm_dist/mumps -run test${tnum}^c002617
	echo ""
	echo "---------------------------------------------------------------------------------------------------"
	echo "          Testing do test${tnum}^c002617 $popstr "
	echo "---------------------------------------------------------------------------------------------------"
	echo ""
	$GTM << GTM_EOF
		do test${tnum}^c002617
GTM_EOF
	echo ""
end
# Move the GTM_FATAL_ERROR.* files, so that error catching mechanism do not show invalid failures
foreach file ( `ls -l GTM_FATAL_ERROR* | $tst_awk '{print $NF}'` )
	mv $file `echo $file | $tst_awk -F 'GTM_' '{print $2}'`
end
$gtm_tst/com/dbcheck.csh
