#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "------------------------------------------------------------------------------------------------------"
echo "Test that a LOCK command subsequent to a LOCK command that failed does not fail with BADLOCKNEST error"
echo "------------------------------------------------------------------------------------------------------"
$gtm_tst/com/dbcreate.csh mumps
$GTM << aaa
lock x:y
lock +x
aaa
$gtm_tst/com/dbcheck.csh
