#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Compile M program with very long line and create listing file.
#  Verify that listing file output is readable and unambiguous.
\cp $gtm_tst/$tst/inref/per1831.m .
setenv MUMPS "$gtm_exe/mumps"
$MUMPS -list=per1831.lis per1831.m
#
# Remove page headers (which include date/time stamps) from listing:
set per1831cwd = `pwd`
$grep -E -v "page|$per1831cwd|`date +%Y`" per1831.lis
