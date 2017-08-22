#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2001-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

echo '# Test that naked indicator is maintained and side-effects are properly handled in $query(lvn,...)'
echo '# Also randomly test indirection for first parameter to $query'

$gtm_tst/com/dbcreate.csh mumps

foreach querydir (1 -1)
	foreach case (a b c d)
		echo "##### Executing rqtest06${case} with querydir=$querydir #####"
		$gtm_dist/mumps -run rqtest06${case} $querydir
	end
end

$gtm_tst/com/dbcheck.csh
