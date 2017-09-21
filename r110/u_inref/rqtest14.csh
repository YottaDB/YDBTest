#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Test $query(lvn,dir) and $query(gvn,dir) where lvn and gvn have nested indirection and dir is -1 or 1'

$gtm_tst/com/dbcreate.csh mumps

$gtm_dist/mumps -run rqtest14

$gtm_tst/com/dbcheck.csh
