#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "#----------------------------------------------------------------------------------------------------#"
echo '# [YDB#1329] An error in $ETRAP or $ZTRAP code after a device EXCEPTION ran in that code           #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# An error in $ETRAP or $ZTRAP code, after that code invoked a device EXCEPTION, failed with GTMASSERT2'
echo '# in set_zstatus.c, as the error handling found that the code last invoked was neither $ETRAP nor $ZTRAP.'
echo

cp $gtm_tst/$tst/inref/ydb1329.m .

echo '# Stage 1 : $ETRAP code READs past the end of an empty file, which invokes the device EXCEPTION, then'
echo '#           divides by zero; then the same $ETRAP code without the READ'
echo '# Before the fix : GTMASSERT2 in set_zstatus.c after the device EXCEPTION ran'
echo '# With the fix   : expect ERRWETRAP and DIVZERO in $ZSTATUS both times'
echo '# Command : $gtm_dist/mumps -run exc^ydb1329'
$gtm_dist/mumps -run exc^ydb1329
echo

echo '# Stage 2 : the same as Stage 1 with $ZTRAP code in place of $ETRAP code'
echo '# Before the fix : GTMASSERT2 in set_zstatus.c after the device EXCEPTION ran'
echo '# With the fix   : expect ERRWZTRAP and DIVZERO in $ZSTATUS both times'
echo '# Command : $gtm_dist/mumps -run ztr^ydb1329'
$gtm_dist/mumps -run ztr^ydb1329
echo

echo "# Done"
