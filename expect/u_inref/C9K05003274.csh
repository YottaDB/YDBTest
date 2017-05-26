#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.log
expect -f $gtm_tst/$tst/inref/c003274.exp >& expect.log
echo "# This should produce NO output because CTRLC is not in the output"
$grep CTRL expect.log
echo "# This should print TWO jobexam file paths"
$gtm_dist/mumps -run verify^c003274
$gtm_tst/com/dbcheck.csh >& dbcheck.log
