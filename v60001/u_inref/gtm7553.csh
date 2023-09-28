#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Disable V6 DB mode to avoid differences in LKE SHOW commands
setenv gtm_test_use_V6_DBs 0

$gtm_tst/com/dbcreate.csh mumps

$gtm_exe/mumps -run gtm7553

$gtm_tst/com/dbcheck.csh
