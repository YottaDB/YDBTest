#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# The test ensures that in case the secondary is in an unsalvageable condition, the databases and journals from
# the primary can be shipped and replication will resume without any problems
# as long as the database and journals in the secondary have full path names pointing to each other
#
if ("ENCRYPT" == $test_encryption) then
	source $gtm_tst/com/create_sym_key_for_multihost_use.csh	# Since database from the primary is shipped to secondary, use the same symmetric keys on both sides
endif
#
###########################################################################################################
setenv test_specific_gde $gtm_tst/$tst/u_inref/helper.gde
$gtm_tst/com/dbcreate.csh mumps .
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`

# save so debug info in case MUSTANDALONE error occurs
$gtm_exe/ftok mumps.dat >&! gtm_ftok_info.out
$gtm_tst/com/ipcs -sa >&! ipcs_sa.out
set gtm_semkey=`cat gtm_ftok_info.out|$grep "mumps.dat"|$tst_awk '{print $5}'`
echo $gtm_semkey >&! gtm_semkey.out
set gtm_semid=`cat ipcs_sa.out | $grep $gtm_semkey | sed 's/s/s /'| $tst_awk '{printf("%s ",$2);}'`
echo $gtm_semid >& gtm_semid.out
if ( "" != "$gtm_semid" ) then
	$gtm_exe/semstat2 $gtm_semid >&! gtm_semstat2_inst.out
endif
$ps >& ps.outx

###########################################################################################################
echo "Starting GTM processes..."
$gtm_tst/com/imptp.csh   >&! imptp.out
sleep  15 # to ensure it runs for a while
###########################################################################################################
#					Secondary side							  #
echo "Receiver shut down ...."
$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh "." < /dev/null >>& $SEC_SIDE/SHUT_`date +%H_%M_%S`.out'
###########################################################################################################
#					Primary side							  #
sleep 15 # (to build backlog) before backup database
echo "==================================================="
mkdir bak1
echo "Backup started"
$MUPIP backup -replinstance=bak1 "*" bak1 >& backup_bak1.out
set backupstatus = $status
set backupcount = `$grep -c "are backed up" backup_bak1.out`

if ( (0 == $backupstatus) && (0 < $backupcount )) then
	echo "Backup completed"
else
	echo "TEST-E-ERROR backup errors pls. check backup_bak1.out"
endif
mv bak1/mumps.repl bak1/pri_mumps.repl
###########################################################################################################
#					Secondary side							  #
echo "============ Secondary side,  copy backed up  database from Primary ==============="
$sec_shell '$sec_getenv; cd $SEC_SIDE; mkdir orig; mv {*.dat*,*.mjl*} orig; \cp -f $PRI_SIDE/bak1/* .'
###########################################################################################################
#					Primary  side							  #
echo "Wait some more time to create backlog in primary side"
sleep 15
###########################################################################################################
#					Secondary side							  #
echo "Start secondary with refreshed database"
setenv start_time "`date +%H_%M_%S`"
$sec_shell '$sec_getenv; cd $SEC_SIDE; mv mumps.repl mumps.repl_bak'
#mumps.repl is moved because, we need to recreate mumps.repl. RCVR.csh will take care if there is not mumps.repl
# signal jnl_on.csh to use -file while turning on journaling, as the db copied from primary will have jnl file pointing to the primary directory
setenv test_jnl_on_file 1
$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh "on" $portno $start_time "updateresync=pri_mumps.repl" < /dev/null >>&!     $SEC_SIDE/START_${start_time}.out'
unsetenv test_jnl_on_file
###########################################################################################################
#					Primary  side							  #
echo "========= Version in primary side ========================="
echo "Stopping GTM processes"
$gtm_tst/com/endtp.csh >& endtp.out
$gtm_tst/com/dbcheck.csh -extract >& dbcheck.out
echo "End of test"
