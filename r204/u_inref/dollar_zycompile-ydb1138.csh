#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#######################################"
echo '#      Test of $ZYCOMPILE'
echo "#######################################"

$gtm_dist/mumps -run ydb1138

echo "# -------------------------------------------------------------------------------"
echo "# Test of https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1665#note_2435762415"
echo "# -------------------------------------------------------------------------------"
echo "# Compiling M line [label(a,) set c=1]. Expecting a NAMEEXPECTED error."
echo "# Prior to r2.04 (YDB@a4c332e7), no error was issued"
echo "label(a,) set c=1" > ydb1138a.m
$gtm_dist/mumps ydb1138a.m

