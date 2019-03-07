#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

echo "# Enable sharing with gtm_statshare"
setenv gtm_statshare "TRUE"
echo "# Set gtm_statsdir to the root directory, which we dont have permissions to"
setenv gtm_statsdir "/"

echo "# Create a single region DB with gbl_dir mumps.gld and region DEFAULT"
$gtm_tst/com/dbcreate.csh mumps >>& create.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat create.out
endif

echo "# The DB, while set for sharing, should now be unable to share due to the invalid gtm_statsdir selection"

echo ''
echo '# Run gtm8914.m'
$ydb_dist/mumps -run gtm8914


$gtm_tst/com/dbcheck.csh mumps >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
endif
