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

echo '# Test $VIEW("JOBPID") returns 0 if no VIEW "JOBPID" was done'
$ydb_dist/yottadb -run %XCMD 'write $view("JOBPID"),!'

echo '# Test $VIEW("JOBPID") returns 0 if VIEW "JOBPID":0 was done'
$ydb_dist/yottadb -run %XCMD 'view "JOBPID":0 write $view("JOBPID"),!'

echo '# Test $VIEW("JOBPID") returns 1 if VIEW "JOBPID":1 was done'
$ydb_dist/yottadb -run %XCMD 'view "JOBPID":1 write $view("JOBPID"),!'

echo '# Test $VIEW("JOBPID") returns 1 if VIEW "JOBPID":-1 was done'
$ydb_dist/yottadb -run %XCMD 'view "JOBPID":-1 write $view("JOBPID"),!'

echo '# Test $VIEW("JOBPID") returns 1 if VIEW "JOBPID":-2 was done'
$ydb_dist/yottadb -run %XCMD 'view "JOBPID":-2 write $view("JOBPID"),!'

echo '# Test $VIEW("jObPiD") returns 1 if VIEW "JOBPID":1 was done'
$ydb_dist/yottadb -run %XCMD 'view "JOBPID":1 write $view("jObPiD"),!'

echo '# Test $VIEW("jobpid") tracks VIEW "jobpid" setting. Expecting to see 0 and 1 output below in that order.'
$ydb_dist/yottadb -run %XCMD 'for i=0:1:1 view "JOBPID":i write $view("jobpid"),!'

