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
echo "Test Case: 10a - ztp_nested"
$gtm_tst/com/dbcreate.csh mumps 1
set time0 = `date +'%d-%b-%Y %H:%M:%S'`
set time0_d = `date +'%m.%d.%H.%M.%S'`
sleep 1
echo "Start before image journaling"
$MUPIP set -journal=enable,before  -reg "*"
$GTM << aa
w "d ^ztp1",! d ^ztp1
aa
set time1 = `cat time1.txt_abs`
set time1_d = `cat time1.txt`
sleep 1
$GTM << aa
w "d ^ztp2wc",! d ^ztp2wc
aa
set time2 = `cat time2.txt_abs`
set time2_d = `cat time2.txt`
set time21 = `cat time21.txt_abs`
set time21_d = `cat time21.txt`
set time22 = `cat time22.txt_abs`
set time22_d = `cat time22.txt`
sleep 1
$GTM << aa
w "d ^ztp3",! d ^ztp3
aa
set time3 = `cat time3.txt_abs`
set time3_d = `cat time3.txt`
echo time0 = "$time0"
echo time0_d = "$time0_d"
echo time1 = "$time1"
echo time1_d = "$time1_d"
echo time2 = "$time2"
echo time2_d = "$time2_d"
echo time21 = "$time21"
echo time21_d = "$time21_d"
echo time22 = "$time22"
echo time22_d = "$time22_d"
echo time3 = "$time3"
echo time3_d = "$time3_d"
set dt22t2 = "`echo $time2_d.$time22_d   | $tst_awk -F \. -f $gtm_tst/com/diff_time.awk -v full=1 | sed 's/^[0-9]*:/0 /g'`"
set dt22t21 = "`echo $time21_d.$time22_d | $tst_awk -F \. -f $gtm_tst/com/diff_time.awk -v full=1 | sed 's/^[0-9]*:/0 /g'`"
set dt22t1 = "`echo $time1_d.$time22_d   | $tst_awk -F \. -f $gtm_tst/com/diff_time.awk -v full=1 | sed 's/^[0-9]*:/0 /g'`"
echo dt22t2 = "$dt22t2"
echo dt22t21 = "$dt22t21"
echo dt22t1 = "$dt22t1"
$gtm_tst/com/backup_dbjnl.csh save "*.dat *.mjl" cp nozip
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
echo "------------------------------------------------------------------------------------------"
cp ./save/* .
echo MUPIP journal -recover -back '"*"' -since=time22  -fence=none -look=\"time=0 0:0:0\"
$MUPIP journal -recover -back "*" -since=\"$time22\" -fence=none -look=\"time=0 0:0:0\"
# expected result: All data updates done in z1, z2 (except z24) and z3 should be visible in the database
#
$GTM <<aa
zwr ^z1,^z21,^z22,^z23,^z3,^z24
aa
echo "------------------------------------------------------------------------------------------"
cp ./save/* .
echo MUPIP journal -recover -back '"*"' -since=time22  -look=\"time=0 0:0:0\"
$MUPIP journal -recover -back "*" -since=\"$time22\"  -look=\"time=0 0:0:0\"
# expected result: All data updates done in z1, z21,z22  should be visible in the database
#
$GTM <<aa
zwr ^z1,^z21,^z22,^z23,^z3
aa
#echo "cat mumps.broken"
#cat mumps.broken
echo "^z23 and ^z24 will be in broken transaction file"
$tst_awk -F "\\" '/^05/ {print $NF}' mumps.broken
echo "^z3 will be in lost transaction file"
$tst_awk -F "\\" '/^05/ {print $NF}' mumps.lost
# The intend is lookback time of 0
echo "------------------------------------------------------------------------------------------"
cp ./save/* .
echo MUPIP journal -recover -back '"*"' -since=time22  -fence=always -look=\"time=0 0:0:0\"
$MUPIP journal -recover -back "*" -since=\"$time22\" -fence=always -look=\"time=0 0:0:0\"
#echo "cat mumps.broken"
#cat mumps.broken
#echo "cat mumps.lost"
#cat mumps.lost
echo "^z23,^z24,^z3 will be in broken transaction file"
$tst_awk -F "\\" '/^05/ {print $NF}' mumps.broken
#
########################################################################
echo "------------------------------------------------------------------------------------------"
# lookback=time22-time2
cp ./save/* .
echo MUPIP journal -recover -back '"*"' -since=time22  -fence=always -look=\"time=time22 - time2\"
$MUPIP journal -recover -back "*" -since=\"$time22\" -fence=always -look=\"time=$dt22t2\"
echo "^z21,^z22,^z23,^z24,^z3 will be in broken transaction file"
$tst_awk -F "\\" '/^05/ {print $NF}' mumps.broken
#echo "cat mumps.broken"
#cat mumps.broken
#echo "cat mumps.lost"
#cat mumps.lost
# expected result:
#
echo "------------------------------------------------------------------------------------------"
# lookback=time22-time21
cp ./save/* .
echo MUPIP journal -recover -back '"*"' -since=time22  -fence=always -look=\"time=time22 - time21\"
$MUPIP journal -recover -back "*" -since=\"$time22\" -fence=always -look=\"time=$dt22t21\"
echo "^z23,^z24,^z3 will be in broken transaction file"
$tst_awk -F "\\" '/^05/ {print $NF}' mumps.broken
#echo "cat mumps.broken"
#cat mumps.broken
#echo "cat mumps.lost"
#cat mumps.lost
# expected result: All data updates done in ztp1 should be visible in the database
#
echo "------------------------------------------------------------------------------------------"
# lookback=time22-time1
cp ./save/* .
echo MUPIP journal -recover -back '"*"' -since=time22  -fence=always -look=\"time=time22 - time1\"
$MUPIP journal -recover -back "*" -since=\"$time22\" -fence=always -look=\"time=$dt22t1\"
echo "^z21,^z22,^z23,^z24,^z3 will be in broken transaction file"
$tst_awk -F "\\" '/^05/ {print $NF}' mumps.broken
# expected result:
#echo "cat mumps.broken"
#cat mumps.broken
#echo "cat mumps.lost"
#cat mumps.lost
#
echo "------------------------------------------------------------------------------------------"
# look=operation
cp ./save/* .
echo MUPIP journal -recover -back '"*"' -since=time22  -fence=always -look=\"operations=1\"
$MUPIP journal -recover -back "*" -since=\"$time22\" -fence=always -look=\"operations=1\"
## expected result:
##
$GTM <<aa
zwr ^z1,^z21,^z22,^z23,^z3,^z24
aa
#
echo "------------------------------------------------------------------------------------------"
# look=operation
cp ./save/* .
echo MUPIP journal -recover -back '"*"' -since=time22  -look=\"operations=2\"
$MUPIP journal -recover -back "*" -since=\"$time22\" -fence=always -look=\"operations=2\"
## expected result:
$GTM <<aa
zwr ^z1,^z21,^z22,^z23,^z3,^z24
aa
#
$gtm_tst/com/dbcheck.csh
echo "End of Test"
