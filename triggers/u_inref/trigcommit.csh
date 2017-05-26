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

# Test that TCOMMIT inside of trigger (to balance TSTART outside of trigger) errors out at TCOMMIT time
$gtm_tst/com/dbcreate.csh mumps 1 	>& dcreate1.log
$gtm_exe/mumps -run trigcommit
$gtm_tst/com/dbcheck.csh		>& dbcheck1.log
