#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################

#
# C9905-001119A Test that TP with WRITE-ONLY references to NOISOLATION globals causes negligible TP restarts
#
# V6.3-013 removed the NOISOLATION optimization for MM (see https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1166#note_951687754).
# Since the lack of this NOISOLATION optimization breaks this test under MM, we temporarily force the test to use BG. Whenever
# NOISOLATION optimization for MM is restored, we will remove the below line.
setenv acc_meth BG

$gtm_tst/com/dbcreate.csh mumps

$GTM << GTM_EOF
        do ^c001119a
GTM_EOF

set searchstr = ": # of Tp total Retries"

# First check that we are indeed searching for the right string in the DSE DUMP -FILE output for tp restarts
@ TRnum = `$grep -w "TR[0-9]" $gtm_inc/tab_gvstats_rec.h | wc -l`
@ dseretrynum = `$grep "# of Tp total Retries" $gtm_inc/tab_gvstats_rec.h | wc -l`
if (($TRnum == 0) || ($TRnum != $dseretrynum)) then
	echo "TEST-E-C001119A : Test needs to be fixed to search for the right string for TP retries"
	echo 'TEST-E-C001119A : Currently it searches for "'$searchstr'". Fix this to match tab_gvstats_rec.h'
	echo "TEST-E-C001119A : TRnum = [$TRnum] : dseretrynum = [$dseretrynum]"
	exit -1
endif

set retryarray = `$DSE dump -file -all |& $grep "$searchstr" | $tst_awk '{print $NF}' | sed 's/0x0*//g'`
# retryarray will now contain hexadecimal values like "8E6 1F" corresponding to retry[0], retry[1] etc.
# Now all of these need to be added to get the total # of restarts.
set sumretries = `echo "$retryarray" | sed 's/ /+/g'`
setenv totretries `$gtm_tst/com/radixconvert.csh h2d $sumretries | $tst_awk '{print $5}'`
# Now check that the total # of restarts is less than a small fraction of the total # of transactions
$GTM << GTM_EOF
	do retrychk^c001119a
GTM_EOF

$gtm_tst/com/dbcheck.csh
