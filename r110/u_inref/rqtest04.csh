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

echo '# Test of reverse $query on local variable subtree that contains just the null subscript'

foreach querydir (1 -1)
	foreach lctstdnull (1 0)
		setenv gtm_lct_stdnull $lctstdnull
		$gtm_dist/mumps -run rqtest04 $querydir
	end
end
