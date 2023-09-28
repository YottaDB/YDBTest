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
#
# Test that LOCK accepts extended reference syntax for nrefs in the form of locals

setenv gtm_test_use_V6_DBs 0	  # Disable V6 DB mode due to differences in LKE LOCKSPACEINFO/LOCKSPACEUSE messages

$gtm_tst/com/dbcreate.csh mumps 1 255 1000

$GTM << GTM_EOF
d ^c002209
GTM_EOF
$gtm_tst/com/dbcheck.csh
