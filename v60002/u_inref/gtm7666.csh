#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

unsetenv gtm_test_freeze_on_error
unsetenv gtm_test_fake_enospc

setenv gtm_test_jobcnt 10
setenv gtm_test_jobid 1
setenv gtm_test_crash 1
setenv gtm_test_dbfill "IMPTP"
setenv acc_meth BG # before image journaling does not work with MM
$gtm_tst/com/dbcreate.csh mumps 4 125 1000 4096 2000 4096 2000 >& dbcreate.out
$MUPIP set -journal='enable,on,before' -reg "*" >& set_jnl.out

echo "Launching $gtm_test_jobcnt jobs."
$gtm_tst/com/imptp.csh >& imptp.out
echo "Waiting 2000 updates to happen."
$gtm_exe/mumps -run %XCMD 'for  quit:2000<=$get(^cntloop(0),0)  hang 0.5'
echo "Updates are done. Crashing processes."
source $gtm_tst/com/gtm_crash.csh

# Save the database in case it fails. That way, we can replay this test
$gtm_tst/com/backup_dbjnl.csh bak "*.dat *mjl*" cp nozip

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 92
if (! $?gtm_white_box_test_case_count) then
    setenv gtm_white_box_test_case_count 0
    $MUPIP journal -recover -backward -verbose mumps.mjl >& recover_out1.outx
    set max=`$tst_awk '/Total number of writes/{print $5}' recover_out1.outx`
    set awk_cmd='BEGIN{srand()}{print int(rand() * '$max') + 1}'
    setenv gtm_white_box_test_case_count `echo | $tst_awk $awk_cmd:q`
    rm *mjl* *.dat*
    cp bak/* .
endif
echo "Selected gtm_white_box_test_case_count: $gtm_white_box_test_case_count"
echo "setenv gtm_white_box_test_case_count $gtm_white_box_test_case_count" >> settings.csh
$MUPIP journal -recover -backward -verbose mumps.mjl >& recover_out2.outx
if (0 == $status) then
    echo "TEST-E-FAIL Recover returned 0 status. Should have been non-zero."
else
    echo "TEST-I-PASS Recover returned non-zero status as expected."
endif
unsetenv gtm_white_box_test_case_number
unsetenv gtm_white_box_test_case_enable

# dbcheck.csh does not make sense in this unstable database state
