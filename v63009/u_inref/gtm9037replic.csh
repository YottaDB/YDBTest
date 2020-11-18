#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$MULTISITE_REPLIC_PREPARE 2

echo "# This tests that a %YDB-E-JNLEXTEND error is printed to the syslog when"
echo "# there is a journaling error due to a disk issue or permissions issue"
echo "# that would cause journaling to be shut down or an instance freeze."

# The below was copied from sr_unix/custom_errors_sample.txt in the YDB repository.
cat >> custom_errors.txt << xx
DBBMLCORRUPT
DBDANGER
DBFSYNCERR
DBIOERR
DSKNOSPCAVAIL
GBLOFLOW
GVDATAFAIL
GVDATAGETFAIL	; This is currently reported as TPFAIL and invisible to the user.
GVGETFAIL
GVINCRFAIL
GVKILLFAIL
GVORDERFAIL
GVPUTFAIL
GVQUERYFAIL
GVQUERYGETFAIL
GVZTRIGFAIL	; This is currently reported as TPFAIL and invisible to the user.
JNLACCESS
JNLCLOSE
JNLCLOSED
JNLCNTRL
JNLEXTEND
JNLFILECLOSERR
JNLFILEXTERR
JNLFILOPN
JNLFLUSH
JNLFSYNCERR
JNLOPNERR
JNLRDERR
JNLREAD
JNLVSIZE
JNLWRERR
JRTNULLFAIL
OUTOFSPACE
TRIGDEFBAD
xx

setenv ydb_custom_errors $tst_working_dir/custom_errors.txt

set syslog_begin = `date +"%b %e %H:%M:%S"`

$echoline
echo "# Creating jnl subdirectories"
mkdir jnl1
mkdir jnl2

$echoline
echo "# Creating database"
$gtm_tst/com/dbcreate.csh mumps

$echoline
echo "# Starting Replication and enable instance freeze on INST2"
$MSR START INST1 INST2
$MSR RUN INST2 '$MUPIP set -inst_freeze_on_error -file mumps.dat'

$echoline
echo "# Starting journaling"
$MSR RUN INST1 '$MUPIP set -journal="enable,nobefore,allocation=2048,autoswitchlimit=16384,file=jnl1/mumps.mjl" -file mumps.dat'
$MSR RUN INST2 '$MUPIP set -journal="enable,nobefore,allocation=2048,autoswitchlimit=16384,file=$tst_working_dir/jnl2/mumps.mjl" -file mumps.dat'

$echoline
echo "# Set a global variable 500 thousand times"
$gtm_exe/yottadb -run %XCMD 'for i=1:1:500000 set ^a=i'

# Remove write permissions on "jnl2" subdirectory
# This will trigger a JNLCLOSED error whenever the current autoswitchlimit is exceeded on the current generation jnl2/mumps.mjl
$echoline
echo "# Removing write permissions on jnl2 subdirectory"
chmod u-w $tst_working_dir/jnl2

$echoline
echo "# Set the global variable another million times"
$gtm_exe/yottadb -run %XCMD 'for i=1:1:1000000 set ^a=i'

$echoline
echo "# Re-Enable write permissions on jnl2 subdirectory and bring the receiver back into sync"
chmod u+w $tst_working_dir/jnl2
$MSR RUN INST2 '$MUPIP replic -source -freeze=off'
$MSR RUN INST2 '$MUPIP replic -receiv -start -updateonly'

$echoline
echo "# Stop Replication and shut down both instances"
$MSR STOP INST1 INST2

set syslog_after = `date +"%b %e %H:%M:%S"`

$echoline
echo "# Check the syslog for an %YDB-E-JNLEXTEND error. If not found, this will time out after 5 minutes (300 seconds)."

$gtm_tst/com/getoper.csh "$syslog_begin" "$syslog_after" syslog_jnlextend.txt "" "JNLEXTEND"

$gtm_tst/com/dbcheck.csh
