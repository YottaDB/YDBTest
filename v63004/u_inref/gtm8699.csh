#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Turn off statshare related env var as it affects test output and is not considered worth the trouble to maintain
# the reference file with SUSPEND/ALLOW macros for STATSHARE and NON_STATSHARE
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

#
foreach share_opt ("STATS" "NOSTATS")

	if ($share_opt == "STATS") then
		echo "# Testing where database has STATISTICS sharing enabled"
	else
		echo "# Testing where database has STATISTICS sharing disabled"
	endif

	#### testA ####
	echo ''
	echo "# Create a 2 region DB with regions DEFAULT and AREG"
	$gtm_tst/com/dbcreate.csh mumps 2 >>& dbcreate_log.txt
	if ($status) then
		echo "DB Create Failed, Output Below"
		cat dbcreate_log.txt
	endif

	echo '# Setting DB stat settings'
	$MUPIP set -$share_opt  -reg "*" >>& dbcreate_log.txt

	echo '# Run gtm8699.m'
	$ydb_dist/mumps -run gtm8699


	$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
	if ($status) then
		echo "DB Check Failed, Output Below"
		cat dbcheck_log.txt
	endif

	echo ''
end

