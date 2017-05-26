#!/usr/local/bin/tcsh -f

if ($?acc_meth) then
	if ("MM" == $acc_meth) then
		if ($?tst_jnl_str) then
			# Change before to nobefore, but if it already was nobefore, we now have nonobefore so change it, too.
			set tstjnlstr = `echo $tst_jnl_str | sed 's/before/nobefore/g; s/nonobefore/nobefore/g'`
			setenv tst_jnl_str $tstjnlstr
		else
			setenv tst_jnl_str "-journal=enable,on,nobefore"
		endif
		setenv gtm_test_jnl_nobefore 1
		setenv jnl_forced
		echo "# gtm_test_jnl_nobefore is modified by mm_nobefore.csh"	>> settings.csh
		echo "setenv gtm_test_jnl_nobefore 1"			>> settings.csh
		echo "# jnl_forced is modified by mm_nobefore.csh"	>> settings.csh
		echo "setenv jnl_forced"				>> settings.csh
		# The randomly chosen value is changed, so lets log the modified tst_jnl_str in settings.csh
		echo "# tst_jnl_str is modified by mm_nobefore.csh"	>> settings.csh
		echo "setenv tst_jnl_str $tst_jnl_str"			>> settings.csh
	endif
endif

