#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
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

# Verfiy counter semaphore limit do not prevent more than 32K processes from starting

setenv gtm_test_qdbrundown 1
# passive_start_upd_enable.csh needs the following to be set
setenv gtm_test_qdbrundown_parms "-qdbrundown"
setenv gtm_test_jnl SETJNL
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps 1 125 1000 4096 2000 4096 2000

echo "# Start IMPTP"
setenv gtm_db_counter_sem_incr 16000
set syslog_start = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/imptp.csh 5 >& imptp1.out
unsetenv gtm_db_counter_sem_incr

$gtm_tst/com/getoper.csh "$syslog_start" "" syslog1.txt "" NOMORESEMCNT 2
if (0 == $status) then
    echo "TEST-I-PASS Successfully disabled counter semaphores"
endif

echo "# Stop IMPTP"
$gtm_tst/com/endtp.csh >& endtp1.out

echo "# IPCS should lay around"
set mupip_ftok_file = mupip_ftok1.out
set check_ipcs_output_file = check_ipcs_output1.txtx
$MUPIP ftok mumps.dat >&! $mupip_ftok_file
set semid = `$grep "mumps.dat" $mupip_ftok_file | $tst_awk '{print $3}'`
set shmid = `$grep "mumps.dat" $mupip_ftok_file | $tst_awk '{print $6}'`

$gtm_tst/com/check_ipcs.csh all  >&! $check_ipcs_output_file

$grep -q $semid $check_ipcs_output_file
if (1 == $status) then
    echo "TEST-E-FAIL semid = $semid should be laying around. Check $check_ipcs_output_file"
endif

$grep -q $shmid $check_ipcs_output_file
if (1 == $status) then
    echo "TEST-E-FAIL shmid = $shmid should be laying around. Check $check_ipcs_output_file"
endif

echo "# node_local.ftok_counter_halted and node_local.access_counter_halted flags should be set"
if (1 != `$gtm_exe/mumps -run checkftokhaltedflag^gtm8137`) then
    echo "TEST-E-FAIL The ftok_counter_halted in database shared memory is not set"
    exit 1
endif

if (1 != `$gtm_exe/mumps -run checkaccesshaltedflag^gtm8137`) then
    echo "TEST-E-FAIL The access_counter_halted in database shared memory is not set"
    exit 1
endif

$MUPIP journal -recover -backward mumps.mjl

echo "# node_local.ftok_counter_halted and node_local.access_counter_halted flags should be clear"
if (0 != `$gtm_exe/mumps -run checkftokhaltedflag^gtm8137`) then
    echo "TEST-E-FAIL The ftok_counter_halted in database shared memory is not clean"
    exit 1
endif

if (0 != `$gtm_exe/mumps -run checkaccesshaltedflag^gtm8137`) then
    echo "TEST-E-FAIL The access_counter_halted in database shared memory is not clean"
    exit 1
endif

echo "# Check again. No IPCS should lay around"
$gtm_tst/com/check_ipcs.csh all

echo "# Verify the counters spit out error if -noqdbrundown"
$DSE change -fileheader -noqdbrundown >>& dse.out

echo "# Start jobs"
setenv gtm_db_counter_sem_incr 16000
$gtm_exe/mumps -run gtm8137
unsetenv gtm_db_counter_sem_incr


echo "# node_local.ftok_counter_halted and node_local.access_counter_halted flags should be clear"
if (0 != `$gtm_exe/mumps -run checkftokhaltedflag^gtm8137`) then
    echo "TEST-E-FAIL The ftok_counter_halted in database shared memory is not clean"
    exit 1
endif

if (0 != `$gtm_exe/mumps -run checkaccesshaltedflag^gtm8137`) then
    echo "TEST-E-FAIL The access_counter_halted in database shared memory is not clean"
    exit 1
endif

$MUPIP journal -recover -backward mumps.mjl
$DSE change -fileheader -qdbrundown >>& dse.out

echo "# Replication Setup"

$gtm_exe/mupip set -region "*" -replic=on >&! replicon.log

echo "# Start passive source server"
source $gtm_tst/com/passive_start_upd_enable.csh >&! passive_start_`date +%H_%M_%S`.out

echo "# Start IMPTP"
setenv gtm_db_counter_sem_incr 16000
set syslog_start = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/imptp.csh 5 >& imptp2.out
unsetenv gtm_db_counter_sem_incr

$gtm_tst/com/getoper.csh "$syslog_start" "" syslog2.txt "" NOMORESEMCNT 2

echo "# Stop IMPTP"
$gtm_tst/com/endtp.csh >& endtp2.out

$MUPIP replicate -source -shutdown -timeout=0 >&! replicshutdown.log

echo "# IPCS should lay around"
set mupip_ftok_file = mupip_ftok2.out
set check_ipcs_output_file = check_ipcs_output2.txtx
$MUPIP ftok mumps.dat >&! $mupip_ftok_file
set semid = `$grep "mumps.dat" $mupip_ftok_file | $tst_awk '{print $3}'`
set shmid = `$grep "mumps.dat" $mupip_ftok_file | $tst_awk '{print $6}'`

$gtm_tst/com/check_ipcs.csh all  >&! $check_ipcs_output_file

$grep -q $semid $check_ipcs_output_file
if (1 == $status) then
    echo "TEST-E-FAIL semid = $semid should be laying around. Check $check_ipcs_output_file"
endif

$grep -q $shmid $check_ipcs_output_file
if (1 == $status) then
    echo "TEST-E-FAIL shmid = $shmid should be laying around. Check $check_ipcs_output_file"
endif

echo "# node_local.ftok_counter_halted and node_local.access_counter_halted flags should be set"
if (1 != `$gtm_exe/mumps -run checkftokhaltedflag^gtm8137`) then
    echo "TEST-E-FAIL The ftok_counter_halted on database shared memory is not set"
    exit 1
endif

if (1 != `$gtm_exe/mumps -run checkaccesshaltedflag^gtm8137`) then
    echo "TEST-E-FAIL The access_counter_halted on database shared memory is not set"
    exit 1
endif

$MUPIP journal -rollback -backward "*"

echo "# node_local.ftok_counter_halted and node_local.access_counter_halted flags should be clear"
if (0 != `$gtm_exe/mumps -run checkftokhaltedflag^gtm8137`) then
    echo "TEST-E-FAIL The ftok_counter_halted on database shared memory is not clean"
    exit 1
endif

if (0 != `$gtm_exe/mumps -run checkaccesshaltedflag^gtm8137`) then
    echo "TEST-E-FAIL The access_counter_halted on database shared memory is not clean"
    exit 1
endif


echo "# Check again. No IPCS should lay around"
$gtm_tst/com/check_ipcs.csh all

# Since this test does a MUPIP JOURNAL -RECOVER and a MUPIP JOURNAL -ROLLBACK with database shared memory not cleanly shutdown
# (i.e. no EOF record in journal file because of counter semaphore overflow) AND the imptp updates could be doing KILL operations,
# it is possible an EPOCH happens in between phase1 and phase2 of the KILL in which case the database at the end of the
# recover/rollback can have DBMRKBUSY integ errors (benign errors). Therefore use dbcheck_filter.csh (not the usual dbcheck.csh).
$gtm_tst/com/dbcheck_filter.csh
