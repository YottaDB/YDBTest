#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
## !!! NOTE !!! ##
# This test is an exact copy of rundown_argless/u_inref/mu_rundown_no_ipcrm1.csh
# The only difference being "set move = 0" vs "set move = 1" below. This makes it an argumentless rundown vs rundown -reg "*"
# argumentless rundown version stays in rundown_argless test, rundown -reg "*" version stays in mupip test.
# A change made to one test should immediately be duplicated to the other.
## !!! NOTE !!! ##
setenv gtm_test_crash 1

# Below is needed since this test does a "NO_IPCRM" and we do not want DBDANGER messages from freezing the instance
source $gtm_tst/com/adjust_custom_errors_for_no_ipcrm_test.csh

$gtm_tst/com/dbcreate.csh mumps 8 125 1000

echo "GTM Process starts in background..."
$gtm_tst/com/imptp.csh 5 >>&! imptp.out

$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_until_rcvr_trn_processed_above.csh +30"

# RECEIVER SIDE (B) CRASH
$gtm_tst/com/rfstatus.csh "BEFORE_SEC_B_CRASH:"
$sec_shell "$sec_getenv; $gtm_tst/com/receiver_crash.csh ""NO_IPCRM"""

# PRIMARY SIDE (A) CRASH
$gtm_tst/com/srcstat.csh "BEFORE_PRI_A_CRASH"
$gtm_tst/com/primary_crash.csh "NO_IPCRM"

# This test does kill -9 followed by a MUPIP RUNDOWN. A kill -9 could hit the running GT.M process while it
# is in the middle of executing wcs_wtstart. This could potentially leave some dirty buffers hanging in the shared
# memory. So, set the white box test case to avoid asserts in wcs_flu.c
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 29

# If encryption is turned on, rundown needs to know the secondary database's encryption key. So, add that to the existing configuration file.
if ("ENCRYPT" == $test_encryption) then
	foreach db (mumps a b c d e f g)
		$gtm_tst/com/modconfig.csh $gtmcrypt_config append-keypair $SEC_SIDE/$db.dat $SEC_SIDE/${db}_dat_key
		echo "dat $SEC_SIDE/$db.dat" >>&! $gtm_dbkeys
		echo "key $SEC_SIDE/${db}_dat_key" >>&! $gtm_dbkeys
	end
endif

set movefiles = 0	# argumentless rundown NOT done below
if (1 == $movefiles) then
	set dbmessage = "YDB-I-TEXT"
	mkdir ./save; mv *.dat mumps.repl ./save #BYPASSOK no need to use backup_dbjnl.csh
	$sec_shell "$sec_getenv; cd $SEC_SIDE; mkdir ./save; mv *.dat mumps.repl ./save" #BYPASSOK no need to use backup_dbjnl.csh
else
	set dbmessage = "MUFILRNDWNSUC"
endif

echo " $MUPIP rundown starts"
if (1 == $movefiles) then
	$MUPIP rundown -override							 >& mupip_rundown1.logx
else
	$MUPIP rundown -reg '*' -override						>>& mupip_rundown1.logx
	$sec_shell "$sec_getenv ; cd $SEC_SIDE; $MUPIP rundown -reg '*' -override "	>>& mupip_rundown1.logx
endif
# Pull out the messages related to our test run's .dat files
$grep $PRI_DIR mupip_rundown1.logx | $grep '.dat' | $tst_awk 'sub(/ [0-9]+/," xxx")' | sort -f
$grep $SEC_DIR mupip_rundown1.logx | $grep '.dat' | $tst_awk 'sub(/ [0-9]+/," xxx")' | sort -f
$grep -E "$PRI_DIR|$SEC_DIR" mupip_rundown1.logx | $grep '.dat' | $grep $dbmessage >&! checkcount.logx

set regioncnt = `wc -l checkcount.logx | $tst_awk '{print $1}'`
# 8 regions on the primary + 8 regions on the secondary = 16 regions
if (16 != $regioncnt) echo "Expected count: 16 Actual count: "$regioncnt

if (1 == $movefiles) then
	mv ./save/*  .
	$sec_shell "$sec_getenv; cd $SEC_SIDE; mv ./save/* ."

	$MUPIP rundown >& mupip_rundown2.logx

	# Pull out the messages related to our test run's .dat files
	$grep $PRI_DIR mupip_rundown2.logx | $grep '.dat' | $tst_awk 'sub(/ [0-9]+/," xxx")' | sort -f
	$grep $SEC_DIR mupip_rundown2.logx | $grep '.dat' | $tst_awk 'sub(/ [0-9]+/," xxx")' | sort -f
	$grep -E "$PRI_DIR|$SEC_DIR" mupip_rundown2.logx | $grep '.dat' | $grep MUFILRNDWNSUC >>&! checkcount.logx

	set regioncnt = `wc -l checkcount.logx | $tst_awk '{print $1}'`
	# 8 regions on the primary + 8 regions on the secondary = 16 regions
	if (16 != $regioncnt) echo "Expected count: 16 Actual count: "$regioncnt
endif

# Remove stray rctl shared memory segments.
$MUPIP rundown -relinkctl >&! mupip_rundown_rctl.logx
$sec_shell "$sec_getenv ; cd $SEC_SIDE; $MUPIP rundown -relinkctl >&! mupip_rundown_rctl.logx"

# we don't call dbcheck.csh since we are kill -9ing the processes, but manually release the reserved ports
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0
$sec_shell "$sec_getenv ; cd $SEC_SIDE; source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 ; source $gtm_tst/com/portno_release.csh"
