#!/usr/local/bin/tcsh -f

if !($?gtm_test_replay) then
	@ rand = `$gtm_exe/mumps -run rand 2`
	if (0 == $rand) then
		setenv idemp_rolrec ROLLBACK
	else
		setenv idemp_rolrec RECOVER
	endif
	echo "# idemp_rolrec chosen in idemp_rollback_or_recover.csh "	>>&! settings.csh
	echo "setenv idemp_rolrec $idemp_rolrec"			>>&! settings.csh
endif
$gtm_tst/$tst/u_inref/rolrec_intr_stop_idemp.csh $idemp_rolrec IDEMP . . 1
