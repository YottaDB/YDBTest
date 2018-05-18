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
foreach share_opt ("STAT" "NOSTAT")

	if ($share_opt == "STAT") then
		echo "# Testing where database has STATISTICS sharing enabled"
	else
		echo "# Testing where database has STATISTICS sharing disabled"
	endif

	#### testA ####
	echo ''
	echo "# Create a 2 region DB with regions DEFAULT and AREG"
	$gtm_tst/com/dbcreate.csh mumps 2 >>& dbcreate_log.txt

	echo '# Setting DB stat settings'
	$MUPIP set -$share_opt  -reg "*" >>& dbcreate_log.txt

	echo '# Run gtm8699.m'
	$ydb_dist/mumps -run gtm8699


	$gtm_tst/com/dbcheck.csh >>& dbcreate_log.txt

	echo ''
end

