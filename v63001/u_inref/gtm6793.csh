#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.      #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo "-----------------------------------------------------------------------------------------------------------------------------------"
echo "#(GTM-6793):MERGE into a local variable (lvn) target limits the number of target subscripts to the maximum number supported by GT.M"
echo "#(currently 31); previously, MERGE could produce variables with 32 subscripts which could cause subsequent problems."
echo "-----------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Test that a Merge of two local variables that would result in 32 subscripts gives a YDB-E-MAXNRSUBSRIPTS error."
echo ""
echo "# Create the DB"
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif

echo "# Set two local variables, one with 31 subscripts, one with a subscript, and merge for a total of 32 subscripts."
$ydb_dist/mumps -run test1^gtm6793
echo "# Set a local variable with 31 subscripts and a global variable with a subscript, and merge for a total of 32 subscripts."
$ydb_dist/mumps -run test2^gtm6793


$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
