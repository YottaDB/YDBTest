#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Test To do: 24
# ----------------
# R1    R2    R3
# ----------------
#	T1    T1
# T2    T2
#       T3    T3
# -----------------
# If during the recovery only R2,R3 is specified, T3 will now be considered LOST.
# This is because the LOST determination happens as a union of R2 and R3 (the regions involving T3)
# At the time of playing T3, R3 has only seen GOOD tns whereas R2 has seen a BROKEN tn (T2).
# Therefore since at least one region has seen a broken tn, T3 even though being GOOD will
# be treated as a LOST transaction.
# Note: The above scenario also tests that "a broken transaction followed by a good tn in the same jnl file" works.
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps 4
$gtm_tst/com/jnl_on.csh
echo "Start updates"
echo `date +'%d-%b-%Y %H:%M:%S'` > time1.txt
$GTM << GTMEND
do init^tpmultireg
do lostmultireg^tpmultireg
GTMEND
set time1=`cat time1.txt`
# Do backward recovery with only region R2 and R3
$MUPIP journal -recover -back -since=\"$time1\" -lost=$PWD/c.lost b.mjl,c.mjl
echo "DB Extract"
$MUPIP extract extract.glo
cat extract.glo
echo "Broken transaction file for region BREG"
$gtm_tst/$tst/u_inref/extr_req_info.csh "b.broken"
echo "Lost transaction file for region CREG"
# Sort output since the order of records within a multi-region TP transaction is non-deterministic
$gtm_tst/$tst/u_inref/extr_req_info.csh "c.lost" | sort
$gtm_tst/com/dbcheck.csh

