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
echo "# Test that compiling M program in UTF-8 mode issues an appropriate INVDLRCVAL error without a GTMASSERT2"
echo ""
echo "# Switch to UTF8 mode"
$switch_chset "UTF-8"
cp $gtm_tst/$tst/inref/ydb329.m .
echo "# Run : mumps ydb329.m"
$ydb_dist/mumps ydb329.m
