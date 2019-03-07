#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# In the case of a JNLMOVED situation, running MUPIP SET -JOURNAL to switch the journal file fails with the same JNLMOVED error.
# This is what one would get:
# > mupip set -journal="enable,on,before" -reg "*"
# %YDB-I-JNLFNF, Journal file ##PATH##/mumps.mjl not found
# %YDB-E-JNLFILOPN, Error opening journal file ##PATH##/mumps.mjl for database file ##PATH##/mumps.dat
# %YDB-E-JNLFILOPN, Error opening journal file  for database file
# %YDB-E-JNLNOCREATE, Journal file ##PATH##/mumps.mjl not created
# %YDB-E-MUNOFINISH, MUPIP unable to finish all requested actions
# This is a situation where we know the journal file state is not good and we need to switch to a new journal file but yet
# MUPIP SET JOURNAL does not work.
# The following test ensures that V5.4-0001 onwards, this is fixed
#
unsetenv gtm_custom_errors	# The test explicitly tests journaling getting turned off. Instance freeze scheme
				# makes sure journaling is never turned off. So, unsetenv gtm_custom_errors.
setenv gtm_test_jnlfileonly 0	# The test mangles the journal, so don't force the source to read it.
unsetenv gtm_test_jnlpool_sync	# ditto
# Set whitebox test case to avoid asserts in jnl_file_open due to JNLOPNERR
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 34

$gtm_tst/com/dbcreate.csh mumps 3 125 1000 4096 1024 1024 1024
$MUPIP set $tst_jnl_str -reg "*" >&! set_journal1.out

# Start few mumps process in the background
echo
echo
$echoline
echo "Start few mumps process in the background"
$echoline
# Use SLOWFILL to avoid source server from ever going to the journal files. This could happen if the receiver server is much behind
# the source server. Since this test explicitly plays with MUPIP SET -JOURNAL and cuts the previous link without properly closing
# the current journal file, the source server could end up with various errors (and asserts in DBG builds) if it ever goes to the
# journal file for sending a journal record corresponding to an old sequence number. To avoid the source server from ever going to
# the journal file, use SLOWFILL. See <C9J04003116_NOPREVLINK_JNLOPNERR_gtmsource_readfile_assert> for more details.
setenv gtm_test_dbfill "SLOWFILL"
$gtm_tst/com/imptp.csh >&! imptp.out

echo
echo
$echoline
echo "Sleep for 15 seconds to let the process do enough updates"
$echoline
sleep 15

echo
echo
$echoline
echo "Change the fileid of the mumps.mjl by doing a gzip followed by a gunzip"
$echoline
# Pause the background jobs before proceeding so that gzip command does not fail
# due to concurrent file modifications
$gtm_exe/mumps -run %XCMD 'do pause^pauseimptp'
# Ensure JNLFLUSH is done (see comment in pause^pauseimptp as to why this is necessary)
$gtm_exe/mumps -run %XCMD 'view "JNLFLUSH"'
$tst_gzip mumps.mjl ; $tst_gunzip mumps.mjl.gz

set syslog_before1 = `date +"%b %e %H:%M:%S"`
echo
echo
$echoline
echo "Attempt to do journal activity by a new process should result in YDB-E-JNLOPNERR"
$echoline
$GTM << GTM_EOF
set ^x=2
GTM_EOF

$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog1.txt "" JNLSENDOPER

echo
echo
$echoline
echo "Fix the situation by doing a MUPIP SET -JOURNAL that will cut the previous link and create fresh set of journal files"
$echoline
set syslog_before2 = `date +"%b %e %H:%M:%S"`
if ($?test_replic == 1) then
	$MUPIP set $tst_jnl_str -reg "*" -replic=on >&! set_journal2.out
else
	$MUPIP set $tst_jnl_str -reg "*" >&! set_journal2.out
endif
set stat = $status
if ($stat) then
	echo "MUPIP SET -JOURNAL command failed. Please check set_journal2.out for more information"
endif
$gtm_tst/com/getoper.csh "$syslog_before2" "" syslog2.txt "" PREVJNLLINKCUT
$gtm_tst/com/check_error_exist.csh set_journal2.out JNLOPNERR PREVJNLLINKCUT

echo
echo
$echoline
echo "Verify that the situation is indeed fixed by doing an update to DEFAULT region and ensuring that it gets journaled"
# Resume the backround jobs
$gtm_exe/mumps -run %XCMD 'do resume^pauseimptp'
$echoline
$GTM << GTM_EOF
write "set ^xrandomvariable=""something_unique"""  set ^xrandomvariable="something_unique"
GTM_EOF

$DSE all -buffer_flush

$MUPIP journal -noverify -fences=none -extract -forward mumps.mjl >&! jnl_extract.out
set stat = $status
if ($stat) then
	echo "MUPIP JOURNAL -EXTRACT failed. Please check jnl_extract.out"
endif
$grep JNLSUCCESS jnl_extract.out
$grep "xrandomvariable" mumps.mjf | $tst_awk -F\\ '{print $NF}'

$gtm_tst/com/endtp.csh >&! endtp.out

echo
echo
$gtm_tst/com/dbcheck.csh -extract
