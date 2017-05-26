#!/usr/local/bin/tcsh
#
# D9I03-002676 [Narayanan] Nested STACKCRIT errors & Incorrect $ZSTATUS reports
#

$gtm_tst/com/dbcreate.csh mumps

foreach realtnum (1 2 3 4)
	if ($realtnum == 3) then
		set tnum = 2
		set popstr = "WITH gtm_ztrap_form = popadaptive"
		setenv gtm_ztrap_form popadaptive
		# Run test2 (in turn TestTrap1) with popadaptive setting.
	else
		set tnum = $realtnum
		set popstr=""
		unsetenv gtm_ztrap_form
	endif
	echo "---------------------------------------------------------------------------------------------------"
	echo "          Testing mumps -run test${tnum}^d002676 $popstr "
	echo "---------------------------------------------------------------------------------------------------"
	echo ""
	$gtm_dist/mumps -run test${tnum}^d002676
	echo ""
	echo "---------------------------------------------------------------------------------------------------"
	echo "          Testing do test${tnum}^d002676 $popstr "
	echo "---------------------------------------------------------------------------------------------------"
	echo ""
	$GTM << GTM_EOF
		do test${tnum}^d002676
GTM_EOF
	echo ""
end

$gtm_tst/com/dbcheck.csh
