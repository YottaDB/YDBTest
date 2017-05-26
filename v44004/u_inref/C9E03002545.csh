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
# C9E03002545 Add full block write to GTM
#
# the output of this test relies on transaction numbers, so let's not do anything that might change the TN
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
# Journaling is turned on explicitly in this test. So let's not randomly enable it in dbcreate.csh
setenv gtm_test_jnl NON_SETJNL

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

$gtm_tst/com/dbcreate.csh mumps 1 64 1000 8192
$MUPIP set -journal="on,enable,before" -reg "*" |& sort -f
#
# set the full block write on
echo "Turn the full block writes on"
setenv gtm_fullblockwrites 1
echo "************"
echo 'GTM updates'
echo ""
$GTM << aaa
  for i=1:1:1000 s ^a(i)="a"_i
  h 1
  for i=1:1:1000 s ^b(i)="b"_i
aaa
echo "************"
echo "DSE dump -f -all"
echo ""
$DSE dump -f -all >& dse_dump.txt
$grep "Full Block Writes" dse_dump.txt
#
echo "************"
echo 'MUPIP integ -reg *'
echo ""
$MUPIP integ -reg "*"
#
echo "************"
echo 'MUPIP reorg -fill=30'
echo ""
$MUPIP reorg -fill=30
#
echo "************"
echo 'MUPIP extract extr.glo'
echo ""
$MUPIP extract extr.glo
#
echo "************"
echo 'MUPIP load extr.glo'
echo ""
$MUPIP load extr.glo
#
echo "************"
echo 'MUPIP backup *'
echo ""
$MUPIP backup "*" ./backup
#
echo "************"
echo 'MUPIP journal -recov -back * -since=0 0:0:1'
echo ""
$MUPIP journal -recov -back "*" -since=\"0 0:0:1\"
#
echo " Do the dbcheck."
$gtm_tst/com/dbcheck.csh
#
echo "Turn the Full Block writes off"
setenv gtm_fullblockwrites 0
$DSE dump -f -all >& dse_dump2.txt
$grep "Full Block Writes" dse_dump2.txt
#
$gtm_tst/com/dbcheck.csh
