#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2012, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test has an already complicated reference file (separate sections for SPANNING_REGIONS and NONSPANNING_REGIONS).
# And each section has different output from MUPIP REORG -TRUNCATE in case the > 4g db block scheme is enabled
# (due to the big HOLE). It is not considered worth maintaining an even more complicated reference file just for this
# scheme. Besides MUPIP REORG -TRUNCATE output for > 4g db blocks is already maintained in other simpler reference files
# (e.g. v62002/outref/gtm8187.txt, reorg/outref/truncate_crash.txt etc.) so disable this 4g block scheme in this test.
setenv ydb_test_4g_db_blks 0

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	setenv test_specific_gde $gtm_tst/$tst/inref/truncate_simple.gde
endif
setenv gtm_test_spanreg 0	# Since test_specific_gde is set in case of spanning regions
setenv test_reorg NON_REORG
setenv gtm_test_mupip_set_version "V5"
setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode due to differences in MUPIP REORG -TRUNCATE output

$gtm_tst/com/dbcreate.csh mumps 4 255 500 1024
set verbose
$gtm_exe/mumps -run %XCMD 'for i=1:1:10000 set v=$j(i,200) set ^a(i)=v,^b(i)=v,^c(i)=v,^d(i)=v'
$MUPIP reorg -truncate
$gtm_exe/mumps -run %XCMD 'kill ^a,^b,^c,^d'
$MUPIP reorg -truncate
unset verbose
$gtm_tst/com/dbcheck.csh
