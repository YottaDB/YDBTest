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
$ydb_dist/mumps -run psforestfn^gtm8644 >& processtree.out
cat processtree.out |& $grep -A 2 "gtm8644.csh" |& sed 's/\<|\>//g' |& $tst_awk '{print $8,$9,$10,$11,$12,$13}'
$ydb_dist/mumps -run quotesfn^gtm8644
