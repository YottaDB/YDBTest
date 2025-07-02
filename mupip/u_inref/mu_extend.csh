#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Since the reference file for this test has "SUSPEND_OUTPUT 4G_ABOVE_DB_BLKS" usage, it needs to fixate
# the value of the "ydb_test_4g_db_blks" env var in case it is randomly set by the test framework to a non-zero value.
if (0 != $ydb_test_4g_db_blks) then
	echo "# Setting ydb_test_4g_db_blks env var to a fixed value as reference file has 4G_ABOVE_DB_BLKS usages" >> settings.csh
	setenv ydb_test_4g_db_blks 8388608
endif

#
########################################
# mu_extend.csh  test for mupip extend #
########################################
#
#
echo MUPIP EXTEND
#
#
@ corecnt = 1
setenv gtmgbldir "extend.gld"
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	$gtm_tst/com/dbcreate.csh "extend" 1 125 700 1536 1300 256
else
	$gtm_tst/com/dbcreate.csh "extend" 1 125 700 1536 100 256
endif
#
#
$GTM << aaaa
view "gdscert":1
w "do in0^dbfill(""set"")",!  do in0^dbfill("set")
w "h",!  h
aaaa
source $gtm_tst/$tst/u_inref/check_core_file.csh "ex" "$corecnt"
#
#
echo "#"
echo "# Extend with a bad region"
echo "#"
$MUPIP EXTEND FREELUNCH -BLOCKS=400
#
$MUPIP EXTEND DEFAULT -BLOCKS=400
if ( $status > 0 ) then
	echo ERROR from extend 400.
	exit 1
endif
#
#
$GTM << bbbb
view "gdscert":1
w "do in0^dbfill(""ver"")",!  do in0^dbfill("ver")
w "do in1^dbfill(""set"")",!  do in1^dbfill("set")
w "h",!  h
bbbb
source $gtm_tst/$tst/u_inref/check_core_file.csh "ex" "$corecnt"
#
#
# Region Name in Mixed cases should be accepted
$MUPIP EXTEND Default
if ( $status > 0 ) then
	echo ERROR from extend default.
	exit 2
endif
#
#
$GTM << cccc
view "gdscert":1
w "do in1^dbfill(""ver"")",!  do in1^dbfill("ver")
s ^a="SUCCESS"
w ^a
w "h",!  h
cccc
source $gtm_tst/$tst/u_inref/check_core_file.csh "ex" "$corecnt"
#
#
$gtm_tst/com/dbcheck.csh
#
#
########################
# END of mu_extend.csh #
########################

