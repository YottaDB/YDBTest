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
setenv SHELL /usr/local/bin/tcsh
$ydb_dist/mumps -run shellfn^gtm8644

# Redirect ps output to .outx file to avoid test failures due to the presence of "-E-" strings in the ps -ef listing.
# For example a concurrently running test that is running the following command will cause a test failure in this test
#	because of the presence of -E- if we stored the ps -ef output in processtree.out (instead of .outx).
# Command : check_error_exist.csh ydb_zdate_form/ydb_zdate_form_MUPIP_RUNDOWN.log SYSTEM-E-ENO11
#
$ydb_dist/mumps -run psforestfn^gtm8644 >& processtree.outx
cat processtree.outx |& $grep -A 2 "gtm8644.csh" |& sed 's/ | //g' |& $tst_awk '{print $8,$9,$10,$11,$12,$13}'
$ydb_dist/mumps -run quotesfn^gtm8644
