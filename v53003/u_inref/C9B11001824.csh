#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2008-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# We want to have NOBEFORE or BEFORE image journaling always. Cannot have no-journaling as a choice.
setenv gtm_test_jnl NON_SETJNL

# Disable randomtn as we want to later reset the database to a fixed currtn of 1 for forward recovery.
setenv gtm_test_disable_randomdbtn

# Disable mupip-set-version as that will disturb currtn as well
setenv gtm_test_mupip_set_version "disable"

# Define white-box test environment variables to avoid later assert failures in forward recovery.
source $gtm_tst/com/wbox_test_prepare.csh "TP_HIST_CDB_SC_BLKMOD" 1 1 settings.csh

$gtm_tst/com/dbcreate.csh mumps
$MUPIP set -region "*" $tst_jnl_str >& jnl_on.out

echo "# Do GT.M updates on journaled database"
$GTM << GTM_EOF
	do ^c001824
GTM_EOF

echo "# Introduce DBTNTOOLG integrity error so following journal recover will fail with TPFAIL error"
$DSE << DSE_EOF
	change -file -curr=1
DSE_EOF

echo "# Do journal forward recovery (expect it to fail with TPFAIL error)"
$MUPIP journal -recover -forward -noverify "*"
echo "exit_status = $status"

# dbcheck intentionally not done since database will be corrupt (due to forward recovery failing above).
