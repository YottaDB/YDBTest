#!/usr/local/bin/tcsh 

# local
source $gtm_tst/$tst/u_inref/cre_coll_sl.csh

if ($?test_replic) then
	# replic
	# NOT TESTED
	if ($tst_org_host != $tst_remote_host) then
		$gtm_tst/com/send_env.csh
		$gtm_tst/$tst/u_inref/cre_coll_sl.csh
	endif
else if ("GT.CM" == $test_gtm_gtcm) then
	#GT.CM
	$gtm_tst/com/send_env.csh
	$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM ; cd SEC_DIR_GTCM; $gtm_tst/$tst/u_inref/cre_coll_sl.csh"
endif
