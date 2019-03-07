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
#
echo "# Test that the pattern match operator with alternation does not SIG-11 with input string as small as 16K"
echo "# This is an issue that was tracked https://gitlab.com/YottaDB/DB/YDB/issues/26"
echo "# But we noticed this was fixed when GT.M V6.3-005 was released as part of GTM-8965"
echo "# The new/correct behavior is a PATALTER2LARGE error (expected in the below output)"
$ydb_dist/mumps -run ^%XCMD 'for i=1:1:20 s x=$j(1,2**i) w "$zlength(x)=",$zlength(x)," : x?.(1""1"",1"" "") = ",x?.(1"1",1" "),!'
