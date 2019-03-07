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

echo '# Test $query(gvn) and $order(gvn), both forward & backward, for spanning regions'

$gtm_dist/mumps -run creategld^rqtest13		# creates file mumps.gde with GDE commands
setenv test_specific_gde `pwd`/mumps.gde
$gtm_tst/com/dbcreate.csh mumps
$gtm_dist/mumps -run init^rqtest13		# load data

foreach querydir (1 -1)
	echo "##### Executing rqtest13 with querydir=$querydir #####"
	$gtm_dist/mumps -run rqtest13 $querydir
end

$gtm_tst/com/dbcheck.csh
