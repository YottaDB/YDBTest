#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2005-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# check MUPIP UPGRADE,DOWNGRADE feature of GT.M
# The test is divided into 5 sections as per the test plan
#
# priorver.txt is to filter the old version names in the reference file
echo $v4ver >& priorver.txt
# alias to use v4 databases
alias restore 'cp -f mumps_v4.dat mumps.dat;cp -f mumps_v4.gld mumps.gld'
# This test uses databases that are not fully upgraded and runs dbcheck. If gtm_test_online_integ is set to
# "-online" then SSV4NOALLOW will be issued. So, we better turn off online integ for the dbchecks done as
# a part of this test.
setenv gtm_test_online_integ ""
# The test uses a pre-created V4 database and does a series of mupip upgrades and downgrades.
# Disable gtm_db_counter_sem_incr when run with the current version as otherwise we will get
# ENO34/ERANGE errors when using the current version.
setenv gtm_db_counter_sem_incr 1

#
###############################################################################################
# 					section 1 					      #
echo ""
echo "Begin Section 1"
echo ""
# create V5 database
$gtm_tst/com/dbcreate.csh mumps
# run mupip upgrade on V5 db.
echo "Attempting MUPIP UPGRADE on V5 db. Should error out"
cp $gtm_tst/$tst/inref/yes.txt .
$MUPIP upgrade mumps.dat < yes.txt
rm -f mumps.dat mumps.gld
###############################################################################################
# 					section 2 					      #
echo ""
echo "Begin Section 2"
echo ""
# switching to a random V4 version
# v4ver env. variable is set from random_v4.csh called in instream.csh
# v4ver variable carries the random V4 version number to be used here
$sv4
echo "version switched to is "$v4ver
# use the already prepared too-full blocks V4 database
source $gtm_tst/$tst/u_inref/v4dat.csh
cp -f mumps.dat mumps_v4.dat
cp -f mumps.gld mumps_v4.gld
# run onlnread.m concurrently here it checks for GV.Tree & D.Tree integrity
($gtm_exe/mumps -run ^onlnread < /dev/null >>& onlnread_mupip1.out&) >&! bg1.out
$gtm_tst/$tst/u_inref/wait_for_onlnread_to_start.csh 60
echo "Attempting V5 MUPIP UPGRADE without stand alone acces. Should issue MUSTANDLONE error"
$MUPIPV5 upgrade mumps.dat < yes.txt
# stop concurrently running onlnread.m, making global ^stop=1 ensures concurrently running onlnread.m stops
$GTM << gtm_eof
set ^stop=1
halt
gtm_eof
set pid = `cat concurrent_job.out`
# this is to ensure the above process stops and properly run down to start next set of commands
$gtm_tst/com/wait_for_proc_to_die.csh $pid -1
rm -f concurrent_job.out
# check for errors reported by onlnread
if (`$grep -v "PASS" onlnread_mupip1.out|wc -l`) then
        echo "TEST-E-ERROR Verification failed for GT & DT.Pls. check onlnread_mupip1.out"
	cat onlnread_mupip1.out
endif
###############################################################################################
# 					section 3 					      #
echo ""
echo "Begin Section 3"
echo ""
rm -f mumps.dat mumps.gld
# use the v4 db already created
restore
echo "Attempting MUPIP UPGRADE without running dbcertify.Should issue MUUPGRDNRDY error"
$MUPIPV5 upgrade mumps.dat < yes.txt
echo "Attempting MUPIP DOWNGRADE on a V4 db.Should issue BADDBVER error"
$MUPIPV5 downgrade mumps.dat < yes.txt
###############################################################################################
# From here the randomness part of the test begins. This is constructed into another script
# and we call the script here redirecting the output.
# The output will be filtered thro' sed script to avoid reference file issues.
###############################################################################################
$gtm_tst/$tst/u_inref/mupip_upgrd_dwngrd_base.csh >>&! mupip_upgrd_dwngrd_base.log
$tst_awk -f $gtm_tst/$tst/inref/filter_64bittn.awk mupip_upgrd_dwngrd_base.log
#
$tst_gzip reorg_toobig_up.out mupip.err* mupip_upgrd_dwngrd_base.log tnreset.log
$sv5
$gtm_tst/com/dbcheck.csh -noonline
echo "Clean up ftok semaphore which will be left around from the BADDBVER error from the dbcheck.csh call"
$MUPIP rundown -reg DEFAULT
# end of test
