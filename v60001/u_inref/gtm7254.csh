#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2012, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps

# HP-UX scheduler is seen to be not as fair as the other so we have lower expectation
# MREP <unfair_lock_gtm7254>
if ($HOSTOS == "HP-UX") then
    set thr = 50
else if ($HOSTOS == "SunOS") then
    set thr = 75
else
    # We used to have the threshold at 95%. But as part of [YottaDB/Lang/YDBGo#18] changes, op_lock2.c
    # was reworked to not use timers which meant the process releasing the lock will send a SIGALRM to the
    # first waiting process but it is more likely some other waiting process gets the lock first since each
    # waiting process does not respond to the SIGALRM/timer interrupt. Even with that, we have seen almost
    # all systems pass tests with 95% but very rarely one host gets a threshold of 89% so we set the threshold
    # to 85% to avoid rare false test failures.
    set thr = 85
endif

$MUPIP set -file mumps.dat -flush_time=5:0:0 # Prevent interruptions from flush timers

$gtm_exe/mumps -run %XCMD "do gtm7254^gtm7254($thr)"

# Check if .mjo files have 100 'o's (i.e. all attempted locks were eventually successfully obtained)
foreach file (*procout.mjo*)
	if (`$grep -E -q 'o{100}' $file`) then
		echo "$file does not have proper /o{100}/ output"
		set fail
	endif
end
if !($?fail) echo "TEST-I-PASS All mjo files have proper output"

$gtm_tst/com/dbcheck.csh
