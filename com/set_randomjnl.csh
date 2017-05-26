#!/usr/local/bin/tcsh -f
# randomly enables journaling
# This script is called by dbcreate.csh
# This is automatically done for all the v4* and v5* tests.
#	-> unset the env.variable gtm_test_enable_randomjnl in v4* and v5* subtests to disable this.
# 	-> set the env.variable gtm_test_enable_randomjnl in any subtest/test to enable this feature

if ($?gtm_test_replay) then
	# rand_jnl_enable will already be in the environment due to sourcing of $gtm_test_replay
else
	setenv rand_jnl_enable `$gtm_exe/mumps -run rand 2`
	#set rand_jnl_option = "$tst_jnl_str"
	# Log all the randomization in settings file
	# rand_jnl_enable 0/1

	cat >> settings.csh << EOF
# Randomly decide whether to enable journaling
setenv rand_jnl_enable $rand_jnl_enable
# If decided to enable journaling, pick up journaling options from tst_jnl_str

EOF

endif

# If $?gtm_custom_errors is defined at this point, then MUPIP SET -JOURNAL done below will try to open $gtm_repl_instance (as part
# of jnlpool_init) to setup the journal pool. But, the file pointed to by $gtm_repl_instance doesn't exist at this point because
# MUPIP REPLIC -INSTANCE_CREATE is not yet done. So, temporarily undefine $gtm_custom_errors to avoid FTOKERR/ENO2 errors.
unsetenv gtm_custom_errors
if ($rand_jnl_enable) then
	echo "# `date`" >>&! set_randomjnl.out
	$MUPIP set $tst_jnl_str -region "*" >>&! set_randomjnl.out
endif

