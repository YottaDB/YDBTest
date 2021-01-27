#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# This is a test for running ^%YDBAIM"

$echoline
echo "# Create database w/ null subs, key of 1019, and rec of 1048576"
echo "# Database can be MM or BG access_method"
echo "# References: "
echo "# https://gitlab.com/YottaDB/DB/YDB/-/issues/674"
echo "# https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/911#note_489079559"
echo "# https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/911#note_489170240"

$echoline
$gtm_tst/com/dbcreate.csh ydbaim 1 -stdnull -null_subscripts=TRUE -key_size=1019 -record_size=1048576
setenv ydb_gbldir ydbaim.gld

$echoline
echo "# Running test code..."
$ydb_dist/mumps -run ydb674
$gtm_tst/com/dbcheck.csh
