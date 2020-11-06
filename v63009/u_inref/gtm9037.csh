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

echo "# This tests that a %YDB-E-JNLEXTEND error is printed to the syslog when"
echo "# there is a journaling error due to a disk issue or permissions issue"
echo "# that would cause journaling to be shut down or an instance freeze."

setenv ydb_error_on_jnl_file_lost 1

set syslog_begin = `date +"%b %e %H:%M:%S"`

$echoline
echo "# Creating jnl subdirectory"
mkdir jnl

$echoline
echo "# Creating database"
$gtm_tst/com/dbcreate.csh mumps

$echoline
echo "# Starting journaling"
$MUPIP set -journal="enable,nobefore,allocation=2048,autoswitchlimit=16384,file=jnl/mumps.mjl" -file mumps.dat

$echoline
echo "# Set a global variable 500 thousand times"
$gtm_exe/yottadb -run %XCMD 'for i=1:1:500000 set ^a=i'

# Remove write permissions on "jnl" subdirectory
# This will trigger a JNLCLOSED error whenever the current autoswitchlimit is exceeded on the current generation ajnl/a.mjl
$echoline
echo "# Removing write permissions on jnl subdirectory"
chmod u-w jnl

$echoline
echo "# Set the global variable another 5 million times"
$gtm_exe/yottadb -run %XCMD 'for i=1:1:5000000 set ^a=i'

$echoline
echo "# Stop journaling"
$MUPIP set -journal=disable -file mumps.dat

set syslog_after = `date +"%b %e %H:%M:%S"`

$echoline
echo "# Re-Enable write permissions on jnl subdirectory to avoid gzip errors"
chmod u+w jnl

$echoline
echo "# Check the syslog for an %YDB-E-JNLEXTEND error. If not found, this will time out after 5 minutes (300 seconds)."

$gtm_tst/com/getoper.csh "$syslog_begin" "$syslog_after" syslog_jnlextend.txt "" "JNLEXTEND"

$gtm_tst/com/dbcheck.csh
