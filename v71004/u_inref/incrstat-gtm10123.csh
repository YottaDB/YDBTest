#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-10123 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-004_Release_Notes.html#GTM-DE1959410123)

\$VIEW "GVSTAT", ZSHOW "G" and %YGBLSTAT report the count of \$INCREMENT() operations labeled INC. \$INCREMENT() operations are are still included in the SET count. Previously, these operations were only included in the SET count. (GTM-10123)

CAT_EOF
echo

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out

echo '### Test $VIEW "GVSTAT", ZSHOW "G" and %YGBLSTAT report the count of $INCREMENT() operations labeled INC'

$gtm_dist/mumps -run %XCMD "set ^total=0"
foreach num (1 4 10 20 100 2000)
	echo
	foreach var (y z)
		$gtm_dist/mumps -run gtm10123 $num "^$var"
	end
end

$gtm_tst/com/dbcheck.csh >& dbcheck.out
