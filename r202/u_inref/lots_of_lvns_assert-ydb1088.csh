#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "###########################################################################################################"
echo '# Test that lots of lvns usage does not assert fail in lv_getslot.c'
echo "###########################################################################################################"

echo "# Test 1 : https://gitlab.com/YottaDB/DB/YDB/-/issues/1088#description"
echo "# Run [mumps -run test1^ydb1088]. Expect no output below. More importantly, do not expect any assert failure"
$gtm_dist/mumps -run test1^ydb1088
echo

echo "# Test 2 : https://gitlab.com/YottaDB/DB/YDB/-/issues/1088#note_2044101764"
echo "# Run [mumps -run test2^ydb1088]. Expect no output below. More importantly, do not expect any assert failure"
$gtm_dist/mumps -run test2^ydb1088
echo

