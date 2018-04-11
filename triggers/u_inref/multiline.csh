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
# This module is derived from FIS GT.M.
#################################################################

$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run multiline
$grep -v '^;' multiline_all.trg > multiline_all.trgx
$grep -v '^;' multiline_post.trg > multiline_post.trgx
diff multiline_all.trgx multiline_post.trgx

# smoketest.m is not UTF-8 friendly, switch to "M" chset
$echoline
echo "smoketest"
set save_chset=`printenv gtm_chset`
if ($?save_chset) then
	$switch_chset "M" >&! switch_chset
endif
$gtm_exe/mumps -run smoketest^multiline >&! smoketest.out
$grep '%YDB-E' smoketest.out
if ($?save_chset) then
	$switch_chset $save_chset >&! restore_chset
endif

$echoline
echo "ensure line numbers are correct"
echo "triggers are on lines"
$grep -n '^+' valid.trg
echo "make sure those lines match the trigger output file"
cat valid.trg.trigout
$echoline
$gtm_tst/com/dbcheck.csh -extract
