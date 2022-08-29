#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Test for GTM-9252 - Verify clean rundown from two processes with same R/O DB open'
echo
echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps
echo
echo '# Drive gtm9252 test routine'
set syslog_begin = `date +"%b %e %H:%M:%S"`
$gtm_dist/mumps -run gtm9252
echo
echo '# Extract syslog file for gtm9252 run looking for SYSCALL error (if we find one, test fails)'
sleep 2                 # Give it a couple secs so there's an actual time range
logger "Send 'SYSCALL' to the syslog so the following getoper.csh invocation doesn't need to timeout to end its search"
$gtm_tst/com/getoper.csh "$syslog_begin" "" syslog_gtm9252.txt "" "SYSCALL"
set pid1 = `cat pid1.txt`
set pid2 = `cat pid2.txt`
grep -E "($pid1|$pid2).*SYSCALL.*IPC_RMID" syslog_gtm9252.txt
echo
echo "# Verify database we (very lightly) used"
$gtm_tst/com/dbcheck.csh
