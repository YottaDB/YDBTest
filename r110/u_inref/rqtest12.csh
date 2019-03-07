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

echo '# Test $query(gvn,-1) for spanning nodes'

$gtm_tst/com/dbcreate.csh mumps -block=4096 -rec=4096
$gtm_dist/dse change -file -null=TRUE >& rqtest12_dse.out
$gtm_dist/dse change -file -stdnullcoll=TRUE >>& rqtest12_dse.out
$gtm_dist/mumps -run init^rqtest12

foreach querydir (1 -1)
	echo "##### Executing rqtest12 with querydir=$querydir #####"
	$gtm_dist/mumps -run rqtest12 $querydir
end

$gtm_tst/com/dbcheck.csh
