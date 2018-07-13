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
#
#
setenv gtm_test_autorelink_always 1
set zroutines1 = `$ydb_dist/mumps -run ^%XCMD 'write $zroutines'`
echo '# Changing $zroutines to an invalid string'
$ydb_dist/mumps -run gtm8718
echo ""
set zroutines2 = `$ydb_dist/mumps -run ^%XCMD 'write $zroutines'`
if ("$zroutines1" == "$zroutines2") then
	echo '# $ZROUTINES MAINTAINED ITS ORIGINAL VALUE'
else
	echo '# $ZROUTINES CHANGED'
	echo $zroutines1
	echo $zroutines2
endif
