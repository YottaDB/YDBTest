#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#----------------------------------------------------------------------------------------------------#"
echo "# [YDB#1309] MUPIP JOURNAL -RECOVER stopped while it cannot create a worker thread terminates with   #"
echo "# FORCEDHALT, and its other worker threads get no errors                                             #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo "# MUPIP JOURNAL -RECOVER and -ROLLBACK run one worker thread per region. If MUPIP cannot create one of"
echo "# them, it issues SYSCALL for pthread_create() while the worker threads it did create are still"
echo "# running. A MUPIP STOP that arrives at that point must wait until those threads are done."
echo "#"
echo "# This subtest LD_PRELOADs ydb1309_threadfail, which makes the third worker thread fail to be created"
echo "# after it sends MUPIP SIGTERM, and slows the reads of the worker threads so that they are still"
echo "# reading their journal files at that point."
echo "#"
echo "# Without the fix, MUPIP runs its exit handling in the middle of the SYSCALL message, so that message"
echo "# lacks its second line (ENO11) and FORCEDHALT follows on the same line. The exit handling also closes"
echo "# the journal files the worker threads read, so depending on timing they issue JNLREAD with ENO9"
echo "# (Bad file descriptor) in a Release build, or fail an assert in a Debug build."
echo

echo "# Journaling is set up explicitly below, so do not let dbcreate.csh enable it at random"
setenv gtm_test_jnl NON_SETJNL
echo "# No asynchronous IO, whose worker thread would count as a thread of the MUPIP process"
setenv gtm_test_asyncio 0
echo "# BEFORE_IMAGE journaling, which backward recovery needs, needs the BG access method"
source $gtm_tst/com/gtm_test_setbgaccess.csh
source $gtm_tst/com/gtm_test_setbeforeimage.csh

echo "# Create a database with regions AREG, BREG and DEFAULT"
$gtm_tst/com/dbcreate.csh mumps 3 >&! dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif
echo '# Command : $MUPIP set -journal="enable,on,before" -region "*"'
$MUPIP set -journal="enable,on,before" -region "*" >&! mupip_set_jnl.out
if ($status) then
	echo "# MUPIP SET failed. Output follows."
	cat mupip_set_jnl.out
endif

# The time before the updates, for -since= below, so that backward recovery processes every update
set since = `date +"%d-%b-%Y %H:%M:%S"`
sleep 1
echo '# Command : $gtm_dist/mumps -run %XCMD '\''for i=1:1:100000 set ^a(i)=$j(i,100),^b(i)=$j(i,100),^x(i)=$j(i,100)'\'
$gtm_dist/mumps -run %XCMD 'for i=1:1:100000 set ^a(i)=$j(i,100),^b(i)=$j(i,100),^x(i)=$j(i,100)'

echo '# Command : compile and link ydb1309_threadfail.c into libydb1309_threadfail'
$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/ydb1309_threadfail.c -o ydb1309_threadfail.o >&! threadfail_cc.out
$gt_ld_shl_linker ${gt_ld_option_output}libydb1309_threadfail${gt_ld_shl_suffix} $gt_ld_shl_options ydb1309_threadfail.o $gt_ld_sysrtns -ldl >&! threadfail_ld.out
if (-e libydb1309_threadfail${gt_ld_shl_suffix}) then
	echo "PASS : libydb1309_threadfail was built"
else
	echo "WRONG : libydb1309_threadfail was not built - see threadfail_cc.out and threadfail_ld.out"
	cat threadfail_cc.out threadfail_ld.out
endif
echo

echo "# Use one worker thread per region"
unsetenv ydb_mupjnl_parallel
setenv gtm_mupjnl_parallel 0

echo "# Stage 1 : run MUPIP JOURNAL -RECOVER -BACKWARD with libydb1309_threadfail preloaded"
echo '# Command : env LD_PRELOAD=./libydb1309_threadfail'${gt_ld_shl_suffix}' $MUPIP journal -recover -backward -since=<time before the updates> "*"'
env LD_PRELOAD=./libydb1309_threadfail${gt_ld_shl_suffix} $MUPIP journal -recover -backward "-since=$since" "*" >&! recover1.out
set mupip_status = $status
echo "#   expect the third worker thread to fail to be created after SIGTERM was sent"
$grep -q "^ydb1309_threadfail : sent SIGTERM and failed pthread_create() for worker thread 3" recover1.out
if ($status) then
	echo "WRONG : no worker thread failed to be created, so this stage tested nothing"
else
	echo "PASS : the third worker thread failed to be created after SIGTERM was sent"
endif
echo "#   expect MUPIP to exit with status 241, the status of %YDB-F-FORCEDHALT"
if (241 == $mupip_status) then
	echo "PASS : MUPIP exited with status 241"
else
	echo "WRONG : MUPIP exited with status $mupip_status, expected 241"
endif
echo "#   expect exactly these messages, each at the start of a line and in this order : SYSCALL for"
echo "#   pthread_create() followed by its ENO11 (Resource temporarily unavailable), FORCEDHALT and MUNOACTION"
set expected = "%YDB-E-SYSCALL %SYSTEM-E-ENO11 %YDB-F-FORCEDHALT %YDB-E-MUNOACTION"
set actual = `$grep -oE '^%[A-Z]+-[EFW]-[A-Z0-9]+' recover1.out`
set actual_all = `$grep -oE '%[A-Z]+-[EFW]-[A-Z0-9]+' recover1.out`
if (("$expected" == "$actual") && ("$expected" == "$actual_all")) then
	echo "PASS : SYSCALL, ENO11, FORCEDHALT and MUNOACTION, each at the start of a line"
else
	echo "WRONG : expected [$expected], got [$actual_all], of which these start a line : [$actual]"
endif
# The SYSCALL message names the source file and line of the call, and is followed by the ENO11 (EAGAIN) message
# for it. Both were checked above, so remove them. Keep the output as it was in recover1_all.outx.
cp recover1.out recover1_all.outx
sed -i -e '/^%YDB-E-SYSCALL, Error received from system call pthread_create() /d' -e '/^%SYSTEM-E-ENO11, /d' recover1.out
$gtm_tst/com/check_error_exist.csh recover1.out YDB-F-FORCEDHALT YDB-E-MUNOACTION
echo

echo "# Stage 2 : run the same backward recovery again with no preload, which completes the interrupted one"
echo '# Command : $MUPIP journal -recover -backward -since=<time before the updates> "*"'
$MUPIP journal -recover -backward "-since=$since" "*" >&! recover2.out
$grep -q "YDB-S-JNLSUCCESS" recover2.out
if ($status) then
	echo "WRONG : the recovery did not succeed. Output follows."
	cat recover2.out
else
	echo "PASS : %YDB-S-JNLSUCCESS"
endif
echo

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo "# Done"
