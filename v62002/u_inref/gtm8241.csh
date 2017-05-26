#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# GTM-8241 [nars] Test that processes blocking on a lock do not attempt to get crit on the db (thereby not creating crit contention)

echo "Create database file mumps.dat"
$gtm_tst/com/dbcreate.csh mumps

# Prevent wcs_clean_dbsync from invoking grab_crit_immediate in the lock waiter processes and in turn affecting CAT stats
# This is easily done by making the flush time much higher so wcs_wtstart does not kick in while the lock wait is going on.
$DSE change -fileheader -flush_time=100000	>& dse_ch_flush_time.out

echo ""
echo "test1 : Verify that blocked processes mostly sleep (no crit activity) if holder process is alive"
$gtm_exe/mumps -run gtm8241 0

echo ""
echo "test2 : Verify that blocked processes dont sleep but instead acquire lock if holder process dies while holding the lock"
$gtm_exe/mumps -run gtm8241 1
$gtm_exe/mumps -run verify^gtm8241

# Clean up relinkctl files and/or shared memory segments, if any. Needed because this test does a "kill -9"
$MUPIP rundown -relinkctl >&! mupip_rundown_rctl.logx

echo ""
echo "Do a dbcheck to ensure db integs clean"
$gtm_tst/com/dbcheck.csh
