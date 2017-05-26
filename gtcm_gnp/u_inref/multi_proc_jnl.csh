#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
############################################################################################################################################################
#
# this test has explicit mupip creates, so let's not do anything that will have to be repeated at every mupip create
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn

# Set autoswitchlimit to smallest value so we test autoswitch logic for GTCM GNP as well
setenv tst_jnl_str "$tst_jnl_str,autoswitch=16384,alloc=2048,exten=2048"

# Also because this test does SLOWFILL type of updates, we need to have a very small inter-update time (gtm_test_wait_factor)
# in order to exercise jnl autoswitch. But because we do not want a lot of updates, the inter-update time should not be too
# low either. Therefore we currently maintain it at 0.02. This value needs to be changed with care.
setenv gtm_test_wait_factor 0.02 # 0.02 second delay between updates in slowfill.m. See comment above for why it is what it is

#AREG is local, all others for remote GT.CM servers
source $gtm_tst/com/dbcreate.csh mumps 6 255 1010 4096 2048 2048 2048
$gtm_tst/com/jnl_on.csh
$rsh $tst_remote_host_1  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_1 ; cd $SEC_DIR_GTCM_1; $gtm_tst/com/jnl_on.csh"
$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2; $gtm_tst/com/jnl_on.csh"
#
echo "# Start imptp updates"
setenv gtm_test_dbfill "SLOWFILL"
setenv gtm_test_jobcnt 5
setenv gtm_test_dbfillid 0
setenv gtm_test_jobid 1
$gtm_tst/com/imptp.csh >>&! imptp.out
#
setenv gtm_test_jobcnt 4
setenv gtm_test_dbfillid 1
setenv gtm_test_jobid 2
$source_dir/send_env.csh	# To reflect the changes in gtm_test_jobcnt, gtm_test_dbfillid and gtm_test_jobid
$rsh $tst_remote_host_1  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_1 ; cd $SEC_DIR_GTCM_1; $gtm_tst/com/imptp.csh >>&! imptp.out"
#
setenv gtm_test_jobcnt 3
setenv gtm_test_dbfillid 2
setenv gtm_test_jobid 3
$source_dir/send_env.csh	# To reflect the changes in gtm_test_jobcnt, gtm_test_dbfillid and gtm_test_jobid
$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2; $gtm_tst/com/imptp.csh >>&! imptp.out"
#
echo "# independant dbfill program has started in local client, and two remote gtcm servers"
#
sleep 15	# Allow some updates
echo "# Switch the journals in the local client"
$gtm_tst/$tst/u_inref/jnl_on2.csh
echo "# Switch the journals on the remote gtcm server 1"
$rsh $tst_remote_host_1  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_1 ; cd $SEC_DIR_GTCM_1; $gtm_tst/$tst/u_inref/jnl_on2.csh"
echo "# Switch the journals on the remote gtcm server 2"
$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2; $gtm_tst/$tst/u_inref/jnl_on2.csh"
#
echo "# Invoke pini_pfini.csh"
$gtm_tst/$tst/u_inref/pini_pfini.csh >>& pini_pfini.out
sleep 15	# Allow some updates
#
echo "# Now stop all dbfill processes"
#
$rsh $tst_remote_host_1  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_1 ; cd $SEC_DIR_GTCM_1; setenv gtm_test_dbfillid 1; setenv gtm_test_jobid 2; $gtm_tst/com/endtp.csh >>&! endtp.out"
$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2; setenv gtm_test_dbfillid 2; setenv gtm_test_jobid 3; $gtm_tst/com/endtp.csh >>&! endtp.out"
setenv gtm_test_dbfillid 0
setenv gtm_test_jobid 1
$gtm_tst/com/endtp.csh >>&! endtp.out
#
echo "# Check the application integrity"
$gtm_tst/com/checkdb.csh
$rsh $tst_remote_host_1  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_1 ; cd $SEC_DIR_GTCM_1; setenv gtm_test_dbfillid 1; setenv gtm_test_jobid 2; $gtm_tst/com/checkdb.csh >>&! checkdb.out; cat checkdb.out"
$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2; setenv gtm_test_dbfillid 2; setenv gtm_test_jobid 3; $gtm_tst/com/checkdb.csh >>&! checkdb.out; cat checkdb.out"
#
echo "# Check the database integrity"
$gtm_tst/com/dbcheck.csh
############################################################################################################################################################
### GTCM SERVER has stopped at this point
############################################################################################################################################################
#
\mkdir ./save; \cp -f {*.dat,*.mjl*} ./save
$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2; \mkdir ./save; \cp -f {*.dat,*.mjl*} ./save"
echo "# Do Database extract after stopping GTCM servers:"
echo "# Local: $MUPIP extract back_extr_fail.glo"
$MUPIP extract back_extr_fail.glo
##
set save_gld = "$gtmgbldir"	# Save gtmgbldir
setenv gtmgbldir local.gld
$GDE << xyz
ch -seg DEFAULT -file=a.dat
exit
xyz
echo "# Local: $MUPIP extract db_extract.glo"
$MUPIP extract db_extract.tmp >& db_extract.out
$tail -n +3 db_extract.tmp > db_extract.glo
setenv gtmgbldir $save_gld	# Must restore gtmgbldir
echo "# Remote: db_extract.csh"
$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM; cd SEC_DIR_GTCM; $gtm_tst/com/db_extract.csh db_extract.glo"
####
#
if (! $gtm_test_jnl_nobefore) then
	echo "# Local: Do $MUPIP journal -recover -back '*' :: will fail"
	$MUPIP journal -recover -back "*"
	#
	setenv gtmgbldir local.gld
	$gtm_tst/$tst/u_inref/repeat_recov.csh
	setenv gtmgbldir $save_gld	# Must restore gtmgbldir
	echo "# Remote1: Recover -back"
	$rsh $tst_remote_host_1  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_1 ; cd $SEC_DIR_GTCM_1; $gtm_tst/$tst/u_inref/repeat_recov.csh"
	echo "# Remote2: Recover -back"
	$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2; $gtm_tst/$tst/u_inref/repeat_recov.csh"
	echo "# Do Database extract after recover -back:"
	##
	setenv gtmgbldir local.gld
	echo "# Local: $MUPIP extract back.glo"
	$MUPIP extract back.tmp >& back.out
	$tail -n +3 back.tmp > back.glo
	setenv gtmgbldir $save_gld	# Must restore gtmgbldir
	echo "# Remote: db_extract.csh"
	$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM; cd SEC_DIR_GTCM ; $gtm_tst/com/db_extract.csh back.glo"
	echo "# Local: diff back.glo db_extract.glo"
	$tst_cmpsilent back.glo db_extract.glo ; if ($status) echo "Files back.glo and db_extract.glo differ. Recover failed!"
	$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM; cd SEC_DIR_GTCM ; $tst_cmpsilent back.glo db_extract.glo ; if ($status) echo 'Files back.glo and db_extract.glo differ. Recover failed!'"
endif
####
echo "# Local : $MUPIP create"
\rm -f *.dat; $MUPIP create -reg=AREG
echo "# Remote1: $MUPIP create"
$rsh $tst_remote_host_1  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_1 ; cd $SEC_DIR_GTCM_1; \rm -f *.dat; $MUPIP create >& create.out"
echo "# Remote2: $MUPIP create"
$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2; \rm -f *.dat; $MUPIP create >& create.out"
####
echo "# Local: $MUPIP journal -recover -forward a_curr.mjl"
$gtm_tst/$tst/u_inref/forward_recov.csh "a_curr.mjl"
echo "# Remote1: Do $MUPIP journal -recover -forward c_curr.mjl,e_curr.mjl,mumps_curr.mjl"
$rsh $tst_remote_host_1  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_1 ; cd $SEC_DIR_GTCM_1; $gtm_tst/$tst/u_inref/forward_recov.csh c_curr.mjl,e_curr.mjl,mumps_curr.mjl"
echo "# Remote2: Do $MUPIP journal -recover -forward b_curr.mjl,d_curr.mjl,mumps_curr.mjl"
$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2; $gtm_tst/$tst/u_inref/forward_recov.csh b_curr.mjl,d_curr.mjl,mumps_curr.mjl"
###
setenv gtmgbldir local.gld
echo "# Do Database extract after recover -forward:"
echo "# Local: $MUPIP extract forward.glo"
$MUPIP extract forward.tmp >& forward.out
$tail -n +3 forward.tmp > forward.glo
setenv gtmgbldir $save_gld	# Must restore gtmgbldir
echo "# Remote: db_extract.csh"
$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM; cd SEC_DIR_GTCM ; $gtm_tst/com/db_extract.csh forward.glo"
echo "Local: diff forward.glo db_extract.glo"
$tst_cmpsilent forward.glo db_extract.glo ; if ($status) echo "Files forward.glo and db_extract.glo differ. Recover failed!"
echo "# Remote: diff forward.glo db_extract.glo"
$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM; cd SEC_DIR_GTCM ; $tst_cmpsilent forward.glo db_extract.glo ; if ($status) echo "Files forward.glo and db_extract.glo differ. Recover failed!""
#
echo "# Now do dbcheck again:"
$gtm_tst/com/dbcheck_base.csh a
$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM; cd SEC_DIR_GTCM ; $gtm_tst/com/dbcheck_base.csh"
####
echo "# Test Finished"
