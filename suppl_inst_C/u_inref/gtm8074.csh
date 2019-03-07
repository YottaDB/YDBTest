#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# GTM-80974 Test interrupted fetchresync rollback on supplementary instance works
#

source $gtm_tst/com/gtm_test_setbeforeimage.csh
$MULTISITE_REPLIC_PREPARE 2 2	# start 2 non-supplementary instances (A,B) and 1 supplementary (P)

$gtm_tst/com/dbcreate.csh mumps

echo
echo "===>Start replication A->B, P->Q and A->P"
echo
setenv needupdatersync 1
$MSR START INST1 INST2 RP
# Do some updates on A to inflate jnl_seqno of A before starting A->P connection.
# Database wise, A has no data but seqno wise it has a seqno much greater than 1.
# This tests that strm_seqno of A can be greater than the unified jnl_seqno on P and things still work.
$MSR RUN INST1 '$gtm_exe/mumps -run updinstA1^gtm8074'
$MSR START INST3 INST4 RP
$MSR START INST1 INST3 RP
unsetenv needupdatersync

$MSR RUN INST3 '$gtm_exe/mumps -run updinstP1^gtm8074'
$MSR RUN INST1 '$gtm_exe/mumps -run updinstA2^gtm8074'
$MSR RUN INST3 '$gtm_exe/mumps -run updinstP2^gtm8074'
$MSR RUN INST3 '$MUPIP set -journal="enable,on,before" -reg "*" >&! cutnewjnlfiles.out'

echo "# Wait for ZERO backlog on A->P side"
$MSR SYNC INST1 INST3

echo "# Shut receiver side of A->P connection"
$MSR STOPRCV INST1 INST3

echo "# Wait for ZERO backlog on P->Q side"
$MSR SYNC INST3 INST4

echo "# Shut source side of P->Q connection"
$MSR STOPSRC INST3 INST4

echo "# Break previous journal link on P before ROLLBACK"
# Redirect the output of the below command to a file, since if freeze is randomly enabled,
# we might see output about waiting for the freeze to be lifted, which would cause reference file issues.
# Also if $expect_leftover_shm is set, we might have leftover db shm which will prevent us from getting standalone
# access (we will get a MUUSERLBK error instead) so use -bypas to avoid getting standalone access.
if ($gtm_test_qdbrundown) then
	set bypas = "-bypas"
else
	set bypas = ""
endif
$MSR RUN INST3 '$MUPIP set -jnlfile -noprevjnlfile '$bypas' mumps.mjl' >& mupip_set_jnlfile.log

echo "# Shut source side of A->P connection"
$MSR STOPSRC INST1 INST3 RESERVEPORT

echo "# Start fetchresync rollback. This should hang due to no source server. And then kill the hung rollback."
# Do it inside a script as otherwise it is not easy to get backgrounding to run fine from the shell command line inside a MSR framework command.
$MSR RUN RCV=INST3 SRC=INST1 '$gtm_tst/$tst/u_inref/gtm8074_rollback_bg.csh __RCV_PORTNO__ >&! rollback_hangkill.out'

echo "# Restart source side of A->P connection"
$MSR STARTSRC INST1 INST3 RP

# Since journal previous links are cut, it is not possible to do forward rollback in this test.
# So pass -backward explicitly to mupip_rollback.csh below.
echo "# Redo fetchresync rollback. This should work fine. And exercise INTERRUPTED ROLLBACK code"
$MSR RUN RCV=INST3 SRC=INST1 '$gtm_tst/com/mupip_rollback.csh -backward -verbose -fetchresync=__RCV_PORTNO__ "*"' >&! rollback2.log

echo "# Log interesting portions of rollback2.log"
$grep -E "Gtmrecv_fetchresync|RESOLVESEQSTRM|RLBKJNSEQ|RLBKSTRMSEQ|Rollback successful" rollback2.log

$gtm_tst/com/dbcheck.csh -extract
