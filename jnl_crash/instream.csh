#!/usr/local/bin/tcsh -f
#
###################################
### instream.csh for jnl_crash test ###
### Layek:9/17/2001: Now test does not force journal switch since 
### "C9A07-001552-Rework-journali..." fixes are in CMS
###################################
#
setenv gtm_test_crash 1
if($?test_replic) then
	echo "jnl_crash test runs as Non-Replication only!"
	exit
endif
if ($LFE != "E") then
	echo "jnl_crash test runs as Extended test only!"
else
	setenv subtest_list "crash_rec_for1 crash_rec_for2 crash_rec_back2 C9B11-001794"
	setenv subtest_exclude_list ""
# 	filter out subtests that cannot pass with MM
	if ("MM" == $acc_meth) then
		setenv subtest_exclude_list "crash_rec_back2 C9B11-001794"
	endif
	# C9B11-001794 test does kill -9 followed by <ipcrm -s sem> but NO <ipcrm -m shm>. This will leave the database in an
	# inconsistent state. GT.M on HPUX/HPPA implements various database latches using a microlock that takes a few 
	# instructions to obtain and release. If a process gets shot by a kill -9 during that small window, there is no recovery
	# logic currently built in it. Trying to do MUPIP RUNDOWN on that causes assert failures in aswp.c. See mrep signature
	# <C9H04_002844_Assert_fail_ASWP_line_68_on_HPUX> for more details. Fixing the HP microlock to have recovery logic built 
	# in is non-trivial. Hence disabling this subtest for now.
	# Note that although kill -9 with NO_IPCRM is not supported on all unix, this test is NOT disabled other unix platforms 
	# because of the fact that the test does MUPIP RUNDOWN after a kill -9. Only on HPPA due to a micro-locks failing in a
	# small time window causes even MUPIP RUNDOWN unusable.
	if ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype") then
		setenv subtest_exclude_list "$subtest_exclude_list C9B11-001794"
	endif
	echo "JNL CRASH test starts..."
	$gtm_tst/com/submit_subtest.csh
	echo "JNL CRASH test DONE."
endif
#
##################################
###          END               ###
##################################


