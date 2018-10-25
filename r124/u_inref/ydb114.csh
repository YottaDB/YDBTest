#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.      #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo "-------------------------------------------------------------------------------------------------------------"
echo "# Test that a new version does not change whatever STDNULLCOLL settings are set in a global db set in a previous version."
echo "-------------------------------------------------------------------------------------------------------------"
echo "# Choose a random version prior to the current version. If version is older than V63003 it will not be able to check STDNULLCOLL"
set rand_ver=`$gtm_tst/com/random_ver.csh -lt $tst_ver`
source $gtm_tst/com/ydb_prior_ver_check.csh $rand_ver
echo "rand_ver: $rand_ver" > debug.txt

setenv gtm_test_spanreg 0 # Test requires traditional global mappings, so disable spanning regions

# If this test chose r120 as the prior version, GDE won't work with that version unless ydb_msgprefix is set to "GTM".
# (https://github.com/YottaDB/YottaDB/issues/193). Therefore, set ydb_msgprefix to "GTM" in that case.
if ($rand_ver == "V63003A_R120") then
	setenv ydb_msgprefix "GTM"
endif

echo "# Set the test version to the previous version"
source $gtm_tst/com/switch_gtm_version.csh $rand_ver $tst_image


echo "# Create DBs DEFAULT, AREG, and BREG in previous version"
$gtm_tst/com/dbcreate.csh mumps 3 >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif

echo ""

echo "# If version permits, randomly set STDNULLCOLL in each region."
# Versions prior to V63003 cannot do this
if (`expr $rand_ver "<" "V63003"`) then
	echo "Because of Version STDNULLCOLL is not changed" >> debug.txt
else
	foreach reg (DEFAULT areg breg)
		set rand_num=`$ydb_dist/mumps -run ^%XCMD 'write $random(2)'`
		if ( $rand_num == 1 ) then
			$ydb_dist/mupip set -stdnullcoll -reg "$reg" >>& debug.txt
		else
			$ydb_dist/mupip set -nostdnullcoll -reg "$reg" >>& debug.txt
		endif
	end
	# Peek at the values set for std_null_coll in each region
	$ydb_dist/mumps -run peek^ydb114 > peek.txt
endif

echo "# Perform some operations in mumps, and extract the global variables"
$ydb_dist/mumps -run oper^ydb114
$ydb_dist/mupip extract -nolog extr_out >>& debug.txt ; cat extr_out | tail -3 > extr_cut


echo ""
echo "# Switch the test version back to the current version."
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo "# Test that .gld file from older version can be upgraded by newer version GDE without issues."
$ydb_dist/mumps -run GDE exit >>& dbexit_log.txt
if ($status) then
	echo "DB Exit Failed, Output Below"
	cat dbexit_log.txt
endif

echo ""
echo "# If version permits, check if STDNULLCOLL values are maintained."
$ydb_dist/mumps -run peek^ydb114 > peek_new.txt
$ydb_dist/mupip extract -nolog extr_out_new >>& debug.txt ; cat extr_out_new | tail -3 > extr_cut_new

if (`expr $rand_ver "<" "V63003"`) then
	echo "-----> Version is too old" >> debug.txt
else if ( { diff peek.txt peek_new.txt } ) then
	echo "-----> STDNULLCOLL values match" >> debug.txt
else
	echo "-----> STDNULLCOLL values do not match"
endif

echo "# Check if Global Variables are maintained."
if ( { diff extr_cut extr_cut_new } ) then
	echo "-----> Global Variables match"
else
	echo "-----> Global Variables do not match"
endif

echo ""

echo "# Check and shutdown the DB"
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
