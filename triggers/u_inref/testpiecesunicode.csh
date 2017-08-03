#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
$gtm_tst/com/dbcreate.csh mumps 1
# Testing the piece and delimiter matching during trigger execution with
# unicode and non-unicode characters
# - delim matches on unicode character boundaries
# - zdelim matches on byte boundaries
#
# * delim w/$zchar both unicode and bytes
# * delim w/$char unicode char
# * zdelim w/$zchar both unicode and bytes
# * zdelim w/$char unicode char
#
# * test pieces while doing some of the delim tests
$gtm_exe/mumps -run testpiecesunicode
source $gtm_tst/com/ydb_trig_upgrade_check.csh
$gtm_tst/com/dbcheck.csh -extract
