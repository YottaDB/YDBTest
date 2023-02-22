#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '## Test for GTM-9277 - test crafted boolean expressions that have side-effect implications in their last'
echo '##  term. These boolean expressions are fed to intrinsic function calls where the value received by the C'
echo '## routine is an integer instead of the underlying mval.'
#
# Note - though we are really only testing this issue when gtm_side_effects is 1, we allow the test system to randomize
# the value for gtm_side_effects to also test the 0 setting and do not hard-code it here.
#
echo
echo '## Setup collation used in the test (via com/cre_coll_sl.csh)'
source $gtm_tst/com/cre_coll_sl.csh com/col_polish.c 1
echo
echo '## Create database with collation enabled as it is used in several expressions. Also add a few records.'
$gtm_tst/com/dbcreate.csh mumps -col=1
$GTM << GTM_EOF
for i=1:1:10 set ^a(i)=i
GTM_EOF
echo
echo '## Drive gtm9277 test routine'
$ydb_dist/yottadb -run gtm9277
echo
echo "## Verify database we (very lightly) used"
$gtm_tst/com/dbcheck.csh
