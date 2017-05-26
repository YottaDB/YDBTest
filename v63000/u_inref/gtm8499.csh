#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# GTM-8499 KILL ^GBLNODE terminates abnormally with SIG-11 in rare situations

echo "Create single-region database with record size of 900"
$gtm_tst/com/dbcreate.csh mumps -record_size=900

setenv gtmdbglvl 0x00040000	# set this to make sure we dont use freed memory (else we will get a SIG-11)

echo ""
echo "mumps -run gtm8499"
$gtm_dist/mumps -run gtm8499
echo ""

echo "Run dbcheck"
$gtm_tst/com/dbcheck.csh
