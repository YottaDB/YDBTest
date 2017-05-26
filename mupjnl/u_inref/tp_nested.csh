#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "Test Case: 11 - tp_nested"
$gtm_tst/com/dbcreate.csh mumps 1
set time0 = `date +'%d-%b-%Y %H:%M:%S'`
sleep 1
echo "Start before image journaling"
$MUPIP set -journal=enable,before  -reg "*"
echo "mumps -run ztp1"
cp $gtm_tst/$tst/inref/ztp1.m .
$gtm_exe/mumps -run ztp1
set time1 = `cat time1.txt_abs`
sleep 1
cp $gtm_tst/$tst/inref/tp2tr.m .
echo "mumps -run tp2tr"
$gtm_exe/mumps -run tp2tr
set time2 = `cat time2.txt_abs`
set time21 = `cat time21.txt_abs`
set time22 = `cat time22.txt_abs`
sleep 1
echo "mumps -run ztp3"
cp $gtm_tst/$tst/inref/ztp3.m .
$gtm_exe/mumps -run ztp3
set time3 = `cat time3.txt_abs`
echo time0 = "$time0"
echo time1 = "$time1"
echo time2 = "$time2"
echo time21 = "$time21"
echo time22 = "$time22"
echo time3 = "$time3"
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before cp/mv of dat files
$gtm_tst/com/backup_dbjnl.csh save '*.dat *.mjl*' cp nozip
#
echo "------------------------------------------------------------------------------------------"
echo MUPIP journal -recover -back '"*"'
$MUPIP journal -recover -back "*"
## expected result: No broken transactions
#
echo "------------------------------------------------------------------------------------------"
cp ./save/* .
echo MUPIP journal -recover -back '"*"' -fence=always
$MUPIP journal -recover -back "*" -fence=always
## expected result: No broken transactions.
#
echo "------------------------------------------------------------------------------------------"
cp ./save/* .
echo MUPIP journal -recover -back '"*"' -since=time3
$MUPIP journal -recover -back "*" -since=\"$time3\"
## expected result: No broken transactions
#
echo "------------------------------------------------------------------------------------------"
cp ./save/* .
echo MUPIP journal -recover -back '"*"' -since=time3 -fence=always
$MUPIP journal -recover -back "*" -since=\"$time3\" -fence=always
## expected result:10 broken transactions for ^z3(i)
echo "^z3 will be in broken transaction file"
$tst_awk -F "\\" '/^05/ {print $NF}' mumps.broken
#
echo "------------------------------------------------------------------------------------------"
cp ./save/* .
echo MUPIP journal -recover -back '"*"' -since=time2
$MUPIP journal -recover -back "*" -since=\"$time2\"
## expected result: no broken transactions ..
#
echo "------------------------------------------------------------------------------------------"
cp ./save/* .
echo MUPIP journal -recover -back '"*"' -since=time2 -fence=always
$MUPIP journal -recover -back "*" -since=\"$time2\" -fence=always
## expected result: 10 broken transactions for ^z3(i), otherwise all updates in ztp2 should have been recovered and present in
## the database
$GTM <<aa
zwr ^z1,^z21,^z22,^z23,^z24
aa
echo "^z3 will be in broken transaction file"
$tst_awk -F "\\" '/^05/ {print $NF}' mumps.broken

echo MUPIP journal -show=broken_transactions -back '"*"'
$MUPIP journal -show=broken_transactions -back '"*"'
#
echo "------------------------------------------------------------------------------------------"
cp ./save/* .
echo MUPIP journal -recover -back '"*"' -since="time1"
$MUPIP journal -recover -back "*" -since=\"$time1\"
# expected result: no broken  transaction
#
echo "------------------------------------------------------------------------------------------"
cp ./save/* .
echo MUPIP journal -recover -back '"*"' -since=time1 -fence=always
$MUPIP journal -recover -back "*" -since=\"$time1\" -fence=always
# expected result: 10 broken transactions for ^z1(i) and ^z3(i) and all updates in ztp2 should be in  the lost transaction file.
# The database should not contain any data
#
$GTM <<aa
zwr ^z1,^z21
aa
echo "^z1 nd ^z3 will be in broken transaction file"
$tst_awk -F "\\" '/^05/ {print $NF}' mumps.broken
echo "^z2 will be in lost transaction file"
$tst_awk -F "\\" '/^05/ {print $NF}' mumps.lost

echo "------------------------------------------------------------------------------------------"
cp ./save/* .
echo MUPIP journal -recover -back '"*"' -since=time1 -fence=none
$MUPIP journal -recover -back "*" -since=\"$time1\" -fence=none
# expected result: All data updates done in ztp1, ztp2 and ztp3 should be visible in the database
#
$GTM <<aa
zwr ^z1,^z21,^z22,^z23,^z3,^z24
aa
echo "------------------------------------------------------------------------------------------"
#echo "Step  j  from test plan;"
cp ./save/* .
echo MUPIP journal -recover -back '"*"' -since=time1 -fence=process
$MUPIP journal -recover -back "*" -since=\"$time1\" -fence=process
# expected result: All data updates done in ztp1, ztp2 and ztp3 should be visible in the database
#
$GTM <<aa
zwr ^z1,^z21,^z22,^z23,^z3,^z24
aa
#####################################################
### rest of them are moved to a test10a
##echo " from  step k to  the rest are moved to another subtest"
$gtm_tst/com/dbcheck.csh
echo "End of test"
