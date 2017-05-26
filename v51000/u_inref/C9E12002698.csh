#!/usr/local/bin/tcsh
#
# C9E12-002698 KILL of globals in TP transactions cause database damage and assert failures
#

# allocate more global buffers to reduce the chances of the test failing because secshr_db_clnup could not find a free buffer
$gtm_tst/com/dbcreate.csh mumps 1 -key=255 -rec=480 -glo=2048

if ($?gtm_test_replay) then
	source $gtm_test_replay
else
	# Test with and without journaling.
	@ jnlchoice = `$gtm_exe/mumps -run rand 2`
	echo "setenv jnlchoice $jnlchoice" >>&! settings.csh

	# Randomly choose to trigger errors in the middle of commit (using white-box testing)
	@ wboxtestchoice = `$gtm_exe/mumps -run rand 2`
	echo "@ wboxtestchoice = $wboxtestchoice" >>&! settings.csh
endif

if ($wboxtestchoice == 1) then
	# set environment variables to enable white-box testing of cache recovery
	source $gtm_tst/com/wbox_test_prepare.csh "CACHE_RECOVER" 10000 100 settings.csh
endif

if ($jnlchoice == 1) then
	$MUPIP set $tst_jnl_str -region "*" >>&! jnl.log
endif

# Want MUPIP REORG to be running concurrently with GT.M processes
# Start reorg processes in background
$gtm_tst/com/bkgrnd_reorg.csh >& bkgrnd_reorg.out
#
# Start GT.M processes
$GTM << GTM_EOF
	do ^c002698
GTM_EOF

#
# Shut down reorg processes
$gtm_tst/com/close_reorg.csh >& close_reorg.out

$gtm_tst/com/dbcheck.csh
