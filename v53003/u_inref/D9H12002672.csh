#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National Information		#
# Services, Inc. and/or its subsidiaries.			#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# S9H12-002672 MUPIP BACKUP should release ALL CRIT before sleep-waiting for kill-in-progress
#
echo "ENTERING D9H12002672"
# Don't allow V6 mode databases to be selected as it causes reference file differences in MUPIP INTEG output.
setenv gtm_test_use_V6_DBs 0
#
# Create database with 3 regions
$gtm_tst/com/dbcreate.csh . 3

#multi-region commands works on ftok order. Do a mupip backup to get database and region name variables defined in ftok order
source $gtm_tst/$tst/u_inref/db_reg_var.csh

setenv bkp_dir "`pwd`/bak1"
mkdir $bkp_dir
chmod 777 $bkp_dir
#Set KIP = 1
echo "# Set kill_in_prog=1 for second region : GTM_TEST_DEBUGINFO $reg2"
$DSE << DSE_EOF >&! dse_change_kip.out
find -reg="$reg2"
change -file -kill_in_prog=1
exit
DSE_EOF

echo "# Start backup process in background"
# backup output goes to file backup.outx and background backup pid is in file backup.pid
$gtm_tst/$tst/u_inref/do_backup.csh "ALL" $bkp_dir >& do_backup.log

# Wait until we know backup process is running in background and is in its KIP wait logic.
# Backup has been started by do_backup.csh with the -dbg qualifier which will print a wait message so check for this.
# Note that kill in progress has been set in $reg2 so wait for message from backup for that particular database $db2.
$gtm_tst/com/wait_for_log.csh -log backup.outx -waitcreation -duration 120 -message "Start kill-in-prog wait for database `pwd`/$db2"

set bkuppid = `cat backup.pid`
if ($bkuppid == 0) then
	echo "TEST-E-BKUPPIDZERO : backup.pid contains 0 as the pid of the background backup. Needs investigation."
endif

echo "# Ensure that while backup process is waiting we dont hold any crits"
$DSE << DSE_EOF >&! dse_crit_all.out
crit -all
exit
DSE_EOF
echo ""
$grep "CRIT is currently unowned on all regions" dse_crit_all.out

# Following section, tests the inhibit_kills logic.
echo "# The backup process is running in background and waiting for KIP to reset."
echo "# We test future kills are inhibited on all the regions. We also test that set should work normally on all regions."
set var="^default"
if ( "AREG" == "$reg1" ) then
	set var="^abcdef"
else if ( "BREG" == "$reg1" ) then
	set var="^bcdefg"
endif
# regioninfo.log is for debug purpose.
echo "Writing variable $var into region $reg1" > regioninfo.log
$GTM << GTMEND
set var="$var"
set reg="$reg1"
set success=\$\$checktime^checktime(30,30,var,reg)
w success
GTMEND

# before leaving the test wait for background backup to complete
if (0 != $bkuppid) then
	$gtm_tst/com/wait_for_proc_to_die.csh $bkuppid 120
endif

# Unset KIP before calling dbcheck.csh
echo "# Unset kill_in_prog=1 for second region : GTM_TEST_DEBUGINFO $reg2"
$DSE << DSE_EOF >&! dse_change_kip2.out
find -reg="$reg2"
change -file -kill_in_prog=0
exit
DSE_EOF

echo "# LEAVING D9H12002672"
$gtm_tst/com/dbcheck.csh
