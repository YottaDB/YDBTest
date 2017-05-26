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
# many_nulls.csh - the external filter on the receiver will randomly change sets to nulls
echo "External Filter test with changes on receiver side to randomly change sets to nulls"
# This test does backward recovery (and before image journaling) which is not suppored by MM access method. Force BG access method
source $gtm_tst/com/gtm_test_setbgaccess.csh
# this test has jnl extract output, so let's not change the tn
setenv gtm_test_disable_randomdbtn
setenv gtm_test_mupip_set_version "disable"
setenv gtm_tst_ext_filter_rcvr "$gtm_exe/mumps -run ^manynulls"
setenv tst_jnl_str "-journal=enable,on,before,autoswitchlimit=16384"
$gtm_tst/com/dbcreate.csh mumps 1
($gtm_dist/mumps -run updates >& num_updates&)
# sleep for up to 60 seconds or until at least 10 journals have been cut
set cnt=1
while ( 60 > $cnt )
	sleep 1
	@ cnt++
	set num_jnls=`ls -1 | $grep mumps.mjl_ | wc -l`
	if ( 10 < $num_jnls ) then
		break
	endif
end
$GTM <<EOF
set ^quit="done"
EOF
# backup 80% of the time loop
@ goback = ($cnt * 4) / 5
# make sure the time is at least 2 seconds
if (2 > $goback) then
	set goback = $cnt
endif
# wait for the updates.m routine to stop
set pid=`cat updates_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid 120
if ($status) then
	echo "TEST-E-ERROR process $pid did not die."
endif
#
echo "Expect DATABASE EXTRACT to fail due to manynulls changes on receiver side"
$gtm_tst/com/dbcheck.csh -extract

cd $SEC_DIR
mkdir SAVE
cp -rf mumps* SAVE
$MUPIP journal -recover -back -lost=x.los "*" -since=\"0 00:00:$goback\" -verbose >& $PRI_DIR/recover.out
# get the globals for comparison to those extracted before the roll-back
$gtm_dist/mumps -direct << EOF
do ^%G
recover.glo
*

halt
EOF
cd $PRI_DIR
$tail -n 4 recover.out
cp $SEC_DIR/recover.glo .
diff sec*.glo recover.glo
