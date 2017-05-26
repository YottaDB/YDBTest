#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This test ensures that MUPIP REPLICATE -INSTANCE_CREATE does NOT rename an existing replication instance file in case of an
# error (like REPLINSTNMUNDEF)
#
# Although this tests MUPIP REPLICATE functionality, we do not need -replic to be turned on for this subtest as no replication
# servers are started
#
#
$echoline
echo "=> Create database and replication instance file"
$echoline
echo
$gtm_tst/com/dbcreate.csh mumps

echo
setenv gtm_repl_instance mumps.repl
$echoline
echo "=> $MUPIP replicate -instance_create -name=INSTA"
$echoline
$MUPIP replicate -instance_create -name=INSTA $gtm_test_qdbrundown_parms

echo
ls -l mumps.{dat,repl*,gld} | $tst_awk '{print $NF}'

echo
echo "Now, try creating another instance file (without -name qualifier) to test that RENAMING does NOT happen"
$echoline
echo "=> $MUPIP replicate -instance_create"
$echoline
echo
$MUPIP replicate -instance_create $gtm_test_qdbrundown_parms

echo
ls -l mumps.{dat,repl*,gld} | $tst_awk '{print $NF}'

echo
echo "Now, by passing a valid -name qualifier with -noreplace flag test that RENAMING still does NOT happen"
$echoline
echo "=> $MUPIP replicate -instance_create -name=INSTA -noreplace"
$echoline
$MUPIP replicate -instance_create -name=INSTA -noreplace $gtm_test_qdbrundown_parms

echo
ls -l mumps.{dat,repl*,gld} | $tst_awk '{print $NF}'

echo
echo "Now, by passing a valid -name qualifier without -noreplace flag test that RENAMING does happen"
$echoline
echo "=> $MUPIP replicate -instance_create -name=INSTA"
$echoline
$MUPIP replicate -instance_create -name=INSTA $gtm_test_qdbrundown_parms

echo
ls -l mumps.{dat,repl*,gld} | $tst_awk '{print $NF}'

echo
$gtm_tst/com/dbcheck.csh
