#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2005-2015 Fidelity National Information 	#
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
#
# TEST checks for mupip backup & restore conditions under various scenarios
#
# This test uses databases that are not fully upgraded and runs dbcheck. If gtm_test_online_integ is set to
# "-online" then SSV4NOALLOW will be issued. So, we better turn off online integ for the dbchecks done as
# a part of this test.
setenv gtm_test_online_integ ""
source $gtm_tst/com/set_crash_test.csh # sets YDBTest and YDB-white-box env vars to indicate this is a crash test
		# Note this needs to be done before the dbcreate.csh call in case of a -replic test so receiver side also
		# inherits this env var. But this is not a -replic test. Nevertheless, we do it before for consistency sake.
echo "########### mixed data format block section ############"
echo "#			Section 1		       #"
$gtm_tst/com/dbcreate.csh mumps 1 255 1000 -allocation=2048 -extension_count=2048
setenv gtm_test_jobid 0
setenv gtm_test_jobcnt 12
setenv gtm_test_crash_nprocs 8    # signal job.m to kill 8 jobs out of the 10	(BYPASSOK kill)
setenv gtm_test_crash_maxdelay 10 # kill those 8 jobs one by one with a maxdelay of 10 seconds
setenv gtm_test_dbfill "IMPTP"    # DEFAULT set in test/com_u/submit_test.csh
# GTM Process starts in background
echo "# Starting GTM processes..."
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
# start another script in the background which alternates between V4 & V6 in seeting the database version
echo "# Staring another bkground process that alternates between database versions"
($gtm_exe/mumps -run ^bkgrndset < /dev/null >>& bkgrndset.out&) >&! bg1.log
# Run gtm_test_crash_jobs_*.csh/.com (created by job.m in the test output directory) in the background
echo "# Start yet another bkground process which is created by job.m"
($gtm_exe/mumps -run ^bkgrndstop < /dev/null >>& bkgrndstop.out&) >&! bg2.log
set rand_wait=`$gtm_exe/mumps -run rand 30 1 10`
sleep $rand_wait
# At this point the databse has a mix of V4 & V6 format blocks
echo "# Take a full backup"
$MUPIP backup -database DEFAULT backup_orig.dat >>&! backup_orig.outx
$grep -vE "shmpool lock|YDB-W-KILLABANDONED" backup_orig.outx | sed 's/%YDB-I-BACKUPTN, Transactions from/%YDB-I-BACKUPTN, Transactions from GTM_TEST_DEBUGINFO/'
sleep $rand_wait
echo "# Take an incremental backup since last full backup"
$MUPIP backup -incremental -since=DATABASE DEFAULT backup.inc1 >>&! backup_inc1.outx
$grep -vE "shmpool lock|YDB-W-KILLABANDONED" backup_inc1.outx | sed 's/[0-9]* blocks saved/XXX blocks saved/' | sed 's/Transactions from /Transactions from GTM_TEST_DEBUGINFO /'
echo "# Stop the background script that is running"
$GTM << gtm_eof
set ^stopbg=1
halt
gtm_eof
set pid1 = `cat ver_alternate.out`
# this is to ensure the above process stops and properly run down to start next set of commands
$gtm_tst/com/wait_for_proc_to_die.csh $pid1 300
# stop gtm_test_crash_jobs*.csh if it has not finished already
set pid2 = `cat crash_job.out`
$gtm_tst/com/wait_for_proc_to_die.csh $pid2 300
echo "# Stopping GT.M processes..."
$gtm_tst/com/endtp.csh >>&! log_endtp.out
echo "# Take an incremental backup since last incremental backup"
$MUPIP backup -incremental -since=INCREMENTAL DEFAULT backup.inc2 >&! backup_inc2.outx
$grep -vE "shmpool lock|YDB-W-KILLABANDONED" backup_inc2.outx | sed 's/[0-9]* blocks saved/XXX blocks saved/' | sed 's/Transactions from /Transactions from GTM_TEST_DEBUGINFO /'
# from now on dbcheck & application check is done repeatedly under various scenarios.
# instead of repeating the steps below or adding another script to do this a cheeky "for" loop is added.
@ i = 0
foreach values ("echo checking database" "cp backup_orig.dat mumps.dat" "$MUPIP restore mumps.dat backup.inc1" "$MUPIP restore mumps.dat backup.inc2")
	@ i = $i + 1
	rm -f checkdb_ref.out >&/dev/null
	# execute the values supplied in for loop
	echo $values
	$values >&! do_$i.out
	sed 's/[0-9]* blocks/XXX blocks/' do_$i.out
	#dbcheck
	$gtm_tst/com/dbcheck_filter.csh
	if ( $status ) then
		echo "TEST-E-ERROR. db integrity error. DBCHECK not clean"
	endif
	# application level check
	$gtm_tst/com/checkdb.csh >>&! checkdb_ref.out
	if (`$grep -c "PASSED" checkdb_ref.out`) then
		cat checkdb_ref.out
	else
		echo "TEST-E-ERROR. checkdb FAILED , application level problem."
	endif
end
#
echo "########### V6 mupip backup with V4 database ######################"
echo "#			Section 2		        	  #"
rm -f mumps.dat mumps.gld *.o
echo "# Create a V4 database"
$sv4
echo "version switched to is "$v4ver >&! switch_v4.out
$gtm_tst/com/dbcreate.csh mumps >&! V4dbcreate.out
# switch back to current V6 version
$sv5
echo "# Backup error expected here for a v4 db"
$MUPIP backup -database DEFAULT backupv5.dat >&! backupv4dat.outx
if ($status == 0 ) then
	echo "TEST-E-ERROR.  error expected but got none"
else
	echo "PASS,got expected error"
endif
sed 's/expected label:/expected label:GTM_TEST_DEBUGINFO/' backupv4dat.outx
#
echo "########### V4 incremental backup with V6 mupip restore ############"
echo "#			Section 3		        	   #"
rm -f mumps.dat mumps.gld
echo "# Create a V4 database"
$sv4
echo "version switched to is "$v4ver >&! switch_v4.out
# priorver.txt is to filter the old version names in the reference file
echo $v4ver >& priorver.txt
$gtm_tst/com/dbcreate.csh mumps >&! V4dbcreate_2.out
echo "# Take a full backup using v4 executables"
$MUPIP backup -database DEFAULT backupv4.dat
$GTM << gtm_eof
for i=1:1:100 set ^x(i)=\$justify(i,100)
halt
gtm_eof
echo "# Take an incremental backup using v4 executables"
$MUPIP backup -incremental -since=database DEFAULT backupv4.inc1
echo "# Switch back to current V6 version"
$sv5
$gtm_tst/com/dbcreate.csh mumps
echo "# Attempt a restore from V6"
echo "# Unrecognizable format error expected here while recovering a v5 database from v4"
$MUPIP restore mumps.dat backupv4.inc1
if ($status == 0) then
	echo "TEST-E-ERROR.unrecognizable format error expected while recovering but got none"
endif
#
echo "########### MUPIP restore transacion option ############"
echo "#			Section 4		       #"
rm -f mumps.dat mumps.gld
$gtm_tst/com/dbcreate.csh mumps
# set compatiblity mode
$MUPIP set -version=V4 -file mumps.dat
echo "# Take full backup"
$MUPIP backup -database DEFAULT backup_compat.dat
$GTM << gtm_eof
for i=1:1:100 set ^x(i)=\$justify(i,100)
halt
gtm_eof
echo "# Take an incremental backup with TN=100000000"
echo "# Backup error expected here due to 2 ** 32 tn in compatiblity mode"
$MUPIP backup -incremental -transaction=100000000 DEFAULT backup_compat.inc1 >>&! err_inc.out
cat err_inc.out
if ( 0 == `$grep -c "no blocks backed up" err_inc.out` )then
	echo "TEST-E-ERROR. transaction number too large error expected due to 2**32 TN in compatiblity mode,but got none"
endif
echo "# Set V6 version"
$MUPIP set -version=V6 -file mumps.dat
echo "# Set cur_tn to be 2**63"
$DSE change -fileheader -current_tn=8000000000000000
echo "# Take a full back here"
$MUPIP backup -database DEFAULT backupv5.dat
# The below set uses i+1 for the value because. If gtm_gvdupsetnoop is randomly set, block TN will not be updated
# and the incremental backup will report different number of "blocks saved"
$GTM << gtm_eof
for i=1:1:100 set ^x(i)=\$justify(i+1,100)
halt
gtm_eof
echo "# MUPIP extract here to check for the globals at the end"
$MUPIP extract xdata.glo
# extract out just the data part from the ".glo" file
sed '1,2 d' xdata.glo >& xdata1.glo
echo "# Take an incremental backup upto tn=2**63"
$MUPIP backup -incremental -transaction=8000000000000000 DEFAULT backupv5.inc1 >>&! mupip_incrv5.out
if ($status) then
	echo "TEST-E-ERROR. incremental backup  failed even after setting V6 as version"
endif
cat mupip_incrv5.out
cp backupv5.dat mumps.dat
$MUPIP restore mumps.dat backupv5.inc1 >>&! mupip_restorev5.out
if ($status) then
	echo "TEST-E-ERROR. MUPIP restore failed even after setting V6 as version"
endif
cat mupip_restorev5.out
# application check
echo "# mupip extract again to verify the values existing in the database"
$MUPIP extract ydata.glo
# extract out just the data part from the ".glo" file
sed '1,2 d' ydata.glo >& ydata1.glo
diff xdata1.glo ydata1.glo >&! tmp1.out
if ($status) then
	echo "TEST-E-ERROR. Database values not same in the extract.Application level check failed"
else
	echo "PASS.Database extract values checked."
endif
$gtm_tst/com/dbcheck.csh
#
mv endtp.out entp.outx
$grep -v "FORCEDHALT" endtp.outx >&! endtp.out
@ cnt =1
foreach x (impjob_imptp0.mj*)
	mv $x impjob_imptp0.bak"$cnt"
	$grep -v "FORCEDHALT" impjob_imptp0.bak"$cnt" >&! $x
	@ cnt = $cnt + 1
end
exit
#C9F04-002714 - Incremental backup on TCP does not error out with restore  on different version
#Hence we are not executing this section till the software gets fixed.
echo "########### incremental backup over TCP connection #################"
echo "#			Section 5				   #"
rm -f *.dat mumps.gld
# sending(backup) system uses V6 receiving(restore) system uses V4
echo "# Error expected here as mupip backup of V6 is restored in V4 over TCP"
$gtm_tst/$tst/u_inref/tcp_bkup_restore.csh $tst_ver $v4ver
rm -f mumps.dat ${tst_org_host}:6200 mumps.gld
# sending(backup) system uses V4 receiving(restore) system uses V6
echo "# Error expected here as mupip backup of V4 is restored in V6 over TCP"
$gtm_tst/$tst/u_inref/tcp_bkup_restore.csh $v4ver $tst_ver
rm -f mumps.dat ${tst_org_host}:6200 mumps.gld
# both sending(backup) system & receiving(restore) system uses V6
echo "# MUPIP restore expected to PASS here as both system uses V6"
$gtm_tst/$tst/u_inref/tcp_bkup_restore.csh $tst_ver $tst_ver
#
