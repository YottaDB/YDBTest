#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
# Test UTF8 scan cacheing. First a couple of simplistic standalone tests for basic functionality.
# Note the first part of this test uses the default values for $gtm_utfcgr_strings and $gtm_utfcgr_string_groups.
#
echo "***** Starting utfcache_extract test"
$gtm_dist/mumps -run utfcacheExtract
echo
echo "***** Starting utfcache_find test"
$gtm_dist/mumps -run utfcacheFind
#
# Time to try something a little more challenging. We have two flavors of a JSON parser - one uses M mode routines
# parse the JSON string ($ZEXTRACT(), $ZFIND(), etc) and the other uses the "normal" versions of these functions.
# The input is all in ASCII format but we run both in UTF8 mode to make sure they generate the same output. The output
# files created by these functions are named jsonout[asc,utf].txt. They are compared after the second run for equality.
#
ln -s $gtm_tst/$tst/inref/DTXJSON.txt ./DTXJSON.txt   # Create link so routines can find this input file
#
# Drive the json parser in ASCII mode - note this is only a difference in the routine driven which,
# for example, uses $ZEXTRACT() instead of $EXTRACT(). The run mode is still UTF8.
#
echo
echo "***** Starting JSON parsing test"
echo "  .. running ASCII flavor"
$gtm_dist/mumps -run runjson "asc"
#
# And once again for the UTF8 flavor which uses $EXTRACT() instead of $ZEXTRACT()
#
echo "  .. running UTF flavor"
$gtm_dist/mumps -run runjson "utf"
#
# Compare the two created files
#
diff jsonoutasc.txt jsonoututf.txt >& jsonout.diff
set savestat = $status
if (0 != $savestat) then
    echo "Output files jsonoutasc.txt and jsonoututf.txt are **NOT** the same and should be - see jsonout.diff"
else
    echo "Output files jsonoutasc.txt and jsonoututf.txt are the same - PASS"
endif
#
# This last test is a randomized thrashing of UTF8 cache to see what might shake out. The generator program
# (utfcacheGenrand.m) creates random strings and a specified number of tests to create based on those strings.
# It creates the cases and the expected results generating a new routine to run to verify those results. The
# generator program runs in $gtm_curpro (the currently defined production version) while the generated
# routine runs with the test version image. In this manner we test the generated cases with both a production
# version (which generated both the cases and the expected values) and the test version.
#
# Note for this test, bump $gtm_utfcgr_string_groups to 4096 (up from default of 32) to handle very large
# UTF8 string (nearly 700K bytes and 170K characters) better.
#
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_utfcgr_string_groups gtm_utfcgr_string_groups 4096
#
# Switch to $gtm_curpro
#
echo
echo "***** Starting random string/testcase generator"
source $gtm_tst/com/switch_gtm_version.csh $gtm_curpro $tst_image
$gtm_dist/mumps -run utfcacheGenrand 5000   # generate 5000 test cases (15000 subtest cases)
#
# Now switch back to our version and drive the generated routine and see if it generates the same values.
#
echo "Driving generated routine to compare values"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
$gtm_dist/mumps -run utfcacheGenerated
#
