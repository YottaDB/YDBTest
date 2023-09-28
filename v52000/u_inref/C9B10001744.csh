#!/usr/local/bin/tcsh
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
#
setenv gtm_test_use_V6_DBs 0 # Disable V6 DB mode due to differing std_null_collation default
#
# C9B10-001744 $Order() can return wrong value if 2nd expr contains gvn
#
$gtm_tst/com/dbcreate.csh mumps 1
$DSE << DSE_EOF
	change -file -null=TRUE
DSE_EOF

$GTM << GTM_EOF
	do ^c001744
GTM_EOF
$gtm_tst/com/dbcheck.csh
