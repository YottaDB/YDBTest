#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that MUMPS and LKE handle correctly control-C
#

$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.log
$gtm_dist/mupip set -lock=5000 -region "*" >>& dbcreate.log

# Use xterm
setenv TERM xterm

# Enable debugging? ATM, no
set debug = "-d" ; set debug = ""

# Start lockjob
$gtm_dist/mumps -run startlockjob^ctrlc

expect ${debug} -f $gtm_tst/$tst/inref/ctrlc.exp >& ctrlc.out
$grep 'Verification' ctrlc.out

# Stop lockjob
$gtm_dist/mumps -run stoplockjob^ctrlc

$gtm_tst/com/dbcheck.csh >& dbcheck.log
