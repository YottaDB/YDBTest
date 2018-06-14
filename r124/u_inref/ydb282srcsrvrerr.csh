#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test that FILEDELFAIL and RENAMEFAIL error codepaths are handled appropriately by source server.
#
set errlist = (FILEDELFAIL RENAMEFAIL)
set errwbox = (201 202)

foreach errcode (1 2)
	set wbox = $errwbox[$errcode]
	set err = $errlist[$errcode]
	echo " ####################################################################"
	echo "     Testing $err error codepath in source server"
	echo " ####################################################################"
	# The below setup is very similar to that in v62000/gtm8086 subtest
	unsetenv gtm_test_fake_enospc
	setenv gtm_test_freeze_on_error 1
	setenv gtm_custom_errors $gtm_tools/custom_errors_sample.txt
	setenv gtm_test_jnlfileonly 1
	unsetenv gtm_test_jnlpool_sync
	$MULTISITE_REPLIC_PREPARE 2

	echo "# Create database in source and receiver side"
	echo "# Set access method to BG since with MM -jnl_prefix= does not work in dbcreate.csh"
	echo "# Set autoswitch to the lowest setting to maximize switching"
	set jnldir="jnldir"
	mkdir -p $jnldir
	if ($?test_replic) then
		$MSR RUN INST2 mkdir -p $jnldir
	endif
	source $gtm_tst/com/gtm_test_setbgaccess.csh
	$gtm_tst/com/dbcreate.csh mumps 1 -jnl_auto=16384 -jnl_prefix=${jnldir}/ >& ${err}_dbcreate.out
	if ($status) then
		echo "# dbcreate failed. cat ${err}_dbcreate.out follows"
		cat ${err}_dbcreate.out
		exit -1
	endif

	set syslog_start = `date +"%b %e %H:%M:%S"`

	echo "# Start only source server (not receiver server) so no connection happens"
	echo "# This will ensure journal files are not opened now by source server but later after directory permissions have been changed"
	$MSR STARTSRC INST1 INST2 RP

	echo "# Permissions of [jnldir] before change"
	$gtm_tst/com/lsminusl.csh -d jnldir | $tst_awk '{print($1,$NF);}'

	echo "# Run lots of updates with white-box case enabled (202) to ensure a $err codepath is later exercised in source server"
	echo "# This will also turn write permissions OFF in [jnldir] directory and result in JNLEXTEND/JNLNOCREATE errors"
	setenv ydb_white_box_test_case_enable 1
	setenv ydb_white_box_test_case_number $wbox
	$ydb_dist/mumps -run ^%XCMD 'for i=1:1:200000 set ^x=i'

	echo "# Permissions of [jnldir] after change"
	$gtm_tst/com/lsminusl.csh -d jnldir | $tst_awk '{print($1,$NF);}'

	echo "# Start receiver server so source server connects and opens journal file and exercise $err codepath"
	$MSR STARTRCV INST1 INST2

	echo "# Ensure source and receiver are in sync"
	$MSR SYNC INST1 INST2

	echo "# Turn write permissions back ON in [jnldir] directory"
	chmod a+w $jnldir

	echo "# Turn off instance freeze"
	$MUPIP replic -source -freeze=off

	echo "# Ensure source server did go through $err codepath (by checking syslog)"
	$gtm_tst/com/getoper.csh "$syslog_start" "" test_syslog1.txt
	$grep "SRCSRVR.*$err" test_syslog1.txt

	echo "# Run dbcheck"
	$gtm_tst/com/dbcheck.csh >& ${err}_dbcheck.out
	if ($status) then
		echo "# dbcheck failed. cat ${err}_dbcheck.out follows"
		cat ${err}_dbcheck.out
		exit -1
	endif
	$gtm_tst/com/backup_dbjnl.csh $err "*.gld *.dat *.repl *.mjl*" mv
end
