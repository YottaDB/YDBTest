#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo
echo '# GTM8681 - Release note:'
echo '#'
echo '# MUPIP BACKUP -RECORD provides a timestamp marking the start of backup when a backup'
echo '# a backup completes with no errors. The timestamp provides a backup date which is'
echo '# meaningful to operators without regard to when a particular transaction might have'
echo '# occurred. MUPIP DUMPFHEAD characterizes the timestamp as "sgmnt_data.last_start_backup",'
echo '# while DSE DUMP -FILEHEADER, labels it as "Last Record Backup Start". If a database has'
echo '# never been backed up with MUPIP BACKUP -RECORD, the utilities display "Never" for the'
echo '# field. Previously the -RECORD option stored only a starting transaction number. (GTM-8681)'
echo '#'
echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps 1
echo
echo '# Show that DSE DUMP -FILEHEADER -ALL shows the last backup time as "Never" if no backup'
echo '# has been done (selecting output record with "Last Record Backup Start" in it):'
$DSE d -f -all |& grep 'Last Record Backup Start'
echo
echo '# Show that MUPIP DUMPFHEAD dumps "sgmnt_data.last_start_backup" as Never'
$MUPIP DUMPFHEAD -reg DEFAULT |& grep "sgmnt_data.last_start_backup"
echo
echo '# Drive gtm8681',!
$gtm_dist/mumps -run gtm8681
@ savestatus = $status
if (0 != $savestatus) then
    echo "  Return failure from gtm8681.m: $savestatus"
    zhalt 1
endif
echo
echo '# Show that DSE DUMP -FILEHEADER -ALL shows the last backup time is NOT "Never" since backup'
echo '# has been done (selecting output record with "Last Record Backup Start" in it):'
$DSE d -f -all |& grep 'Last Record Backup Start'
#
# Part 2 uses a white box test so it can only run with a DEBUG build.
#
if ("dbg" == "$tst_image") then
    echo
    $echoline
    echo '#'
    echo '# Part 2 of test - starting over with new DB after saving old DB'
    mkdir origdb
    mv mumps.dat origdb/
    cp mumps.gld origdb/
    $gtm_dist/mupip create # Recreate DB - empty - no backup ever taken
    echo
    echo '# Run a backup with white box test WBTEST_BACKUP_FORCE_MV_RV which creates an error in the'
    echo '# backup when trying to finally move backup file from temp file to backup target. We expect'
    echo '# this command to fail.'
    setenv gtm_white_box_test_case_enable 1
    setenv gtm_white_box_test_case_number 175	# WBTEST_BACKUP_FORCE_MV_RV to generate an error
    $gtm_dist/mupip backup DEFAULT mumps_backup.dat
    unsetenv gtm_white_box_test_case_enable
    unsetenv gtm_white_box_test_case_number
    echo
    echo '# Now that the backup failed, verify that MUPIP DUMPFHEAD value for "sgmnt_data.last_start_backup",'
    echo '# is still "Never".'
    $MUPIP DUMPFHEAD -reg DEFAULT |& grep "sgmnt_data.last_start_backup"
endif
echo
echo '# Validate DB'
$gtm_tst/com/dbcheck.csh
