#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-005_Release_Notes.html#GTM-DE326986)

GT.M processes detach from shared memory associated with MUPIP INTEG snapshots correctly. Previously,
relatively idle GT.M processes could remain attached to such shared memory segments on unjournaled
regions or when the journal file switched while the snapshot was active, which prevented GT.M process
rundown from removing shared memory. The workaround was to use MUPIP RUNDOWN. (GTM-DE326986)

CAT_EOF

echo "# Disable journaling in this test as it is easy to test the unjournaled region case in the release note"
setenv gtm_test_jnl NON_SETJNL

echo '# Create 2-region database (AREG and DEFAULT)'
$gtm_tst/com/dbcreate.csh mumps 2 -stdnull

echo '# Execute [mumps -run gtmde326986] to start mumps processes that update AREG in background'
$gtm_dist/mumps -run gtmde326986

echo '# Run [mupip integ -online -dbg -reg areg] in the foreground in a loop until a snapshot shmid created by the integ'
echo '# is seen to exist even after the integ process terminated. That implies a concurrent mumps process'
echo '# attached to this snapshot shmid as part of its update to AREG.'
@ cnt = 1
while ($cnt < 10000)
        set logfilename = "mu_integ_$cnt.out"
        $MUPIP integ -online -dbg -reg AREG >& $logfilename
        set shmid = `$grep 'Successfully created shared memory. SHMID' $logfilename | $tst_awk '{print $NF}'`
        set is_shm_present = `ipcs -m | $tst_awk '{print $2}' | $grep '^'$shmid'$'`
        if ("" != "$is_shm_present") then
                break
        endif
        @ cnt = $cnt + 1
end

echo '# Now that we have a snapshot shmid that exists even after the online integ terminated, wait for 1 minute'
echo '# for the mumps process to detach from the shmid. That should completely remove the shmid from the system'
echo '# (the online integ would have only marked the shmid for deletion when the last process attached to the'
echo '# shm detaches from it).'
echo '# In GT.M V7.0-004, the shmid would stay on for ever (i.e. even after 1 minute) whereas in GT.M V7.0-005'
echo '# the shmid would go away after approximately a 1 minute wait.'
echo '# Therefore sleep for about 65 seconds (including a 5 second buffer) before checking if shmid exists on system'
sleep 65

echo '# Now that sleep is done, check if snapshot shmid still exists (it should not)'
set is_shm_present = `ipcs -m | $tst_awk '{print $2}' | $grep '^'$shmid'$'`
if ("" != "$is_shm_present") then
	echo 'TEST-E-FAIL : snapshot shmid ['$shmid'] still exists in system'
else
	echo 'TEST-S-PASS : snapshot shmid ['$shmid'] no longer exists in system (as expected)'
endif

echo '# Signal background mumps process to stop now that test is done'
$gtm_dist/mumps -run %XCMD 'set ^stop=1'

echo '# Wait for background jobs to terminate'
$gtm_dist/mumps -run wait^job

echo '# Validate DB'
$gtm_tst/com/dbcheck.csh

