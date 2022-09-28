#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test case 1 :
# 1. Have two environments defined by a)mumps.gld/mumps.dat b)other.gld/other.dat
# 2. source/receiver servers are started in mumps.gld environment
# 3. Another process starting other.gld environment (but pointing to the same mumps.repl file) shouldn't be allowed to update other.dat
# i.e One environment will never be allowed to update its replicated database using an instance file from another environment

# The below test plays with multiple global directories and journal pool. Unsetenv gtm_custom_errors to avoid REPLINSTMISMTCH errors
# (in any MUPIP SET commands below)
unsetenv gtm_custom_errors

$gtm_tst/com/dbcreate.csh mumps

setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
echo "# The below update should be successful"
$GTM <<GTM_EOF
s ^mumps=1
GTM_EOF

echo "# Change gtmgbldir to other.gld and create other.dat"
setenv gtmgbldir other.gld
$GDE << GDE_EOF
change -segment DEFAULT -file=other.dat
exit
GDE_EOF

$MUPIP create
$MUPIP set -replication=on -reg "*"

echo "# The below update should error out with YDB-E-REPLINSTNOSHM"
$GTM << GTM_EOF >&! gtm_updates.outx
set ^other=1
GTM_EOF

sed 's/jnlpool shmid = [0-9][0-9]*/jnlpool shmid = ##SHMID##/' gtm_updates.outx
setenv gtmgbldir mumps.gld

# Test case 2 : Recreating a live instance file should be handled much more robustly so we dont have mixing of multiple journal pools
echo "# Start background updates"
$gtm_exe/mumps -run startone^updates
$gtm_exe/mumps -run waitforglobal

echo "# Get the jnlpool shmid of mumps.repl"
$MUPIP ftok -jnlpool mumps.repl >&! mupip_ftok_mumps_repl.out
set old_shmid = `$tst_awk '/jnlpool/ {print $6}' mupip_ftok_mumps_repl.out`
set old_semid = `$tst_awk '/jnlpool/ {print $3}' mupip_ftok_mumps_repl.out`
$gtm_exe/ftok -id=44 mumps.repl >&! ftok_mumps_repl.out
set key = `$tst_awk '{print $5}' ftok_mumps_repl.out`
# Now note down ipcs -s and ipcs -m at this point
$gtm_tst/com/ipcs -s |& $grep $USER >&! ipcs_s_b4kill.out
$gtm_tst/com/ipcs -m |& $grep $USER >&! ipcs_m_b4kill.out
set old_semid2 = `$tst_awk '/'$key'/ { print $2 ; exit }' ipcs_s_b4kill.out`
set old_shmid_chk = `$grep -w $old_shmid ipcs_m_b4kill.out`
set old_semid_chk = `$grep -w $old_semid ipcs_s_b4kill.out`
set old_semid2_chk = `$grep -w $old_semid2 ipcs_s_b4kill.out`
echo "# The following semids and shmids will be expected to be orphaned and removed by argumentless rundown" >&! orphaned_sem.out
echo "old shmid = $old_shmid ; old_semid = $old_semid ; old_semid2 = $old_semid2" >> orphaned_sem.out
echo "# For the sake of completeness, make sure the three ipcs exist now (and will not exist after mupip rundown below)"
if (('' == "$old_shmid_chk") || ('' == "$old_semid_chk") || ('' == "$old_semid2_chk")) then
	echo "TEST-E-FAIL: At least one of the expected ipcs does not exist! See ipcs_._b4kill.out for details."
endif
echo "# Shutdown source server and remove mumps.repl"
$MUPIP replic -source -shutdown -timeout=0  >>& SHUT_${start_time}.out
mv mumps.repl mumps.repl.old
setenv start_time2 `date +%H_%M_%S`

echo "# Restart source server with new replication instance file"
setenv gtm_test_repl_skipsrcchkhlth
$gtm_tst/com/SRC.csh "." $portno $start_time2 >&! SRC_${start_time2}.out
unsetenv gtm_test_repl_skipsrcchkhlth

echo "# The source server should error out with REPLINSTMISMTCH though the name of replication instance file is the same"
echo "# Check if the error message prints the shmid of the old mumps.repl correctly"
$gtm_tst/com/check_error_exist.csh SRC_${start_time2}.log REPLINSTMISMTCH YDB-E-DBNOREGION | sed 's/jnlpool shmid = '$old_shmid'/jnlpool shmid = ##OLD_SHMID##/' | sed 's/jnlpool shmid = [0-9][0-9]*/jnlpool shmid = ##NEW_SHMID##/'

echo "# The below should error out with NOJNLPOOL error because source server startup failed"
$GTM << GTM_EOF
set \$etrap="write \$zstatus,!  halt"
set ^nojnlpool=1
GTM_EOF

echo "# The below shutdown command should issue NOJNLPOOL error because source server did not start at all"
$MUPIP replic -source -shutdown -timeout=0

# Test Case 3 : argumentless mupip rundown shoud handle multiple journal pools (pointing to the same instance file) correctly.
echo "# Kill the background mumps process"
set mumpsid = `$grep jobone one_updates1.mjo1 | sed 's/.*jobone(1,\(.*\))/\1/'`
$kill -15 $mumpsid

# !!! TEMPORARY CHANGE -- REMOVE ONCE GTM-7022 is taken care of !!!
# Until GTM-7022 is complete, this protects the MUMPS process's IPCs from persisting
# beyond the MUPIP rundown below because we are ensuring that the process is fully
# dead before proceeding.
$gtm_tst/com/wait_for_proc_to_die.csh $mumpsid 300

$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" >>&! $SEC_SIDE/SHUT_${start_time}.out"

echo '$MUPIP rundown'
$MUPIP rundown >&! mupip_rundown.outx
$gtm_tst/com/ipcs -m |& $grep $USER >&! ipcs_m_afterrundown.out
$gtm_tst/com/ipcs -s |& $grep $USER >&! ipcs_s_afterrundown.out
echo "# Check that NONE of the orphaned ipcs exist after argument-less mupip rundown"
set old_shmid_chk = `$grep -w $old_shmid ipcs_m_afterrundown.out`
set old_semid_chk = `$grep -w $old_semid ipcs_s_afterrundown.out`
set old_semid2_chk = `$grep -w $old_semid2 ipcs_s_afterrundown.out`
if (('' != "$old_shmid_chk") || ('' != "$old_semid_chk") || ('' != "$old_semid2_chk")) then
	echo "TEST-E-FAIL: At least one of the unexpected ipcs still exists! See ipcs_._afterrundown.out for details."
endif
echo '$MUPIP rundown again'
# The second rundown should not print the orphaned sem/shm ids
$MUPIP rundown >&! mupip_rundown2.outx
$grep -E " id ($old_shmid|$old_semid|$old_semid2) " mupip_rundown2.outx
$gtm_tst/com/wait_for_proc_to_die.csh $mumpsid 300
$gtm_tst/com/dbcheck.csh -noshut

# Test Case 4 : Argumentless MUPIP RUNDOWN should not remove orphaned shared memory if it does not have permissions to open the database file pointed to by the shm
setenv gtmgbldir user1.gld
$GDE << GDE_EOF
change -segment DEFAULT -file=user1.dat
exit
GDE_EOF

$MUPIP create
chmod 600 user1.dat
$gtm_exe/mumps -direct << GTM_EOF
set ^user1=1
zsystem "echo "_\$job_" > case4pid.txt"
zsystem "$kill9 "_\$job
GTM_EOF

echo "# Notedown the shared memory and semaphore id"
$MUPIP ftok user1.dat >&! mupip_ftok_user1_dat.out
set user1_shmid = `$tst_awk '/user1.dat/ {print $6}' mupip_ftok_user1_dat.out`
set user1_semid = `$tst_awk '/user1.dat/ {print $3}' mupip_ftok_user1_dat.out`
echo "# The following shmid and semid should not be removed by argumentless rundown run as other user"	>&! user1_shm.out
echo "user1_shmid = $user1_shmid ; user1_semid = $user1_semid"						>> user1_shm.out

echo '# The database has 600 permission. An argumentless mupip rundown as $gtmtest1 should not remove the shared memory, as it does not have write permission to the database'

cat > otheruser_rundown.csh << EOM
#!/usr/local/bin/tcsh -f
cd \$3
source $gtm_tst/com/set_specific.csh
source $gtm_tst/com/set_active_version.csh \$1 \$2
setenv gtmgbldir user1.gld
\$gtm_exe/mupip rundown
EOM

chmod +x otheruser_rundown.csh
$rsh -l $gtmtest1 $tst_org_host $tst_working_dir/otheruser_rundown.csh $tst_ver $tst_image $tst_working_dir >&! otheruser_rundown.outx

echo "# Should not see any of the shm or sem noted down above"
$grep -E " id ($user1_shmid|$user1_semid) " otheruser_rundown.outx
echo "# Check that the orphaned ipcs exist after argument-less mupip rundown as another user"
set user1_shmid_chk = `$gtm_tst/com/ipcs -m | $tst_awk '{print $2}' | $grep -w $user1_shmid`
set user1_semid_chk = `$gtm_tst/com/ipcs -s | $tst_awk '{print $2}' | $grep -w $user1_semid`
if (('' == "$user1_shmid_chk") || ('' == "$user1_semid_chk")) then
	echo "user1_shmid_chk = $user1_shmid_chk ; user1_semid_chk = $user1_semid_chk" >> orphaned_sem2_chk.out
	$gtm_tst/com/ipcs -a >&! ipcs_after_gtmtest1_rundown.out
	echo "TEST-E-FAIL: At least one of the expected ipcs does not exist! See ipcs_after_gtmtest1_rundown.out for details."
endif

echo '# $MUPIP rundown as same user'
$MUPIP rundown >&! user1_rundown.outx
echo "# Check that NONE of the orphaned ipcs exist after argument-less mupip rundown"
set user1_shmid_chk = `$gtm_tst/com/ipcs -m | $tst_awk '{print $2}' | $grep -w $user1_shmid`
set user1_semid_chk = `$gtm_tst/com/ipcs -s | $tst_awk '{print $2}' | $grep -w $user1_semid`
if (('' != "$user1_shmid_chk") || ('' != "$user1_semid_chk")) then
	echo "user1_shmid_chk = $user1_shmid_chk ; user1_semid_chk = $user1_semid_chk" >> removed_sem2_chk.out
	$gtm_tst/com/ipcs -a >&! ipcs_after_user1_rundown.out
	echo "TEST-E-FAIL: At least one of the unexpected ipcs still exists! See ipcs_after_user1_rundown.out for details."
endif

$sec_shell "$sec_getenv; cd $SEC_SIDE; source $gtm_tst/com/portno_release.csh"
