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
# do a mean thing to a database to see that MUPIP INTEG -FAST -ONONLINE does not explode
setenv gtm_test_disable_randomdbtn 1
$gtm_tst/com/dbcreate.csh -block_size=1024 -key_size=64
$gtm_dist/mumps -run gtm8481
$DSE change -fileheader  -current_tn=1011
# success is for the following INTEG does not core out
$MUPIP integ -noonline -fast -full -region default >& integ.outx
$grep -Ev 'DBLOCMBINC|DBMRKBUSY|DBTNLTCTN|INTEGERRS' integ.outx > integ.out
# no dbcheck.csh because we intentionally damaged the database
echo Done.
