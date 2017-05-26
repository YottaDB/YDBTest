#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2004-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# C9D01-002206 [mupipupgrade] leftover ipcs (orphaned semaphores and shared memories)
#
# Journaling is turned on explicitly in this test. So let's not randomly enable it in dbcreate.csh
setenv gtm_test_jnl NON_SETJNL
setenv gtm_test_spanreg 0	# because this test creates databases with integ errors, gensprgde.m will not work easily
				# since this test does not create more than a dozen nodes, there is no need for it to work either.
$gtm_tst/com/dbcreate.csh mumps 8 64 8000 60416 100 512
$MUPIP set -journal="on,enable,before" -reg "*" |& sort -f
#
echo "****************************"
echo 'MUPIP set -glo=64000 -reg *'
echo ""
$MUPIP set -glo=64000 -reg "*" |& sort -f
mkdir backup
$gtm_tst/com/backup_dbjnl.csh save "*.dat" cp nozip
echo "****************************"
echo 'GTM updates all regions'
echo ""
# Lets inhibit the getting of shared memory
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 44
setenv gtm_white_box_test_case_count 1
$GTM << aaa
  s ^a=1
  s ^b=1
  s ^c=1
  s ^d=1
  s ^e=1
  s ^f=1
  s ^g=1
  s ^h=1
aaa
echo "****************************"
echo 'MUPIP integ -reg *'
echo ""
$MUPIP integ -reg "*"
echo "****************************"
echo 'DSE exit'
echo ""
$DSE exit
echo "****************************"
echo 'LKE exit'
echo ""
$LKE exit
#
echo "****************************"
echo 'MUPIP backup *'
echo ""
$MUPIP backup "*" ./backup
echo "****************************"
echo 'MUPIP journal -recov -back *'
echo ""
$MUPIP journal -recov -back "*"
cp save/*.dat .
echo "****************************"
echo 'MUPIP journal -recov -forw *'
echo ""
$MUPIP journal -recover -forw "*"
#
$MUPIP rundown -reg "*" |& sort -f

# dbcheck.csh is meaningless with the above whitebox test case (mupip integ -reg "*" is expected to fail anyway)
#$gtm_tst/com/dbcheck.csh
