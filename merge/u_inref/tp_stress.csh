#!/usr/local/bin/tcsh -f
if ($tst_buffsize < 16000000 ) then
      setenv tst_buffsize 16000000
endif   
setenv gtm_test_parms "1,7"
setenv gtm_test_maxdim 5

if ($?gtm_test_replay) then
	source $gtm_test_replay
else
	# Randomly choose to trigger replication connection breakage errors (using white-box testing)
	# by forcing a source server heartbeat to not be acknowledged by the receiver server.
	@ wboxtestchoice = `$gtm_exe/mumps -run rand 4`
	echo "@ wboxtestchoice = $wboxtestchoice" >>&! settings.csh
endif

# if wboxtestchoice is non-zero, set environment variables to enable white-box testing of abnormal situations
if ($wboxtestchoice == 1) then
	source $gtm_tst/com/wbox_test_prepare.csh "REPL_HEARTBEAT_NO_ACK" 1 1 settings.csh
else if ($wboxtestchoice == 2) then
	source $gtm_tst/com/wbox_test_prepare.csh "REPL_TR_UNCMP_ERROR" 50 1 settings.csh
else if ($wboxtestchoice == 3) then
	source $gtm_tst/com/wbox_test_prepare.csh "REPL_TEST_UNCMP_ERROR" 1 1 settings.csh
endif

source $gtm_tst/com/dbcreate.csh mumps 7 255 1010 4096 4096 4096
$gtm_exe/mumps -dir << aaa
d ^MRGITP
halt
aaa
$gtm_tst/com/dbcheck.csh  -extr
cat *.mje*
