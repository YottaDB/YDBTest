#!/usr/local/bin/tcsh -f

if !($?gtm_test_replay) then
	@ rand = `$gtm_exe/mumps -run rand 2`
	if (0 == $rand) then
		setenv mupipstop_rolrec ROLLBACK
	else
		setenv mupipstop_rolrec RECOVER
	endif
	echo "# mupipstop_rolrec chosen in mupipstop_rollback_or_recover.csh "	>>&! settings.csh
	echo "setenv mupipstop_rolrec $mupipstop_rolrec"			>>&! settings.csh
endif
$gtm_tst/$tst/u_inref/rolrec_intr_stop_idemp.csh $mupipstop_rolrec STOP . . 1
$gtm_tst/$tst/u_inref/check_timing.csh
