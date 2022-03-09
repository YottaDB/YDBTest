#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Create a database"
$gtm_tst/com/dbcreate.csh mumps
$echoline

echo "# Populate the database with globals"
$ydb_dist/mumps - run fillDB^gtm9244
$echoline

echo "# Call %JSWRITE on a glvn"
$ydb_dist/mumps -run jswrite^gtm9244
$echoline

echo "# Call STDIN^%JSWRITE using a ZWRITE as input"
$ydb_dist/mumps -run %XCMD 'ZWRITE ^x' | $ydb_dist/mumps -run STDIN^%JSWRITE > jswrite_zwrite.out
$ydb_dist/mumps -run %XCMD 'do checkfile^gtm9244("jswrite_zwrite.out","^x","zwr","")'
$echoline

echo "# Call incorrect ^%JSWRITE commands expecting errors"
echo '# Running ^%JSWRITE("^x","*#") expecting error'
$ydb_dist/mumps -run %XCMD 'do ^%JSWRITE("^x","*#")'
echo '# Running ^%JSWRITE("^x","#*") expecting error'
$ydb_dist/mumps -run %XCMD 'do ^%JSWRITE("^x","#*")'
echo '# Running ^%JSWRITE("^doesnotexit","*") expecting no output'
$ydb_dist/mumps -run %XCMD 'do ^%JSWRITE("^doesnotexist","#")'
$echoline

echo "# Run dbcheck"
$gtm_tst/com/dbcheck.csh
