#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-9409 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-001_Release_Notes.html#GTM-9408)

The HANG command avoids a race condition where a non-zero duration could occasionally hang
indefinitely. The change makes things, including \$HOLOROG and \$ZUT, that rely on the system clock more
sensitive to changes which adjust that resource. The workaround for this was to wake the affected
process with a SIGALRM, and change any HANG that exhibited the symptom to use a timed READ of some
non-responding device in place of the HANG. (GTM-9408)

-----------------------------------------------"
Test scenario is running a HANG 3 and concurrently resetting the system date back in time by 100 seconds
and sending the hanging process a signal (mupip intrpt sends SIGUSR1).

This used to cause the process to incorrectly conclude that it needed to hang for 103 more seconds when
the original hang gets interrupted by the SIGUSR1 signal.

With the GTM-9408 fixes, we expect the HANG 3 to hang only for 3 seconds even if the system time is reset
back by 100 seconds.

Since resetting the system date requires root access, this subtest is included in the "sudo" test.
-----------------------------------------------"

CAT_EOF

echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps

echo '# Run [mumps -run gtm9408]'
$gtm_dist/mumps -run gtm9408

echo '# Validate DB'
$gtm_tst/com/dbcheck.csh

