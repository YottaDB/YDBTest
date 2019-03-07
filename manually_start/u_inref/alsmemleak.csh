#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################
#
# Testing for aliasing memory leaks by testing heavy rev long running flavor
# of the aliaslv tptests.m test.
#

# Turn off gtmdbglvl due to run time constraints
# A non-zero gtmdbglvl turns on the debug memory manager even for pro builds and that
# causes every malloc/free to record caller_id() which does many system calls (sigprocmask() etc.)
# all of which slow down this test to a few hours which causes TEST-E-HANG alerts.
unsetenv gtmdbglvl

# Data base is not really used but needs to be present for TP restart testing
$gtm_tst/com/dbcreate.csh .

# Fetch current version of test from aliaslv suite
cp $gtm_tst/aliaslv/inref/tptests.m .
$gtm_dist/mumps -run autolvgc^tptests

$gtm_tst/com/dbcheck.csh
