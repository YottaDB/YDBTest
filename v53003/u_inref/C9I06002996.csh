#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Disable randomtn as otherwise it could set curr_tn to a value that is too high for V4 db format
setenv gtm_test_disable_randomdbtn

# Disable mupip-set-version to V4 as that will disturb Fully Upgraded flag and in turn affect the static reference file
setenv gtm_test_mupip_set_version "disable"

$gtm_tst/com/is_icu_new_naming_scheme.csh
if (0 == $status) $switch_chset M >&! disable_utf8.txt

$gtm_tst/com/dbcreate.csh mumps

set linestr = "----------------------------------------------------------------------"
set newline = ""

echo $linestr
echo "# Test that endiancvt is not affected by csd->wc_blocked"
echo "# Test that csd->wc_blocked gets reset to 0 in endian-converted db"
echo "Currently it is not easily possible to set wc_blocked to a non-zero value in a standalone database. So this is not tested"
echo ""

echo $linestr
echo "# Turn ON freeze"
$MUPIP freeze -on DEFAULT
if (3 != `$DSE dump -file |& $grep -i "freeze" | $grep -v 0x00000000 | wc -l`) then
	# We expect to see TWO lines with non-zero values "Cache freeze id" and "Freeze match",
	# plus the "Anticipatory Freeze" line.
	# If that is not the case, then dump the actual values.
	$DSE dump -file |& $grep -i "freeze"
endif
echo "# Test that endiancvt is not affected by csd->freeze"
echo "yes" | $MUPIP endiancvt mumps.dat >& endiancvt1a.log
echo "# Test that csd->freeze gets reset to 0 in endian-converted db"
echo "yes" | $MUPIP endiancvt mumps.dat >& endiancvt1b.log
$DSE dump -file |& $grep -i "freeze"
echo "# Turn OFF freeze before proceeding to next test"
$MUPIP freeze -off DEFAULT
echo ""

echo $linestr
echo "# Set kill_in_prog to non-zero value"
$DSE change -file -kill=10 >& dse2a.log
$DSE dump -file |& $grep "KILLs in progress"
echo "# Test that endiancvt does not proceed if kill_in_prog is non-zero"
$MUPIP endiancvt mumps.dat
echo "# Test that endiancvt proceeds even if kill_in_prog is non-zero as long as OVERRIDE is specified"
echo "yes" | $MUPIP endiancvt -override mumps.dat >& endiancvt2a.log
echo "# Test that endiancvt preserves the kill_in_prog value as part of the conversion"
echo "yes" | $MUPIP endiancvt -override mumps.dat >& endiancvt2b.log
$DSE dump -file |& $grep "KILLs in progress"
echo "# Set kill_in_prog back to 0 before proceeding to next test"
$DSE change -file -kill=0 >& dse2b.log
$DSE dump -file |& $grep "KILLs in progress"
echo ""

echo $linestr
echo "# Test that endiancvt does not proceed if rc_srv_cnt is non-zero"
$DSE change -file -rc_srv_count=10 >& dse3a.log
echo "# Currently there is no way of verifying that rc_srv_cnt is indeed non-zero in file header so no DSE DUMP command here"
$MUPIP endiancvt mumps.dat
echo "# Test that endiancvt proceeds even if rc_srv_cnt is non-zero as long as OVERRIDE is specified"
echo "yes" | $MUPIP endiancvt -override mumps.dat >& endiancvt3a.log
echo "# Test that endiancvt preserves the rc_srv_cnt value as part of the conversion"
echo "yes" | $MUPIP endiancvt -override mumps.dat >& endiancvt3b.log
echo "# Currently there is no way of verifying that rc_srv_cnt is indeed non-zero in file header so no DSE DUMP command here"
echo "# Set rc_srv_cnt back to 0 before proceeding to next test"
$DSE change -file -rc_srv_count=0 >& dse3b.log
echo "# Currently there is no way of verifying that rc_srv_cnt is indeed zero in file header so no DSE DUMP command here"
echo ""
$gtm_tst/com/dbcheck.csh

echo $linestr
# Following section of the test uses prior GTM version for testing. Skip this testing if the platform doesnt have
# any prior versions
if ($?gtm_test_nopriorgtmver) then
	exit
endif

echo "# Test that endiancvt does not proceed if minor-dbver is not same as current version"
echo "# We know that any version <= V63000 has a minor db-ver different from the current or any future version"
echo "# So create database using that older version and try to endiancvt it using the current version"
echo "# Randomly choose a prior V5 version that is <= V63000 to create the database first."
set prior_ver = `$gtm_tst/com/random_ver.csh -gte V50000 -lte V63000`
if ("$prior_ver" =~ "*-E-*") then
	echo "No prior versions available: $prior_ver"
	exit -1
endif
echo "$prior_ver" > priorver_nofilter.txt
echo "Randomly chosen prior V5 version is : GTM_TEST_DEBUGINFO [$prior_ver]"
echo ""
echo "# Switch to prior version"
source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image
echo "Creating database using prior V5 version"
\rm *.o	>& rm1.out # remove .o files created by current version (in case the format is different)
$gtm_tst/com/dbcreate.csh mumps
echo "# Switch to current version"
\rm *.o	>& rm2.out # remove .o files created by prior version (in case the format is different)
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
# For some 64-bit platforms, the gld format could be different between prior_ver and curver
# So recreate gld file unconditionally.
mv mumps.gld priorver.gld
$GDE exit
echo "# Test that endiancvt does not proceed if minor_dbver is different"
$gtm_tools/offset.csh sgmnt_data t_end.c |  $grep minor_dbver >& offset_from_header.logx
@ offset_minor_ver = `$tst_awk '{print $3}' offset_from_header.logx`
@ size_minor_ver = `$tst_awk '{print $7}' offset_from_header.logx`
set prev_minor_ver = `od -A d -t d -N $size_minor_ver -j $offset_minor_ver mumps.dat | $tst_awk '{print $2}'`
$MUPIP endiancvt mumps.dat
echo "# Test that endiancvt proceeds even if minor_dbver is different as long as OVERRIDE is specified"
echo "yes" | $MUPIP endiancvt -override mumps.dat >& endiancvt4a.log
echo "# Test that endiancvt preserves the minor_dbver value as part of the conversion"
echo "yes" | $MUPIP endiancvt -override mumps.dat >& endiancvt4b.log
echo ""
echo "Find the offset of minor_dbver in file header"
set now_minor_ver = `od -A d -t d -N $size_minor_ver -j $offset_minor_ver mumps.dat | $tst_awk '{print $2}'`
if ($prev_minor_ver != $now_minor_ver) then
	echo "The value is: $now_minor_ver. Prev version: $prev_minor_ver"
	echo "Minor db version is changed"
else
	echo "Minor db version is the same"
endif
echo $linestr
echo "# Set desired_db_format to V4"
$MUPIP set -ver="V4" -reg "*"
$DSE dump -file |& $grep -i "Desired DB Format"
echo "# Test that endiancvt does not proceed if desired_db_format is V4"
$MUPIP endiancvt mumps.dat
echo "# Test that endiancvt does not proceed even if desired_db_format is V4 and OVERRIDE is specified"
$MUPIP endiancvt -override mumps.dat
$DSE dump -file |& $grep -i "Desired DB Format"
echo "# Set desired_db_format back to V6 before proceeding to next test"
$MUPIP set -ver="V6" -reg "*"
echo ""

echo $linestr
echo "# Set fully_upgraded to FALSE"
$MUPIP reorg -downgrade -reg "*"
$MUPIP set -ver="V6" -reg "*"
$DSE dump -file -all |& $grep "Fully Upgraded"
echo "# Test that endiancvt does not proceed if fully_upgraded is FALSE"
$MUPIP endiancvt mumps.dat
echo "# Test that endiancvt does not proceed even if fully_upgraded is FALSE and OVERRIDE is specified"
$MUPIP endiancvt -override mumps.dat
$DSE dump -file -all |& $grep "Fully Upgraded"
echo "# Set fully_upgraded back to TRUE before proceeding to next test"
$MUPIP reorg -upgrade -reg "*"
$DSE dump -file -all |& $grep "Fully Upgraded"
echo ""
$gtm_tst/com/dbcheck.csh
