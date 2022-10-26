#!/usr/local/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#This test only runs on dbg because the white box tests don't work on pro

set syslog_begin = `date +"%b %e %H:%M:%S"`

$echoline
echo "# Creating database"
$gtm_tst/com/dbcreate.csh mumps

$echoline

echo "# Starting journaling"
$MUPIP set -journal="enable,file=jnl.mjl" -file mumps.dat

$echoline
echo "# Turn on WBTEST_JNLPROCSTUCK_FORCE"
setenv gtm_white_box_test_case_enable   1
setenv gtm_white_box_test_case_number   156      # WBTEST_JNLPROCSTUCK_FORCE

$echoline
echo '# Test YDB#941 too : Copy mumps.gld to copy.gld and do a SET $ZGBLDIR=copy.gld inside M.'
echo '#                    This way we can later check that the DSE program invoked by %YDBPROCSTUCKEXEC uses copy.gld'
echo '#                    (the current global directory in the process) and not mumps.gld (ydb_gbldir/gtmgbldir env var)'
cp $gtmgbldir copy.gld
echo "# Set a global variable 500 times"
$gtm_exe/yottadb -run %XCMD 'set $zgbldir="copy.gld" for i=1:1:500 set ^a=i'

# The next step ("Stop journaling") requires standalone access to the database.
# It is possible the %YDBPROCSTUCKEXEC invocation in line 37 above (due to the JNLPROCSTUCK error)
# created a background "dse" process that is still accessing the database file. If so, kill it before
# the next step as otherwise it would get a "File already open by another process" error.
# See https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1224#note_1141982726 for more details.
$gtm_tst/com/kill_ydbprocstuckexec_dse_processes.csh

$echoline
echo "# Stop journaling"
$MUPIP set -journal=disable -file mumps.dat

set syslog_after = `date +"%b %e %H:%M:%S"`

$echoline
echo "# Check the syslog for an %YDB-W-JNLPROCSTUCK error. If not found, this will time out."
$gtm_tst/com/getoper.csh "$syslog_begin" "$syslog_after" syslog_jnlprocstuck.txt "" "JNLPROCSTUCK"

echo "# Test of YDB#941 : Verify %YDBPROCSTUCKEXEC used copy.gld as its global directory file and not mumps.gld"
echo "#                   We expect below output say copy.gld (and not mumps.gld)"
grep "Database file headers for regions from global directory" %YDBPROCSTUCKEXEC*_dse.out

$echoline
$gtm_tst/com/dbcheck.csh
