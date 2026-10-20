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

echo "#-----------------------------------------------------------------------------------------------#"
echo "# [#1310] A DBIOERR that names the failing asyncio system call is issued in full                #"
echo "#-----------------------------------------------------------------------------------------------#"
echo

# When wcs_wtstart() fails to write a database block, it calls wcs_wterror(), which sends DBIOERR to the
# operator log on the 1st, 101st, ... failure. If the failing write was an asyncio one and the aio shim
# recorded which system call failed (aio_shim_errstr), wcs_wterror() sends DBIOERR followed by SYSCALL naming
# that call. That send_msg_csa() call declared one argument more than it passed, so send_msg_va() read a
# value from beyond the end of its argument list and used it as a FAO count. On a Debug build that value
# fails the "fao_count > MAX_FAO_PARMS" check with an assert in send_msg.c, and the message never reaches
# the operator log. On a pro build what happens depends on that value.
#
# v60000/dbioerr reaches wcs_wterror() through WBTEST_WCS_WTSTART_IOERR (65), but reaches the SYSCALL form
# only on the rare runs where asyncio is randomly on AND an io_submit() happens to fail first. This subtest
# makes both happen every time:
#   1. The database is created with -asyncio.
#   2. ydb1310_iosubmit.c is LD_PRELOADed to make every io_submit() fail with EAGAIN. aio_shim_write() then
#      sets aio_shim_errstr to "io_submit()".
#   3. WBTEST_WCS_WTSTART_IOERR (65) then replaces that EAGAIN with ENOENT, which wcs_wterror() reports as a
#      DBIOERR, together with SYSCALL because aio_shim_errstr is set.
#
# White box cases exist only in a Debug build, so this subtest is excluded on pro (see instream.csh).

# Turn off statshare as in v60000/dbioerr, so the only database file is the one this subtest checks
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare
# ASYNCIO requires BG, does not go with V4 database formats, and needs a block size that is a multiple of 4096
source $gtm_tst/com/gtm_test_setbgaccess.csh
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_spanreg 0

echo '# Stage 1 : create an ASYNCIO database and build the library that makes io_submit() fail'
echo '# Command : $gtm_tst/com/dbcreate.csh mumps -block_size=4096 -asyncio'
$gtm_tst/com/dbcreate.csh mumps -block_size=4096 -asyncio >&! dbcreate.out
if (0 == $status) then
	echo "PASS : the database was created"
else
	echo "WRONG : dbcreate.csh failed - see dbcreate.out"
	cat dbcreate.out
endif

echo '# Command : $DSE dump -fileheader'
$DSE dump -fileheader >&! dse_dump.out
$grep -q 'Async IO  *ON' dse_dump.out
if (0 == $status) then
	echo "PASS : the database file header shows Async IO ON"
else
	echo "WRONG : the database file header does not show Async IO ON - see dse_dump.out"
	$grep 'Async IO' dse_dump.out
endif

echo '# Command : compile and link ydb1310_iosubmit.c into libydb1310_iosubmit'
$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/ydb1310_iosubmit.c -o ydb1310_iosubmit.o >&! iosubmit_cc.out
$gt_ld_shl_linker ${gt_ld_option_output}libydb1310_iosubmit${gt_ld_shl_suffix} $gt_ld_shl_options ydb1310_iosubmit.o $gt_ld_sysrtns -ldl >&! iosubmit_ld.out
if (-e libydb1310_iosubmit${gt_ld_shl_suffix}) then
	echo "PASS : libydb1310_iosubmit was built"
else
	echo "WRONG : libydb1310_iosubmit was not built - see iosubmit_cc.out and iosubmit_ld.out"
	cat iosubmit_cc.out iosubmit_ld.out
endif
echo

echo '# Stage 2 : update the database while every asyncio write fails, so the flush timer reports DBIOERR'
# Start of the syslog window searched below (local time, as com/getoper.csh expects)
set syslog_start = `date +"%b %e %H:%M:%S"`
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 65	# WBTEST_WCS_WTSTART_IOERR
setenv gtm_white_box_test_case_count 1
echo '# Command : env LD_PRELOAD=./libydb1310_iosubmit'${gt_ld_shl_suffix}' $gtm_dist/mumps -run %XCMD '"'"'for i=1:1:10  hang 1  set ^a(i)=$j(i,10)'"'"
env LD_PRELOAD=./libydb1310_iosubmit${gt_ld_shl_suffix} $gtm_dist/mumps -run %XCMD 'for i=1:1:10  hang 1  set ^a(i)=$j(i,10)' >&! updates.out
# White box testing is enabled by the mere PRESENCE of the enable variable, so all three must be unsetenv'd
unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number
unsetenv gtm_white_box_test_case_count

$grep -q 'YDB-F-ASSERT' updates.out
if (0 != $status) then
	echo "PASS : the process did not fail an assert"
else
	echo "WRONG : the process failed an assert - see updates.out"
	$grep 'YDB-F-ASSERT' updates.out
endif
# The write errors are also reported when the process runs the database down at exit
$gtm_tst/com/check_error_exist.csh updates.out DBIOERR ENO2 YDB-E-NOTALLDBRNDWN YDB-E-GVRUNDOWN >&! check_updates.logx
if (0 == $status) then
	echo "PASS : the process reported DBIOERR, ENO2, NOTALLDBRNDWN and GVRUNDOWN at exit"
else
	echo "WRONG : expected DBIOERR, ENO2, NOTALLDBRNDWN and GVRUNDOWN in updates.out - see check_updates.logx"
	cat check_updates.logx
endif
echo

echo '# Stage 3 : the DBIOERR in the operator log carries the SYSCALL for io_submit() and then ENO2'
# The operator log shows the database file by its real path, which can differ from `pwd` when the test area is
# reached through a symbolic link
set dbpath = `realpath mumps.dat`
echo '# Command : $gtm_tst/com/getoper.csh "$syslog_start" "" syslog.txt "" "YDB-E-DBIOERR.*<database file>"'
$gtm_tst/com/getoper.csh "$syslog_start" "" syslog.txt "" "YDB-E-DBIOERR.*$dbpath" >&! getoper.logx
$grep "YDB-E-DBIOERR.*$dbpath" syslog.txt >&! dbioerr_syslog.logx
if (! -z dbioerr_syslog.logx) then
	echo "PASS : the operator log has a DBIOERR for this database file"
else
	echo "WRONG : no DBIOERR for this database file in the operator log - see syslog.txt and getoper.logx"
endif
set dbioerr = "`head -1 dbioerr_syslog.logx`"
echo "$dbioerr" | $grep -q 'YDB-E-DBIOERR, Error while doing write operation on region DEFAULT ([^)]*mumps.dat), %YDB-E-SYSCALL, Error received from system call io_submit() -- called from module [^ ]*wcs_wterror.c at line [0-9]*, %SYSTEM-E-ENO2, No such file or directory -- generated from'
if (0 == $status) then
	echo "PASS : the DBIOERR is followed by SYSCALL for io_submit() from wcs_wterror.c and by ENO2, with nothing else"
else
	echo "WRONG : the DBIOERR does not read DBIOERR, SYSCALL io_submit() from wcs_wterror.c, ENO2 - see dbioerr_syslog.logx"
	echo "$dbioerr"
endif
echo

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
if (0 == $status) then
	echo "PASS : dbcheck.csh found no integrity errors"
else
	echo "WRONG : dbcheck.csh failed - see dbcheck.out"
	cat dbcheck.out
endif
