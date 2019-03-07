#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test is similar to rqtest02 except that this is for global variables
echo '# Test of reverse $query on global variables for slightly complex subscripted global variable trees'

$gtm_tst/com/dbcreate.csh mumps
$gtm_dist/mumps -run rqtest08
$gtm_tst/com/dbcheck.csh
