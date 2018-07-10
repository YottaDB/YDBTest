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
# Tests that $zroutines defaults to the current directory when gtmroutines is not defined
#

# Copying M file to current directory so system can still find it even after we unset gtmroutines
cp $gtm_tst/$tst/inref/gtm8736.m ./gtm8736.m
unsetenv gtmroutines
if (! $?gtmroutines) then
	echo "# gtmroutines is not defined"
endif
$ydb_dist/mumps -run gtm8736
