#!/usr/local/bin/tcsh -f
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
echo '# This test is to test functionality of -VERBOSE flag in MUPIP BACKUP, MUPIP FREEZE and MUPIP INTEG'
echo ''
echo '# Create database file'
$gtm_tst/com/dbcreate.csh mumps
echo ''

foreach opt (dbg verbose)
	echo "# Create backup path for -$opt"
	mkdir bak_$opt/
	echo ''
	echo '# Set kill_in_prog=1 in DEFAULT region'
	echo "# This is for making MUPIP INFO appear when we use -DBG or -VERBOSE as an option"
	$DSE << DSE_EOF >>&! dse_kip.out
	change -file -kill_in_prog=1
	exit
DSE_EOF
	echo ''
	echo "# Test MUPIP BACKUP with -$opt flag"
	($MUPIP backup -$opt -online "*" bak_$opt >& mupip_backup_$opt.out &)
	$gtm_tst/com/wait_for_log.csh -log mupip_backup_$opt.out -waitcreation -duration 60 -message "Start kill-in-prog wait for database"
	echo ''
	echo "# Test MUPIP FREEZE with -$opt flag"
	($MUPIP freeze -$opt -on "*" >& mupip_freeze_$opt.out &)
	$gtm_tst/com/wait_for_log.csh -log mupip_freeze_$opt.out -waitcreation -duration 60 -message "Start kill-in-prog wait for database"
	echo ''
	echo "# Test MUPIP INTEG with -$opt flag"
	($MUPIP integ -$opt -region "*" >& mupip_integ_$opt.out &)
	$gtm_tst/com/wait_for_log.csh -log mupip_integ_$opt.out -waitcreation -duration 60 -message "Start kill-in-prog wait for database"
	echo ''
	echo '# set kill_in_prog=0'
	$DSE << DSE_EOF >>&! dse_kip.out
	change -file -kill_in_prog=0
	exit
DSE_EOF
	echo ''
	$gtm_tst/com/wait_for_log.csh -log mupip_backup_$opt.out -waitcreation -duration 60 -message "BACKUPSUCCESS"
	$gtm_tst/com/wait_for_log.csh -log mupip_freeze_$opt.out -waitcreation -duration 60 -message "All requested regions frozen"
	$gtm_tst/com/wait_for_log.csh -log mupip_integ_$opt.out -waitcreation -duration 60 -message "No errors detected by integ"
	echo ''
	echo "# Result from MUPIP BACKUP with -$opt flag"
	$grep -Ev 'FILERENAME|JNLCREATE' mupip_backup_$opt.out | $grep -vE '^$|cp --sparse=always'
	echo ''
	echo "# Result from MUPIP FREEZE with -$opt flag"
	$grep -Ev 'FILERENAME|JNLCREATE' mupip_freeze_$opt.out
	echo ''
	echo "# Result from MUPIP INTEG with -$opt flag"
	$grep -Ev 'FILERENAME|JNLCREATE' mupip_integ_$opt.out
	echo ''
	echo "# Unfreeze database file to do dbcheck.csh"
	$MUPIP freeze -off DEFAULT >& unfreeze.out
	echo ''
	echo "# Check for database integrity"
	$gtm_tst/com/dbcheck.csh
	echo ''
end
