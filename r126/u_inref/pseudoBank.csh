#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test of simulated banking transactions using M with multiple jobs
#
#

echo '# Test of simulated banking transactions using M with 10 processes/jobs'

#SETUP of the driver M file
cp $gtm_tst/$tst/inref/pseudoBank.m .

$gtm_tst/com/dbcreate.csh mumps

# run the driver
$gtm_dist/mumps -r pseudoBank

cp $gtm_tst/com/pseudoBankDisp.m .
$gtm_dist/mumps -r pseudoBankDisp
$gtm_tst/com/dbcheck.csh
