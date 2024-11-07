#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo '# Test for GTM-8838 - Test WFR, BUS and BTS statistics and their field name counterparts are accessible'
echo '# via $VIEW, MUPIP DUMPFHEAD, ^%PEEKBYNAME, and ^%YGBLSTAT (ZSHOW is already covered elsewhere in the'
echo '# test system).'
echo
echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps
echo
echo '# Make it a not empty database'
$gtm_dist/mumps -run ^%XCMD 'for i=1:1:10 set ^x(i)=$justify(i,100)'
echo
echo '# Verify $VIEW("GVSTAT","DEFAULT") displays the new stats (only print tail to avoid stat differences in reference file)'
$gtm_dist/mumps -run VerifyView^gtm8838
echo
echo '# Capture the output of MUPIP DUMPFHEAD -reg DEFAULT in the file mupip_dumpfhead_output.txt'
$MUPIP dumpfhead -reg DEFAULT >& mupip_dumpfhead_output.txt
echo
echo '# Verify the old names for these stats are no longer shown in MUPIP DUMPFHEAD outpu (should display nothing)'
egrep 'sgmnt_data.t_qread_ripsleep_cnt_cntr|sgmnt_data.db_csh_get_too_many_loops_cntr|sgmnt_data.bt_put_flush_dirty_cntr' mupip_dumpfhead_output.txt
echo
echo '# Verify the new names for these stats are available in MUPIP DUMPFHEAD output (expect the 3 statistic values)'
egrep 'gvstats_rec.n_wait_for_read|gvstats_rec.n_buffer_scarce|gvstats_rec.n_bt_scarce' mupip_dumpfhead_output.txt
echo
echo '# Verify the old names for these stats are no longer shown with ^%PEEKBYNAME() (expect errors for unknown fields)'
$gtm_dist/mumps -run ^%XCMD 'write "t_qread_ripsleep_cnt_cnt: ",$$^%PEEKBYNAME("sgmnt_data.t_qread_ripsleep_cnt_cntr","DEFAULT"),!'
$gtm_dist/mumps -run ^%XCMD 'write "t_qread_ripsleep_cnt_cnt: ",$$^%PEEKBYNAME("sgmnt_data.db_csh_get_too_man_loops_cntr","DEFAULT"),!'
$gtm_dist/mumps -run ^%XCMD 'write "t_qread_ripsleep_cnt_cnt: ",$$^%PEEKBYNAME("sgmnt_data.bt_put_flush_dirty_cntr","DEFAULT"),!'
echo
echo '# Verify the new names for these stats are available with ^%PEEKBYNAME() (expect the 3 statistic values)'
$gtm_dist/mumps -run ^%XCMD 'write "n_wait_for_read: ",$$^%PEEKBYNAME("sgmnt_data.gvstats_rec.n_wait_for_read","DEFAULT"),!'
$gtm_dist/mumps -run ^%XCMD 'write "n_buffer_scarce: ",$$^%PEEKBYNAME("sgmnt_data.gvstats_rec.n_buffer_scarce","DEFAULT"),!'
$gtm_dist/mumps -run ^%XCMD 'write "n_bt_scarce: ",$$^%PEEKBYNAME("sgmnt_data.gvstats_rec.n_bt_scarce","DEFAULT"),!'
echo
echo '# Verify the statistics show up in ^%YGBLSTAT (only print tail to avoid stat differences in reference file)'
$gtm_dist/mumps -run VerifyYGBLSTAT^gtm8838
#
# This part of the test uses WBTEST_YDB_SETSTATSOFF white box test so is restricted to DEBUG builds only
if ("dbg" == "$tst_image") then
    echo
    echo '# Turn global stat sharing off of on this DB to make changing the stats easier (prevents other processes from'
    echo '# changing our stats once we set them). Test will fail without NOSTATS being set.'
    $MUPIP set -nostats -reg DEFAULT
    #
    # Set the flush time really high so no possibility of a timed flush (even on really slow PI systems) that would
    # cause the n_db_flush stat to increase causing the test to fail.
    $MUPIP set -flush_time=600 -reg DEFAULT
    echo
    echo '# Set each of the gvstats statistics to a given value then verify that value via both ^%PEEKBYNAME and MUPIP DUMPFHEAD'
    setenv gtm_white_box_test_case_enable   1
    setenv gtm_white_box_test_case_number   404	# WBTEST_YDB_SETSTATSOFF
    $gtm_dist/mumps -run VerifyGVSTATS^gtm8838
endif
echo
echo '# Verify database we (lightly) used'
$gtm_tst/com/dbcheck.csh
