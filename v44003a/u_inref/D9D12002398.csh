#!/usr/local/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
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
# D9D12-002398 BEGSEQGTENDSEQ error as part of crash recovery testing at KTB
#

setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
$gtm_tst/com/dbcreate.csh mumps 5

# Wait for the Source Server to have written/read all information to/from the instance file before we reset the
# resync sequence numbers with the below commands (which can be wrong if replication is not up and fully initialized first).
# What happens is the following:
# - Before setting the resync sequence number in the replication instance file as part of the test, need to wait for the
#   source server to update the same (which it does as part of the connection handshake with the receiver server).
# - Not waiting makes it possible for the handshake (that happens in the background) to occur AFTER this script sets it.
# - In that case, the handshake resync sequence number will overwrite the resync sequence number set by the test and cause
#   a test failure as later stages of this test rely on the resync sequence number set by the test.
set start_time = `cat start_time`
$gtm_tst/com/wait_for_log.csh -message "New History Content" -log SRC_$start_time.log -duration 120

$gtm_tst/com/set_resync_and_reg_seqno.csh AREG    "64"       "set_seqno.out"	>>&! set_resync_and_reg_seqno.out
$gtm_tst/com/set_resync_and_reg_seqno.csh BREG    "FFFFFFF0" "set_seqno.out"	>>&! set_resync_and_reg_seqno.out # 4G - 16
$gtm_tst/com/set_resync_and_reg_seqno.csh CREG    "10000012C" "set_seqno.out"	>>&! set_resync_and_reg_seqno.out # 4G + 300
$gtm_tst/com/set_resync_and_reg_seqno.csh DEFAULT "40000000" "set_seqno.out"	>>&! set_resync_and_reg_seqno.out # 1G
$gtm_tst/com/set_resync_and_reg_seqno.csh DREG    "1194"      "set_seqno.out"	>>&! set_resync_and_reg_seqno.out

echo "-------------------------------------------------------------------"
echo "       1) Reg/Resync Seqno before MUPIP SET (no *)                 "
echo "-------------------------------------------------------------------"
$gtm_tst/com/get_dse_df.csh	# creates dse_df.log
$grep -E "Region          |Seqno" dse_df.log
mv dse_df.log dse_df_1.log
$MUPIP replic -editinstance -show -detail $gtm_repl_instance >& editinst_1.log
$grep "Resync Sequence" editinst_1.log
echo ""

$MUPIP set $tst_jnl_str -region BREG
$MUPIP set $tst_jnl_str -region CREG
$MUPIP set $tst_jnl_str -replication="on" -region DEFAULT
$MUPIP set $tst_jnl_str -region DREG

echo "-------------------------------------------------------------------"
echo "       2) Reg/Resync Seqno before MUPIP SET -REG *                 "
echo "-------------------------------------------------------------------"
$gtm_tst/com/get_dse_df.csh	# creates dse_df.log
$grep -E "Region          |Seqno" dse_df.log
mv dse_df.log dse_df_2.log
$MUPIP replic -editinstance -show -detail $gtm_repl_instance >& editinst_2.log
$grep "Resync Sequence" editinst_2.log
echo ""
$gtm_tst/com/get_mupjnl_show.csh "*.mjl" "header" jnl_show_2.log
$grep -E "Journal file name|Sequence" jnl_show_2.log
echo ""

if ("BG" == $acc_meth) then
	$MUPIP set -journal="on,before" -region "*" |& sort -f
else
	$MUPIP set -journal="on,nobefore" -region "*" |& sort -f
endif

echo "-------------------------------------------------------------------"
echo "       3) Reg/Resync Seqno after MUPIP SET -REG *                  "
echo "-------------------------------------------------------------------"
$gtm_tst/com/get_dse_df.csh	# creates dse_df.log
$grep -E "Region          |Seqno" dse_df.log
mv dse_df.log dse_df_3.log
$MUPIP replic -editinstance -show -detail $gtm_repl_instance >& editinst_3.log
$grep "Resync Sequence" editinst_3.log
echo ""
$gtm_tst/com/get_mupjnl_show.csh "*.mjl" "header" jnl_show_3.log
$grep -E "Journal file name|Sequence" jnl_show_3.log
echo ""

$gtm_tst/com/dbcheck.csh
