#################################################################
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
#
echo '# GTM-4272 - Verify MUPIP BACKUP displays information in standard GT.M messages format'
echo '#'
echo '# Release note:'
echo '#'
echo '# MUPIP BACKUP and RESTORE display information in standard GT.M messages format. The messages'
echo '# display the full path when they include a file context. Please refer to the Error and Other'
echo '# Messages section of these release notes for details on the standard messages. Previously, certain'
echo '# MUPIP BACKUP and RESTORE messages did not follow the standard GT.M message format and/or did'
echo '# not display the full path when there was a file context. (GTM-4272)'
echo '#'
echo '# Note that the existing tests in the test system tested several of errors mentioned in the errors'
echo '# section of the release notes. Those are not tested here. The remaining errors that are tested'
echo '# here are the following:'
echo '#'
echo '#   1. BKUPFILEPERM - Backup file permissions on existing file do not permit replacement'
echo '#   2. BKUPPROGRESS - Progress messages printed during backup - note debug-only'
echo '#   3. BKUPRETRY - Run a broken backup that attempts to retry after an error'
echo '#   4. CMDERR - Attempt to backup repl instance file to nonexistent file/directory'
echo '#'
echo
echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps
echo
echo '# Put a little something in the database so we have something to backup'
$gtm_dist/mumps -dir <<EOF
for i=1:1:100000 set ^a(\$justify(i,50))=\$justify(i,75)
EOF
#
# Test #1
#
echo
$echoline
echo
echo '# Test #1 - BKUPFILEPERM - backup file exists and permissions do not allow existing file replacement'
echo '#   Command used: $MUPIP backup -replace DEFAULT mumps_backup.dat'
echo
echo '#   Create the backup directory and change its permissions'
touch mumps_backup.dat
chmod -w mumps_backup.dat
echo
echo '#   Attempt to backup DB into created file using command above - expect BKUPFILEPERM error'
$MUPIP backup -replace DEFAULT mumps_backup.dat
# Remove empty file
chmod +w mumps_backup.dat
rm mumps_backup.dat
#
# Test # 2
#
if (1 == $ydb_test_copy_file_range_avail) then
    echo
    $echoline
    echo
    echo '# Test # 2 - BKUPPROGRESS - run a backup that prints progress messages (grep from output file)'
    echo '#   Command used: $MUPIP backup -showprogress DEFAULT mumps_backup.dat'
    # These progress messages aren't very interesting due to the smallness of the backup but it shows it is functional. Note since
    # the BKUPPROGRESS message is not deterministic (in terms of how many we get), we write the output to the file and select the
    # first message that occurs. We only need to see one to prove these messages exist.
    $MUPIP backup -showprogress DEFAULT mumps_backup.dat >& mupip_backup_showprogress.log
    $grep BKUPPROGRESS mupip_backup_showprogress.log | head -n1
    rm mumps_backup.dat
endif
#
# Test # 3 uses white box testing so only run this sub-test if this is a debug build
#
if ("dbg" == "$tst_image") then
    echo
    $echoline
    echo
    echo '# Test #3 - BKUPRETRY - Attempt backup with whitebox test WBTEST_BACKUP_FORCE_MV_RV enabled to cause an error and generate a retry'
    echo '#   Command used: $MUPIP backup -retry=2 DEFAULT mumps_backup.dat'
    setenv gtm_white_box_test_case_enable 1
    setenv gtm_white_box_test_case_number 175	# WBTEST_BACKUP_FORCE_MV_RV to generate an error
    $MUPIP backup -retry=2 DEFAULT mumps_backup.dat
    unsetenv gtm_white_box_test_case_enable
    unsetenv gtm_white_box_test_case_number
endif
#
# Test #4
#
# We restrict this test from running on RHEL 7.9 as the error message it prints about the bad file is surrounded by unicode single
# quotes in that version which we don't consider worth matching given this is old RHEL 7 in a reference file due to the quote's
# multi-byte representation so this subtest is bypassed under RHEL 7.9.
if (("rhel" != $gtm_test_linux_distrib) || ("7.9" != $gtm_test_linux_version)) then
    echo
    $echoline
    echo
    echo '# Test #4 - CMDERR - Backup the replinstance file to a file under a non-existent directory to generate CMDERR'
    echo '#   Command used: $MUPIP backup -replinstance=/tmp/nonexist42/efgh.repl'
    $MUPIP backup -replinstance=/tmp/nonexist42/efgh.repl
endif
#
echo
$echoline
echo
echo '# Validate DB'
$gtm_tst/com/dbcheck.csh
