#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
# This module is derived from FIS GT.M.
#################################################################
#
# Generate boolean expressions, test with gtm_boolean=0 and 1
#
$gtm_tst/com/dbcreate.csh .

#
# Make sure $gtmdbglvl is off for compiles (takes WAY too long - over 5hrs on snail) but can be on for runs
#
if ($?gtmdbglvl) then
	set gtmdbglvlsave = "$gtmdbglvl"
endif

# Before test starts, unsetenv env vars that would otherwise influence/subvert the intention of this test
source $gtm_tst/com/unset_ydb_env_var.csh ydb_boolean gtm_boolean
source $gtm_tst/com/unset_ydb_env_var.csh ydb_side_effects gtm_side_effects

# Generator always runs no-bool
$gtm_dist/mumps -run boolgen
if ($status == 1) then
    echo "Run of boolgen.m failed"
    exit 1
endif

# With YDB#484 changes in r1.30, boolean expression evaluation was reworked significantly enough even when $ZYSQLNULL was not in use
# that it was felt necessary to validate that the new boolean expression evaluation returns the same results as the old
# method in r1.28 (which is the latest production version as of this time). Therefore, this test (which generates random boolean
# expressions) has been enhanced to not only check that the results of the boolean expression are the same when ydb_boolean is
# 0 or 1, but also cross check that the same output shows up when run with r1.28 ($gtm_curpro) and when run with r1.30 ($gtm_exe).
# Hence the for loop below if $gtm_curpro (latest production version) env var is defined.
if ($?gtm_curpro) then
	# If gtm_curpro env var is defined, then do 2 iterations in for loop
	set cur_ver=$gtm_exe:h:t
	set cur_build=$gtm_exe:t
	set verlist = "0 1"	# 0 corresponds to $gtm_exe, 1 corresponds to $gtm_curpro
else
	# If gtm_curpro env var is not defined, then do only 1 iteration in for loop
	set verlist = "0"	# 0 corresponds to $gtm_exe
endif
foreach iter ($verlist)
	if ($iter == 1) then
		# Running btest in $gtm_curpro
		# version change to $gtm_curpro
		source $gtm_tst/com/switch_gtm_version.csh $gtm_curpro pro
		set temp=".${gtm_dist:h:t}"
	else
		set temp=""
	endif
	# First run is normal shortcutting - no boolean
	if ($iter == 0) echo "Compiling btest.m with gtm_boolean=0"
	setenv gtm_boolean 1
	if ($?gtmdbglvlsave) unsetenv gtmdbglvl
	$gtm_dist/mumps btest.m
	if ($status != 0) then
	    echo "Compile of normal boolean btest.m failed"
	    exit 1
	endif
	if ($iter == 0) echo "Running btest.m with gtm_boolean=0"
	if ($?gtmdbglvlsave) then
		setenv gtmdbglvl "$gtmdbglvlsave"
	endif
	$gtm_dist/mumps -run btest > "btest_output_bool0.txt${temp}"
	if ($status != 0) then
	    echo "Run of normal boolean btest.m failed"
	    exit 1
	endif
	mv btest.o btest-nonbool.o${temp}	# Allows comparison of bool-0 object file with bool-1
	# Compile with boolean now
	if ($iter == 0) echo "Compiling btest.m with gtm_boolean=1"
	setenv gtm_boolean 1
	if ($?gtmdbglvlsave) unsetenv gtmdbglvl
	$gtm_dist/mumps btest.m
	if ($status != 0) then
	    echo "Compile of full boolean btest.m failed"
	    exit 1
	endif
	if ($iter == 0) echo "Running btest.m with gtm_boolean=1"
	if ($?gtmdbglvlsave) then
		setenv gtmdbglvl "$gtmdbglvlsave"
	endif
	$gtm_dist/mumps -run btest > "btest_output_bool1.txt${temp}"
	if ($status != 0) then
	    echo "Run of full boolean btest.m failed"
	    exit 1
	endif
	mv btest.o btest-bool.o${temp}		# Allows comparison of bool-0 object file with bool-1
	unsetenv gtm_boolean
end
if ($?gtm_curpro) then
	# Switch back to current test version (from current production version)
	source $gtm_tst/com/switch_gtm_version.csh $cur_ver $cur_build
endif
# Compare output files in detail to isolate broken expressions if any
$gtm_dist/mumps -run boolcomp
if ($?gtm_curpro) then
	# Compare boolean expression evaluation output of current test version against current production version output
	foreach bool (0 1)
		diff btest_output_bool${bool}.txt.${gtm_curpro} btest_output_bool${bool}.txt > gtm7277bool${bool}_diff.txt
		if ($status) then
			echo -n "# FAIL : Boolean expression evaluation output different between $gtm_curpro and $gtm_exe"
			echo " when gtm_boolean is set to $bool. Pasting gtm7277bool${bool}_diff.txt below."
			cat gtm7277bool${bool}_diff.txt
		endif
	endif
endif
# Quick double check of database coherency.
$gtm_tst/com/dbcheck.csh
