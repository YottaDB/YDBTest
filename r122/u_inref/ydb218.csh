#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo "------------------------------------------------------------------------------------------------------------------------"
echo '# Test that ydb_app_ensures_isolation env var can be set to a length > 1k of global variables "^a1,^a2,...,^a999,^a1000"'

# create database
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif


echo "------------------------------------------------------------------------------------------------------------------------"
echo "# Test that ydb_app_ensures_isolation can be set using setenv"
echo "# Generate global variable list noisolist"
set noisolist = "^a1"
foreach ind (`seq 2 1 1000`)
	set noisolist = "$noisolist,^a$ind"
end
echo $noisolist >& debug.txt

echo '# Set noisolist using: setenv ydb_app_ensures_isolation "$noisolist"'
setenv ydb_app_ensures_isolation "$noisolist"

echo '# Use $VIEW "NOISOLATION" to ensure each global variable has no isolation set.'
$gtm_exe/mumps -run test1^ydb218 $noisolist


# Unset the environment for the next method
unset ydb_app_ensures_isolation

echo "------------------------------------------------------------------------------------------------------------------------"

echo '# Test that ydb_app_ensures_isolation can be set using "VIEW NOISOLATION"'
echo '# Generate global variable list noisolist using mumps'
echo '# Set noisolist using: VIEW "NOISOLATION": noisolist'
echo '# Use $VIEW "NOISOLATION" to ensure each global variable has no isolation set.'
$gtm_exe/mumps -run test2^ydb218 $noisolist


# check database
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
        echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
