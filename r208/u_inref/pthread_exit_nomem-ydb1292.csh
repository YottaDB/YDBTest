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
echo "# [YDB#1292] A MUPIP JOURNAL worker thread that exits when no more memory can be mapped does not     #"
echo "# abort the process                                                                                  #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo "# glibc's pthread_exit() loads libgcc_s.so.1 the first time a thread calls it. If no more memory can be"
echo '# mapped at that point, the load fails and glibc aborts the process with "libgcc_s.so.1 must be'
echo '# installed for pthread_exit to work". MUPIP JOURNAL -RECOVER and -ROLLBACK run one worker thread per'
echo "# region, which call pthread_exit() when the process is asked to stop (MUPIP STOP) or when they get an"
echo "# error."
echo "#"
echo "# This subtest stops a MUPIP JOURNAL -RECOVER -BACKWARD while its worker threads run, limits its"
echo "# address space to what it is using, and sends it SIGTERM. Its worker threads then call pthread_exit()."
echo "#"
echo "# Without the fix, a Release build prints WRONG and MUPIP aborts with that glibc message. A Debug build"
echo "# passes either way, since it loads libgcc_s.so.1 at startup to record which code allocates each block"
echo "# of memory."
echo

echo "# Journaling is set up explicitly below, so do not let dbcreate.csh enable it at random"
setenv gtm_test_jnl NON_SETJNL
echo "# Nothing may load libgcc_s.so.1 at MUPIP startup, or the test passes without the fix, so use M mode"
echo "# (in UTF-8 mode, the ICU libraries depend on libgcc_s.so.1) and no gtmdbglvl (which turns on the same"
echo "# allocation recording as a Debug build)"
$switch_chset M >&! switch_chset_m.out
unsetenv gtmdbglvl ydb_dbglvl
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
echo '# Command : $ydb_dist/yottadb -run %XCMD '\''for i=1:1:100000 set ^a(i)=$j(i,100),^b(i)=$j(i,100),^x(i)=$j(i,100)'\'
$ydb_dist/yottadb -run %XCMD 'for i=1:1:100000 set ^a(i)=$j(i,100),^b(i)=$j(i,100),^x(i)=$j(i,100)'
$gtm_tst/com/backup_dbjnl.csh bak "*.gld *.dat *.mjl*" cp nozip

set file = ydb1292_stopthreads
$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/$file.c >& $file.cc.out
if ($status) then
	echo "# Compiling $file.c failed. Output follows."
	cat $file.cc.out
endif
$gt_ld_linker $gt_ld_options_common $gt_ld_option_output $file $file.o $gt_ld_sysrtns $gt_ld_syslibs >& $file.map
if ($status) then
	echo "# Linking $file failed. Output follows."
	cat $file.map
endif
echo

echo "# Use one worker thread per region"
setenv ydb_mupjnl_parallel 0
unsetenv gtm_mupjnl_parallel
# A glibc fatal error goes to the terminal, if there is one, unless this is set
setenv LIBC_FATAL_STDERR_ 1

echo "# Stage 1 : run MUPIP JOURNAL -RECOVER -BACKWARD, stop it once it has worker threads, limit its address"
echo "#           space to what it is using, send it SIGTERM and let it continue"
echo '# Command : ./'$file' recover1.out $gtm_exe/mupip journal -recover -backward -since=<time before the updates> "*"'
./$file recover1.out $gtm_exe/mupip journal -recover -backward "-since=$since" "*" >&! $file.out
cat $file.out
echo "#   expect it to be stopped while it had worker threads"
$grep -q "^Stopped the MUPIP process while it had worker threads" $file.out
if ($status) then
	echo "WRONG : it was not stopped while it had worker threads, so this stage tested nothing"
else
	echo "PASS : it was stopped while it had worker threads"
endif
echo "#   expect libgcc_s to be mapped into it before its worker threads exit"
$grep -q "^libgcc_s is mapped into it" $file.out
if ($status) then
	echo "WRONG : libgcc_s was not mapped into it"
else
	echo "PASS : libgcc_s was mapped into it"
endif
echo "#   expect no glibc message about libgcc_s.so.1"
$grep "libgcc_s.so.* must be installed" recover1.out
if ($status) then
	echo "PASS : no glibc message about libgcc_s.so.1"
else
	echo "WRONG : glibc aborted MUPIP because it could not load libgcc_s.so.1"
endif
echo "#   expect MUPIP to exit with status 241, the status of %YDB-F-FORCEDHALT"
$grep -q "^MUPIP exited with status 241" $file.out
if ($status) then
	echo "WRONG : MUPIP did not exit with status 241"
else
	echo "PASS : MUPIP exited with status 241"
endif
$gtm_tst/com/check_error_exist.csh recover1.out YDB-F-FORCEDHALT YDB-E-MUNOACTION
echo

echo "# Stage 2 : run the same backward recovery again with no stop, which completes the interrupted one"
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
