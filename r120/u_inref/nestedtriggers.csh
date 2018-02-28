#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Test nested trigger reloads and TP restarts in multi-process setup"
#
$gtm_tst/com/dbcreate.csh mumps
$gtm_dist/mumps -run nestedtriggers
$gtm_tst/com/dbcheck.csh
