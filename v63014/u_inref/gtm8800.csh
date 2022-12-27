#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
if (! $?test_replic) then
	echo "This subtest needs to be run with -replic. Exiting..."
	exit -1
endif
echo '# gtm8800 - verify MUIP FTOK and MUPIP SEMAPHORE operate correctly with new parms (-ID, -ONLY, and -[NO]HEADER)'
echo
echo '# Setup MSR and run dbcreate'
$MULTISITE_REPLIC_PREPARE 3
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate.txt
endif
echo
echo '# Start source and receiver services'
$MSR START INST1 INST2
$MSR START INST1 INST3
echo
echo '# On the primary, do 10 updates just to have done *something*'
$gtm_dist/mumps -run ^%XCMD 'for i=1:1:10 set ^a(i)=$justify(i,50)'
$MSR SYNC INST1 INST2
$MSR SYNC INST1 INST3
echo
echo '# Obtain semaphore & shared memory ids of the databases, journal pools, and receiver pools in INST1, INST2, and INST3'
set cmd = "$MUPIP FTOK"  # Resolve the command
set ENVVARS = "$gtm_test_msr_DBDIR1 $gtm_test_msr_DBDIR2 $gtm_test_msr_DBDIR3"
set envvars = `echo $ENVVARS` # Create array with expanded dirs indexable by instance number
foreach idx (1 2 3)
    # Build and execute the MUPIP FTOK command for each database
    set args = "-noheader $envvars[$idx]/mumps.dat"
    $cmd $args >& ftok_dbdump_INST${idx}.out
    # Get the semid for the database
    set name = "dbsemidINST${idx}"
    set $name = `$tst_awk '{print $3}' ftok_dbdump_INST${idx}.out`
    # Get the shmid for the database
    set name = "ftokdbshmidINST${idx}"
    set $name = `$tst_awk '{print $6}' ftok_dbdump_INST${idx}.out`
    # Build and execute the MUPIP FTOK command for each jnlpool/recvpool
    set args = '-jnlpool -recvpool'
    set args = "$args $envvars[$idx]/mumps.repl"
    $cmd $args >& ftok_pooldump_INST${idx}.out
    # Get semid for jnlpool
    set name = "ftokjnlpoolsemidINST${idx}"
    set $name = `$tst_awk '/jnlpool/ {print $3}' ftok_pooldump_INST${idx}.out`
    # Get shmid for jnlpool
    set name = "ftokjnlpoolshmidINST${idx}"
    set $name = `$tst_awk '/jnlpool/ {print $6}' ftok_pooldump_INST${idx}.out`
    # Get semid for recvpool
    set name = "ftokrecvpoolsemidINST${idx}"
    set $name = `$tst_awk '/recvpool/ {print $3}' ftok_pooldump_INST${idx}.out`
    # Get shmid for recvpool
    set name = "ftokrecvpoolshmidINST${idx}"
    set $name = `$tst_awk '/recvpool/ {print $6}' ftok_pooldump_INST${idx}.out`
end
ipcs -a >& running_ipcs.txt
if ("$ftokrecvpoolsemidINST1" != "-1") then
    echo
    echo "FAILURE - Receive pool semid for first instance is not -1 as expected - Is $ftokrecvpoolsemidINST1 instead"
endif
echo
echo '# Drive validation routine on each of our 3 instances'
# First drive on primary
echo "# Instance 1:"
$MSR RUN INST1 '$gtm_dist/mumps -run validate^gtm8800' $dbsemidINST1 $ftokdbshmidINST1 $ftokjnlpoolsemidINST1 $ftokjnlpoolshmidINST1 $ftokrecvpoolsemidINST1 $ftokrecvpoolshmidINST1
echo "# Instance 2:"
$MSR RUN INST2 '$gtm_dist/mumps -run validate^gtm8800' $dbsemidINST2 $ftokdbshmidINST2 $ftokjnlpoolsemidINST2 $ftokjnlpoolshmidINST2 $ftokrecvpoolsemidINST2 $ftokrecvpoolshmidINST2
echo "# Instance 3:"
$MSR RUN INST3 '$gtm_dist/mumps -run validate^gtm8800' $dbsemidINST3 $ftokdbshmidINST3 $ftokjnlpoolsemidINST3 $ftokjnlpoolshmidINST3 $ftokrecvpoolsemidINST3 $ftokrecvpoolshmidINST3
echo
$echoline
echo
echo '# Attempt various MUPIP FTOK commands to verify output form'
echo
echo '# (1) Run MUPIP FTOK $gtm_test_msr_DBDIR1/mumps.dat $gtm_test_msr_DBDIR2/mumps.dat $gtm_test_msr_DBDIR3/mumps.dat'
$MUPIP FTOK $gtm_test_msr_DBDIR1/mumps.dat $gtm_test_msr_DBDIR2/mumps.dat $gtm_test_msr_DBDIR3/mumps.dat
echo
echo '# (2) Run MUPIP FTOK notmumps.dat (nonexistent file - should return -1 FTOK and default to -ONLY behavior)'
$MUPIP FTOK notmumps.dat
echo
echo '# (3) Run MUPIP FTOK -only notmumps.dat (nonexistent file - should return -1 FTOK)'
$MUPIP FTOK -only notmumps.dat
echo
echo '# (4) Run MUPIP FTOK -noheader $gtm_test_msr_DBDIR1/mumps.dat $gtm_test_msr_DBDIR2/mumps.dat $gtm_test_msr_DBDIR3/mumps.dat'
$MUPIP FTOK -noheader $gtm_test_msr_DBDIR1/mumps.dat $gtm_test_msr_DBDIR2/mumps.dat $gtm_test_msr_DBDIR3/mumps.dat
echo
echo '# (5) Run MUPIP FTOK -only $gtm_test_msr_DBDIR1/mumps.dat $gtm_test_msr_DBDIR2/mumps.dat $gtm_test_msr_DBDIR3/mumps.dat'
$MUPIP FTOK -only $gtm_test_msr_DBDIR1/mumps.dat $gtm_test_msr_DBDIR2/mumps.dat $gtm_test_msr_DBDIR3/mumps.dat
echo
echo '# (6) Run MUPIP FTOK -noheader -only $gtm_test_msr_DBDIR1/mumps.dat $gtm_test_msr_DBDIR2/mumps.dat $gtm_test_msr_DBDIR3/mumps.dat'
$MUPIP FTOK -noheader -only $gtm_test_msr_DBDIR1/mumps.dat $gtm_test_msr_DBDIR2/mumps.dat $gtm_test_msr_DBDIR3/mumps.dat
echo
echo '# (7) Run MUPIP FTOK -jnlpool'
$MUPIP FTOK -jnlpool
echo
echo '# (8) Run MUPIP FTOK -jnlpool $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl'
$MUPIP FTOK -jnlpool $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl
echo
echo '# (9) Run MUPIP FTOK -jnlpool -noheader $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl'
$MUPIP FTOK -jnlpool -noheader $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl
echo
echo '# (10) Run MUPIP FTOK -jnlpool -only $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl'
$MUPIP FTOK -jnlpool -only $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl
echo
echo '# (11) Run MUPIP FTOK -jnlpool -noheader -only $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl'
$MUPIP FTOK -jnlpool -noheader -only $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl
echo
echo '# (12) Run MUPIP FTOK -recvpool $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl'
$MUPIP FTOK -recvpool $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl
echo
echo '# (13) Run MUPIP FTOK -recvpool -noheader $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl'
$MUPIP FTOK -recvpool -noheader $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl
echo
echo '# (14) Run MUPIP FTOK -recvpool -only $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl'
$MUPIP FTOK -recvpool -only $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl
echo
echo '# (15) Run MUPIP FTOK -recvpool -noheader -only $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl'
$MUPIP FTOK -recvpool -noheader -only $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl
echo
echo '# (16) Run MUPIP FTOK -jnlpool -recvpool $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl'
$MUPIP FTOK -jnlpool -recvpool $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl
echo
echo '# (17) Run MUPIP FTOK -jnlpool -recvpool -noheader $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl'
$MUPIP FTOK -jnlpool -recvpool -noheader $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl
echo
echo '# (18) Run MUPIP FTOK -jnlpool -recvpool -only $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl'
$MUPIP FTOK -jnlpool -recvpool -only $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl
echo
echo '# (19) Run MUPIP FTOK -jnlpool -recvpool -noheader -only $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl'
$MUPIP FTOK -jnlpool -recvpool -noheader -only $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl
echo
echo '# (20) Run MUPIP FTOK -only -id=44 mumps.repl'
$MUPIP FTOK -only -id=44 mumps.repl
echo
echo '# (21) Run MUPIP FTOK -id=43 mumps.dat'
$MUPIP FTOK -id=43 mumps.dat
echo
echo '# (22) Run MUPIP FTOK -only -id=44 $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl'
$MUPIP FTOK -only -id=44 $gtm_test_msr_DBDIR1/mumps.repl $gtm_test_msr_DBDIR2/mumps.repl $gtm_test_msr_DBDIR3/mumps.repl
echo
echo '# These next two tests are for verifying the output and alignment of MUPIP FTOK'
echo
echo '# (23) Run MUPIP FTOK mumps.dat'
$MUPIP FTOK mumps.dat
echo
echo '# (24) Run MUPIP FTOK -jnlpool -recvpool $gtm_test_msr_DBDIR2/mumps.repl'
$MUPIP FTOK -jnlpool -recvpool $gtm_test_msr_DBDIR2/mumps.repl
echo
$echoline
echo
echo '# Compare the output of MUPIP FTOK mumps.dat vs MUPIP FTOK -id=43 mumps.dat to verify they are the same'
echo
$MUPIP FTOK mumps.dat >& ftoknoid.txt
$MUPIP FTOK -id=43 mumps.dat >& ftokid.txt
diff ftoknoid.txt ftokid.txt
if (0 != $status) then
    echo '*** Difference detected !'
else
    echo '*** No difference detected!'
endif
echo
$echoline
echo
echo '# Now for some MUPIP SEMAPHORE commands - the semaphores here are all of the semaphores used in this test - i.e. the semids for'
echo '# 3 journal pools, 2 receive pools (INST1 has no receive pool), and 3 databases. This verifies their existence.'
echo
echo '# (25) Run MUPIP SEMAPHORE $ftokjnlpoolsemidINST1 $ftokjnlpoolsemidINST2 $ftokjnlpoolsemidINST3 - Verify 3 jnlpool semids exist (no error)'
$MUPIP SEMAPHORE $ftokjnlpoolsemidINST1 $ftokjnlpoolsemidINST2 $ftokjnlpoolsemidINST3
echo
echo '# (26) Run MUPIP SEMAPHORE $ftokrecvpoolsemidINST2 $ftokrecvpoolsemidINST3 - Verify 2 recvpool semids exist (no error) & verify formatting'
$MUPIP SEMAPHORE $ftokrecvpoolsemidINST2 $ftokrecvpoolsemidINST3
echo
echo '# (27) Run MUPIP SEMAPHORE $dbsemidINST1 $dbsemidINST2 $dbsemidINST3 - Verify 3 DB semids exist (no error)'
$MUPIP SEMAPHORE $dbsemidINST1 $dbsemidINST2 $dbsemidINST3
echo
echo '# To also get a semaphore id that has a non-zero key, discover the ftok semaphore for mumps.dat'
set ftokdbsemidINST1 = `$gtm_dist/mumps -run ^%XCMD 'write $$^%PEEKBYNAME("unix_db_info.ftok_semid","DEFAULT"),!'`
echo
echo '# (28) Run MUPIP SEMAPHORE $ftokdbsemidINST1 - looking for non-zero key value'
$MUPIP SEMAPHORE $ftokdbsemidINST1
echo
$echoline
echo
echo '# Run dbcheck.csh -extract to ensure db extract on primary matches secondary'
$gtm_tst/com/dbcheck.csh -extract
