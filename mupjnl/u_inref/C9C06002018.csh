#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2003, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
$gtm_tst/com/dbcreate.csh mumps 1
setenv gtmgbldir "mumps.gld"
#
if ($?test_replic == 0) then
	$MUPIP set -journal="enable,on,before" -reg "*"
endif
#
$GTM << gtm_eof
d in5^sfill("set",1,1)
gtm_eof
#
echo "Backward recovery ......"
ls -lart > out1.txt
set format="%Y %m %d %H %M %S %Z"
set time1=`date +"$format"`
$MUPIP journal -recover -backward  "*" >>& rec_bak.log
set stat1=$status
set time2=`date +"$format"`
ls -lart > out2.txt
#

echo "Check the time stamps ......"
echo $time1 " " $time2 >>& time_diff.txt
@ difftime =`$tst_awk -f $gtm_tst/$tst/inref/diff_time.awk time_diff.txt`
if ($difftime > 10) then
	echo "C9C06002018 TEST FAILED because it took too long"
	cat rec_bak.log
	exit 1
endif

#don't need this for now
#echo "Check if the output files are the same ......"
diff out1.txt out2.txt > diff.txt

$grep "Recover successful" rec_bak.log
set stat2=$status
if ($stat1 != 0 || $stat2 != 0) then
	echo "C9C06002017 TEST FAILED"
	cat rec_bak.log
	exit 1
endif
$gtm_tst/com/dbcheck.csh -extract
