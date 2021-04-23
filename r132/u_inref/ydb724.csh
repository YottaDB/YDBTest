#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '### Test some $ZATRANSFORM edge cases ###'
echo
$echoline
echo "# Create shared library for alternate collation # 1 (reverse collation)"
source $gtm_tst/com/cre_coll_sl_reverse.csh 1
$echoline
echo "# Drive ydb724 edge case test"
echo
$ydb_dist/yottadb -run ydb724

