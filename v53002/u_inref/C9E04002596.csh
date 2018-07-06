#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright 2008, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# C9E04-002596 Test multiple gld mapping regions to the same physical file
#

if ($?test_replic) then
	echo "# Create 9 instances INST1 through INST9"
	$MULTISITE_REPLIC_PREPARE 9
endif

$gtm_tst/com/dbcreate.csh mumps 8 -rec=8000 -gld_has_db_fullpath >& dbcreate.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate.out
	exit -1
endif

if (! $?test_replic) then
	# to test multiple global directories, copy the gld file
	foreach num (0 1 2 3 4 5 6 7)
		cp mumps.gld mumpssec$num.gld
	end
else
	echo "# Start source servers on INST1 through INST8 (use INST9 as dummy secondary for all of them)"
	foreach num (1 2 3 4 5 6 7 8)
		$MSR STARTSRC INST$num INST9 RP
		$MSR RUN INST$num "pwd" >& curdir.out
		@ secnum = $num - 1
		ln -s `grep -v "Executing" curdir.out`/mumps.gld mumpssec$secnum.gld
	end
	echo "# Start and stop source server on INST9 just so we create instance file (needed by later dbcheck.csh)"
	$MSR STARTSRC INST9 INST1 RP
	$MSR STOPSRC INST9 INST1
	echo "# Do random updates (TP and non-TP) in the same process across multiple instances INST1 to INST8 (tests GTM-8182)"
endif

# Randomly set ydb_app_ensures_isolation env var to list of globals that need VIEW "NOISOLATION" set.
# If not set, tpntpupd.m (invoked later from c002596.m below) will do the needed VIEW "NOISOLATION" call.
source $gtm_tst/com/tpntpupd_set_noisolation.csh

$GTM <<GTM_EOF
	do ^c002596
GTM_EOF

$gtm_tst/com/dbcheck.csh
