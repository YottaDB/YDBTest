#################################################################
#								#
# Copyright (c) 2003-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "Test case 15 - recov_post_jnl_switch"
$gtm_tst/com/dbcreate.csh mumps 5
echo mupip set -journal=enable,before,ep=300,alignsize=4096 -reg '"*"'
$MUPIP set -journal=enable,before,ep=300,alignsize=4096 -reg "*" |& sort -f
$gtm_tst/com/backup_dbjnl.csh save "*.dat" cp nozip
set time1 = `date +'%d-%b-%Y %H:%M:%S'`
echo time1 = "$time1"
$GTM << aa
w "d t1^test15",! d t1^test15
w "d t2^test15",! d t2^test15
w "d t3^test15",! d t3^test15
h
aa
$gtm_tst/com/dbcheck.csh -noshut >& dbcheck_0.log
# Switch journals: DEFAUTL: 1, AREG: 2, BREG: 3, CREG: 4, DREG: 5
$MUPIP set -journal=enable,before -reg DEFAULT
$MUPIP set -journal=enable,before -reg AREG
$MUPIP set -journal=enable,before -reg AREG
$MUPIP set -journal=enable,before -reg BREG
$MUPIP set -journal=enable,before -reg BREG
$MUPIP set -journal=enable,before -reg BREG
$MUPIP set -journal=enable,before -reg CREG
$MUPIP set -journal=enable,before -reg CREG
$MUPIP set -journal=enable,before -reg CREG
$MUPIP set -journal=enable,before -reg CREG
$MUPIP set -journal=enable,before -reg DREG
$MUPIP set -journal=enable,before -reg DREG
$MUPIP set -journal=enable,before -reg DREG
$MUPIP set -journal=enable,before -reg DREG
$MUPIP set -journal=enable,before -reg DREG
#echo "-------------------------------------------------------------------------"
## Although there are several steps mentioned in test plan,
## they are covered in other tests,  so removed from this subtest
echo mupip journal -recov -back '"*"' -since="time1"
$MUPIP journal -recov -back "*" -since=\"$time1\" >&! back_recov1.out
$grep -vE "MUJNLSTAT|MUJNLPREVGEN|FILERENAME" back_recov1.out
$gtm_tst/com/dbcheck.csh -nosprgde -noshut >& dbcheck_1.log
echo "-------------------------------------------------------------------------"
cp -f ./save/*.dat .
echo mupip journal -recov -forw -verify '"*"'
$MUPIP journal -recov -forw -verify "*"
if ($status) then
	echo "FAILED 0: mupip journal -recov -forward"
	exit 1
endif
$gtm_tst/com/dbcheck.csh -nosprgde -noshut >& dbcheck_2.log
echo "-------------------------------------------------------------------------"
echo "move databases and journals and create new ones"
$gtm_tst/com/backup_dbjnl.csh save "*.dat *.mjl*" mv
$MUPIP create |& sort -f
echo "mupip set -journal=enable,before -reg *"
$MUPIP set -journal=enable,before -reg "*" |& sort -f
sleep 3
$gtm_tst/com/backup_dbjnl.csh save1 "*.dat" cp nozip
echo "Make update only to AREG"
set time2 = `date +'%d-%b-%Y %H:%M:%S'`
echo time2 = "$time1"
$GTM <<aa
f i=1:1:100 s ^a(i)=i
aa
echo "mupip journal -recov -back '*' -since=time2"
$MUPIP journal -recov -back "*" -since=\"$time2\" >&! back_recov2.out
$grep -vE "MUJNLSTAT|MUJNLPREVGEN|FILERENAME" back_recov2.out
$gtm_tst/com/dbcheck.csh -nosprgde -noshut >& dbcheck_3.log
echo "-------------------------------------------------------------------------"
cp -f ./save1/*.dat .
echo mupip journal -recov -forw -verify '"*"'
$MUPIP journal -recov -forw -verify "*"
if ($status) then
	echo "FAILED 1: mupip journal -recov -forward"
	exit 1
endif
$gtm_tst/com/dbcheck.csh -nosprgde -noshut >& dbcheck_4.log
$GTM << aa
w "^a(1)= ",^a(1),", ^a(100)= ",^a(100),!
h
aa
echo "============================================================================"
$gtm_tst/com/dbcheck.csh -nosprgde -noshut >& dbcheck_5.log
echo "END of test"
