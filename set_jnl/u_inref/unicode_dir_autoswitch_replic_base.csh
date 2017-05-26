#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2007-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This applies to replication only
setenv tst_buffsize 1048576
set unidir="αβγδε.能吞.ＡＢＣＤＥＦＧ.能吞下玻璃而傷"
set dbbase="ＡＢＣＤＥＦＧ能吞下玻璃而傷"
\mkdir $unidir
cd $unidir
setenv gtmgbldir $dbbase.gld
source $gtm_tst/com/dbcreate_base.csh $dbbase 4 225 1000 1024 5000 8192 5000
# Since this test uses dbcreate_base and starts replication all by itself, unsetenv gtm_custom_errors until the source servers
# are started to avoid any FTOKERR/ENO2 errors (in MUPIP SET commands) due to the non-existence of mumps.repl instance file.
if ($?gtm_custom_errors) then
	setenv restore_gtm_custom_errors $gtm_custom_errors
	unsetenv gtm_custom_errors
endif
$MUPIP set -replication=on -REG "*" >>& jnl.log
echo "On Primary:"
$MUPIP set $tst_jnl_str,epoch=10,extension=1,auto=16384,alloc=4096 -reg AREG
$MUPIP set $tst_jnl_str,epoch=900,auto=17388,alloc=5100 -reg BREG
$MUPIP set $tst_jnl_str,epoch=10,auto=17388,alloc=5100 -reg CREG
$MUPIP set $tst_jnl_str,epoch=900,auto=17388,alloc=5100 -reg DEFAULT
echo "On Secondary:"
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; \mkdir $unidir; cd $unidir; setenv gtmgbldir $dbbase.gld  ; source $gtm_tst/com/dbcreate_base.csh $dbbase 6 225 1000 1024 5000 8192 5000"
$sec_shell "$sec_getenv ; cd $SEC_SIDE/$unidir; $MUPIP set -replication=on -REG '*' >>& jnl.log"
#
setenv portno `$sec_shell "$sec_getenv ; source $gtm_tst/com/portno_acquire.csh"`
$sec_shell "$sec_getenv ; echo $portno >&! $SEC_SIDE/portno"
#
if ($?restore_gtm_custom_errors) then
	setenv gtm_custom_errors $restore_gtm_custom_errors
	unsetenv restore_gtm_custom_errors
endif
$gtm_tst/com/SRC.csh "." $portno "" >>&! START.out
$sec_shell  "$sec_getenv ; cd $SEC_SIDE/$unidir; $gtm_tst/com/RCVR.csh ""."" $portno "" < /dev/null "">&!"" $SEC_SIDE/START.out ; "

setenv gtm_test_switches_jnl_files 1	# indicate to mupip_rollback.csh that this test switches jnlfiles explicitly
# Below script invocation is needed explicitly on PRI and SEC side because dbcreate.csh is not called by this test
$gtm_tst/com/backup_for_mupip_rollback.csh
$sec_shell "$sec_getenv; cd $SEC_SIDE; cd $unidir; $gtm_tst/com/backup_for_mupip_rollback.csh"

#
set jnlstr1 = "epoch=30,auto=18240,alloc=8000"
$sec_shell "$sec_getenv ; cd $SEC_SIDE/$unidir; $MUPIP set $tst_jnl_str,$jnlstr1 -reg BREG"
$sec_shell "$sec_getenv ; cd $SEC_SIDE/$unidir; $MUPIP set $tst_jnl_str,epoch=30,auto=17388,alloc=5100 -reg CREG"
$sec_shell "$sec_getenv ; cd $SEC_SIDE/$unidir; $MUPIP set $tst_jnl_str,epoch=900,auto=17388,alloc=5100 -reg DREG"
echo "Starting GTM processes..."
$gtm_tst/com/imptp.csh >>&! imptp.out
sleep 20
$MUPIP set $tst_jnl_str,epoch=10,extension=1,auto=16384,alloc=4096 -reg AREG
$sec_shell "$sec_getenv; cd $SEC_SIDE; cd $unidir; $MUPIP set $tst_jnl_str,$jnlstr1 -reg BREG"
sleep 10
if (0 == $gtm_test_forward_rollback) then
	set newjnlfile="../last_a.mjl"
else
	# If forward rollback is enabled, then don't point new jnlfile in a parent directory.
	# It makes processing in mupip_rollback.csh very difficult to cp/mv jnl files to/from backup directories.
	set newjnlfile="last_a.mjl"
endif

$MUPIP set $tst_jnl_str,epoch=10,extension=1,auto=16384,alloc=4096,file=$newjnlfile -reg AREG
$sec_shell "$sec_getenv ; cd $SEC_SIDE/$unidir; $MUPIP set $tst_jnl_str,$jnlstr1,file=$newjnlfile -reg BREG"
sleep 10
echo "Stopping GTM processes..."
$gtm_tst/com/endtp.csh >>& endtp.out
setenv  PRI_SIDE_TEMP $PRI_SIDE
setenv  SEC_SIDE_TEMP $SEC_SIDE
setenv PRI_SIDE "$PRI_SIDE/$unidir"
setenv SEC_SIDE "$SEC_SIDE/$unidir"
$gtm_tst/com/RF_sync.csh >&! rf_sync.log
setenv  PRI_SIDE $PRI_SIDE_TEMP
setenv  SEC_SIDE $SEC_SIDE_TEMP
$sec_shell "$sec_getenv ; cd $SEC_SIDE/$unidir; $gtm_tst/com/RCVR_SHUT.csh ""on"" < /dev/null >>&! $SEC_SIDE/SHUT.out"
$gtm_tst/com/SRC_SHUT.csh ""on"" >&! SRC_SHUT.out
$gtm_tst/com/db_extract.csh pri.glo
$sec_shell "$sec_getenv ; cd $SEC_SIDE/$unidir; $gtm_tst/com/db_extract.csh ../sec.glo"
$tst_cmpsilent pri.glo $SEC_SIDE/sec.glo
if ($status != 0) then
	echo "TEST-E-FAILED: DATABASE EXTRACTs on PRIMARY and SECONDARY are DIFFERENT"
else
	echo "DATABASE EXTRACT PASSED"
endif
$gtm_tst/com/dbcheck_base.csh
$sec_shell "$sec_getenv ; cd $SEC_SIDE/$unidir; $gtm_tst/com/dbcheck_base.csh"
###############################################################
$gtm_tst/$tst/u_inref/jnlverify.csh >& verification.out
$sec_shell "$sec_getenv ; cd $SEC_SIDE/$unidir; $gtm_tst/$tst/u_inref/jnlverify.csh >& verification.out"
sleep 1
$grep -E 'GTM-E|GTM-F'  verification.out
if ($status == 0) then
	echo "Please look at verification.out for details"
endif
$gtm_tst/$tst/u_inref/jnlrollback.csh 2 >>&! rollback.out
$grep -E "JNLSUCC" rollback.out
$sec_shell "$sec_getenv ; cd $SEC_SIDE/$unidir; setenv gtm_test_switches_jnl_files 1; $gtm_tst/$tst/u_inref/jnlrollback.csh 2 >>&! sec_rollback.out ; $grep 'JNLSUCC' sec_rollback.out"
$gtm_tst/com/db_extract.csh pri2.glo
$sec_shell "$sec_getenv ; cd $SEC_SIDE/$unidir; $gtm_tst/com/db_extract.csh ../sec2.glo"
$tst_cmpsilent pri2.glo $SEC_SIDE/sec2.glo
if ($status != 0) then
	echo "TEST-E-FAILED: DATABASE EXTRACTs on PRIMARY and SECONDARY are DIFFERENT after rollback"
else
	echo "DATABASE EXTRACT PASSED after rollback"
endif
$gtm_tst/com/portno_release.csh
