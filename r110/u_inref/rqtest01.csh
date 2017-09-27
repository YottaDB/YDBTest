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

echo '# Test of reverse $query on local variables for the following scenarios'
echo '#	1) LVNULLSUBS error. Also test that LVNULLSUBS error is NOT issued if only the last subscript is ""'
echo '#	2) GTMNULLCOLL vs STDNULLCOLL differences'
echo '# Also randomly test indirection for first parameter to $query'

foreach querydir (1 -1)
	foreach lctstdnull (1 0)
		setenv gtm_lct_stdnull $lctstdnull
		$gtm_dist/mumps -run rqtest01 0 $querydir
		$gtm_dist/mumps -run rqtest01 1 $querydir
		$gtm_dist/mumps -run rqtest01 2 $querydir
		$gtm_dist/mumps -run rqtest01 3 $querydir
	end
end
