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
echo "-----------------------------------------------------------------------------------------------------------------------"
echo '# Test that environmental variables can be set and unset using the VIEW "SETENV" and VIEW "UNSETENV" commands in mumps.'
echo "-----------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Initialize the environment variable ydb369_var"
setenv ydb369_var initialized
echo $ydb369_var
echo ""
echo '# Case 1: VIEW "SETENV":"ydb369_var":case1, where case1="case1", should be successful'
$ydb_dist/mumps -run ydb369 case1


echo ""
echo '# Case 2:  VIEW "SETENV":"ydb369_var":case2, where case2="case=2", should be successful'
$ydb_dist/mumps -run ydb369 case2


echo ""
echo '# Case 3:  VIEW "SETENV":"ydb369_var":"abc""def", should be succesful'
$ydb_dist/mumps -run ydb369 case3


echo ""
echo '# Case 4:  VIEW "SETENV", should issue a VIEWARGCNT error'
$ydb_dist/mumps -run ydb369 case4


echo ""
echo '# Case 5:  VIEW "SETENV":"", should result in no-op since env var name is null'
$ydb_dist/mumps -run ydb369 case5


echo ""
echo '# Case 6:  VIEW "SETENV":"":"", should result in no-op since env var name is null'
$ydb_dist/mumps -run ydb369 case6


echo ""
echo '# Case 7:  VIEW "SETENV":"ydb369_var":"", should set ydb369_var to ""'
$ydb_dist/mumps -run ydb369 case7


echo ""
echo '# Case 8:  VIEW "SETENV":"ydb369_var":"case8", should set ydb369_var to case8'
$ydb_dist/mumps -run ydb369 case8


echo ""
echo '# Case 9:  VIEW "SETENV":"ydb369_var":"case9":"extra", should set ydb369_var to case9 and ignore extra'
$ydb_dist/mumps -run ydb369 case9


echo ""
echo '# Case 10:  VIEW "SETENV":"x=y":"case10":"extra", should issues a SETENVFAIL error'
$ydb_dist/mumps -run ydb369 case10


echo ""
echo '# Case 11:  VIEW "SETENV":a:b, should succesfully set the value set in b to the env var set in a'
$ydb_dist/mumps -run ydb369 case11


echo ""
echo '# Case 12:  VIEW "SETENV":"ydb369_var":"case12", then VIEW "UNSETENV":"ydb369_var", should successfully unset ydb369_var'
$ydb_dist/mumps -run ydb369 case12
