#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Verify that shared memory and semaphore fields in the file header are not reset without being removed

# Due to a bug in V61000, MUPIP RUNDOWN could reset shared memory and semaphore fields in the file header while leaving them
# behind. This test exposes this problem by launching consecutive MUPIP RUNDOWN and MUPIP ROLLBACKS.  Under normal conditions,
# MUPIP RUNDOWN shouldn't remove the shared resources if it's not their creator. If the V61000 bug persists, MUPIP ROLLBACK
# should realize that the shared memory and semaphore ipcs are still up while they are invalidated in the file header.

# With 16K counter semaphore bump per process, the 32K counter overflow happens with just 2 processes
# (the below subtest starts 10 imptp processes) which means the argumentless mupip rundown (done in a while loop below)
# could delete the db ipcs before the imptp processes finish rundown. This could cause the imptp process in gds_rundown()
# to issue a CRITSEMFAIL error in pro and fail an assert while doing a semctl() on udi->ftok_semid and seeing an EIDRM/EINVAL.
# So disable artificial counter overflows for this test.
unsetenv gtm_db_counter_sem_incr

$MULTISITE_REPLIC_PREPARE 2
setenv acc_meth BG # before image journaling does not work with MM
setenv tst_jnl_str "-journal=enable,on,before"
$gtm_tst/com/dbcreate.csh mumps 1 125 1000 4096 2000 4096 2000 >& dbcreate_out.txt

$MSR START INST1 INST2
#note the filename of the source server log
get_msrtime  # sets $time_msr
setenv srclogfile12 SRC_$time_msr.log

setenv gtm_test_jobcnt 10
setenv gtm_test_jobid 1
setenv gtm_test_dbfill "IMPTP"
echo "# Launching $gtm_test_jobcnt jobs."
$gtm_tst/com/imptp.csh >& imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
echo "# Waiting 2000 updates to happen."
$gtm_exe/mumps -run %XCMD 'for  quit:2000<=$get(^cntloop(0),0)  hang 0.5'

set pidmumps=`sed -n 's/PID:\([0-9]*\)/\1/p' impjob_imptp1.mjo*`
set pidsrc=`$MUPIP replicate -source -checkhealth |& $tst_awk '($1 == "PID") && ($2 ~ /[0-9]*/) { print $2 }'`

echo "# MUPIP STOP the source server"
$MUPIP stop $pidsrc >& mupip_stop_src.log
$gtm_tst/com/wait_for_proc_to_die.csh $pidsrc

echo "# Attempt rollback this should fail because of running mumps processes"
# Below backward rollback invocation is expected to fail. Therefore pass "-backward" explicitly to mupip_rollback.csh
# (and avoid implicit "-forward" rollback invocation that would otherwise happen by default).
$gtm_tst/com/mupip_rollback.csh -backward -lost=simpleinstanceupdate.los "*" >& rollback_0.logx
$gtm_tst/com/check_error_exist.csh rollback_0.logx "MUNOACTION"
echo "# Attempt rundown which again should fail due to running mumps processes"
$MUPIP rundown >& rundown_0.logx
$gtm_tst/com/check_error_exist.csh rundown_0.logx "MUNOTALLSEC"

echo "# MUPIP STOP all the mumps processes"
foreach pid ( $pidmumps )
    $MUPIP stop $pid >>& mupip_stop_mumps.log
end

# Intentionally not waiting for MUMPSes to completely quit because we want to make sure that their rundown conflict with MUPIP
# RUNDOWN so that MUPIP RUNDOWN is not the shared resource creator. If MUMPS processes exit immediately or we explicitly give them
# time to quit, then this test may pass despite the bug persistence.  However, in our experiments with V61000 was failing every time
# so this test should expose this bug sooner or later given that it resurfaces in the future.

echo "# Now journal pool is orphaned but source server also terminated abnormally. See if rundown/rollback behaves nicely."
@ cnt = 1
while ($cnt < 100)
	# Below backward rollback invocation CAN fail. Therefore pass "-backward" explicitly to mupip_rollback.csh
	# (and avoid implicit "-forward" rollback invocation that would otherwise happen by default).
        $gtm_tst/com/mupip_rollback.csh -backward -lost=simpleinstanceupdate.los "*" >& rollback_${cnt}.logx
        if ($status) then
		# The following error is an indication of premature ipcs reset on the file header
                $grep -q "REPLINSTDBMATCH" rollback_${cnt}.logx
                if (0 == $status) then
                        echo "------------------------------------------"
                        echo "---> Got REPLINSTDBMATCH error : See rollback_${cnt}.log for details"
                        echo "------------------------------------------"
                        break
                endif
        endif
        $MUPIP rundown >& rundown_${cnt}.logx
        @ cnt = $cnt + 1
end

foreach pid ( $pidmumps )
    $gtm_tst/com/wait_for_proc_to_die.csh $pid 120
end

$MSR STOPRCV INST1 INST2
$MUPIP rundown >& rundown_final.logx
foreach file ($srclogfile12 impjob_imptp1.mje*)
    sed 's/YDB-F-FORCEDHALT/FORCEDHALT/' $file > ${file}.tmp
    mv ${file}.tmp $file
end

$gtm_tst/com/dbcheck_filter.csh -noshut
