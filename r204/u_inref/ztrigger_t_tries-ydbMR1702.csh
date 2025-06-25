#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Test YDB\!1702 : $ztrigger("item") clears t_tries in case of errors'

echo '# Run dbcreate.csh'
$gtm_tst/com/dbcreate.csh mumps

echo "# Run [mumps -run ydbMR1702]"
$gtm_dist/mumps -run ydbMR1702

echo '# Run dbcheck.csh'
$gtm_tst/com/dbcheck.csh
