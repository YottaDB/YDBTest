#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh

setenv test_debug 1
echo "Standalone access subtest .."
$gtm_tst/com/dbcreate.csh mumps 4 125 1000 1024 4096 1024 4096
$gtm_tst/com/create_reg_list.csh
echo ""
echo Test Case 41
echo  ""
echo "Replication state transition 1 to 0 needs standalone access"
echo "GTM Process starts in background..."
setenv gtm_test_dbfill "SLOWFILL"
setenv gtm_test_jobcnt 2
setenv gtm_test_jobid 1
$gtm_tst/com/imptp.csh >>&! imptp.out
sleep 10		# To allow some data to be set for all regions
echo "Try 1 to 0 : $MUPIP set -replic=off -reg *"
set output = "set_replic_off.out"
$MUPIP set -replic=off -reg "*" >&! ${output}x
$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-E-MUNOFINISH' ${output}x >&! $output
echo "Journal States:(expected ON) : Replication States (expected ON):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State"
$gtm_tst/$tst/u_inref/check_repl_state.csh
#
echo "Try Journal State 2 to 2 and replication 1 to 0:"
echo "$MUPIP set -replic=off -journal=enable,on,before -reg *"
set output = "set_replic_off_jnl_on.out"
$MUPIP set -replic=off -journal=enable,on,before -reg "*" >&! ${output}x
$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-E-MUNOFINISH' ${output}x >&! $output
echo "Journal States:(expected ON) : Replication States (expected ON):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State"
$gtm_tst/$tst/u_inref/check_repl_state.csh
#
echo "Try Journal State 2 to 1:"
$MUPIP set -journal=enable,off,before -reg "*" |& sort -f
echo "Journal States:(expected ON) : Replication States (expected ON):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State"
$gtm_tst/$tst/u_inref/check_repl_state.csh
#
echo "Try Journal DISABLED:"
$MUPIP set -journal=disable -reg "*" |& sort -f
echo "Journal States:(expected ON) : Replication States (expected ON):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State"
$gtm_tst/$tst/u_inref/check_repl_state.csh
#
echo "Stop the background process"
$gtm_tst/com/endtp.csh  >>& endtp1.out
$tst_tcsh $gtm_tst/com/RF_SHUT.csh  "on"
$tst_tcsh $gtm_tst/com/RF_EXTR.csh
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/dbcheck_base.csh -nosprgde"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/dbcheck_base.csh -nosprgde"
$gtm_tst/com/checkdb.csh
#
echo "No background processes are running"
echo '$gtm_tst/com/mupip_rollback.csh -resync=1 -lost=alllost.glo *'
$gtm_tst/com/mupip_rollback.csh -resync=1 -lost=alllost.glo "*" >&! rollback_resync1.out
set rollback_status = $status
# Only P->Q will have the below additional line. Check for it and filter it out to make the reference file consistent.
# %YDB-I-RLBKSTRMSEQ, Stream journal seqno of the instance after rollback is Stream  0 : Seqno 1 [0x0000000000000001]
if (2 == $test_replic_suppl_type) then
	$grep "YDB-I-RLBKSTRMSEQ" rollback_resync1.out >& /dev/null
	@ rollback_status = $rollback_status + $status
	$grep -v "YDB-I-RLBKSTRMSEQ" rollback_resync1.out
else
	cat rollback_resync1.out
endif
if ($rollback_status) then
	echo rollback failed
	exit
endif
echo "Journal States:(expected ON) : Replication States (expected ON):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State"
$gtm_tst/$tst/u_inref/check_repl_state.csh
echo "Now switch replication state 1 to 0"
$MUPIP set -replic=off -reg "*" |& sort -f
echo "Journal States:(expected ON) : Replication States (expected OFF):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State"
$gtm_tst/$tst/u_inref/check_repl_state.csh
#
echo ""
echo Test Case 40
echo ""
unsetenv test_replic
#
echo "Transition of replication state 0 to 1 needs standalone access"
# replication state 0
echo "GTM Process starts in background..."
setenv gtm_test_jobid 2
$gtm_tst/com/imptp.csh >>&! imptp.out
sleep 10		# To allow some data to be set for all regions
set output = "set_replic_on.out"
$MUPIP set -replic=on -reg "*" >&! ${output}x
$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-E-MUNOFINISH' ${output}x >&! $output
echo "Journal States:(expected ON) : Replication States (expected OFF):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State"
$gtm_tst/$tst/u_inref/check_repl_state.csh
#
set output = "set_jnl_on_replic_on.out"
$MUPIP set -journal=enable,on,before -replic=on -reg "*" >&! ${output}x
$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-E-MUNOFINISH' ${output}x >&! $output
echo "Journal States:(expected ON) : Replication States (expected OFF):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State"
$gtm_tst/$tst/u_inref/check_repl_state.csh
#
echo "Stop the background process"
$gtm_tst/com/endtp.csh  >>& endtp2.out
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/checkdb.csh
#
echo "No background processes are running"
echo "Now switch replication state 0 to 1"
$MUPIP set -replic=on -reg "*" |& sort -f
echo "Journal States:(expected ON) : Replication States (expected ON):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State"
$gtm_tst/$tst/u_inref/check_repl_state.csh
###
echo "Verify All Journals:"
foreach jnl (`ls *.mjl*`)
echo "$MUPIP journal -verify -for $jnl" >>& verification.out
$MUPIP journal -verify -for $jnl >>& verification.out
if ($status) echo $jnl
end
