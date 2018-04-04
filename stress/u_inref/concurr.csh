#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
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
# This test is intended to run all mupip functionality concurrently,
# which do not need standalone database access.
# Currently: 10 GTM processes start concurrently on multiple regions
# repliction is always running
# mupip reorg runs always on both side
# After a while backup/extend/extract starts on both side

# Source random settings for the subtest
source $gtm_tst/$tst/u_inref/concurr_settings.csh

# If randomly switching to dbg versions of mupip, do not rely on the default encryption key setup as it depends on $gtm_dist, which will be
# different between dbcreate and other background jobs. Use gtm_obfuscation_key to have it the same across images. Although image switching
# happens only when the test is run in pro, it is good to run with gtm_obfuscation_key sometimes in dbg as well. Also make sure the
# encryption library and algorithm are fixed for both images.
if ( ($concurr_randdbg) && ("ENCRYPT" == "$test_encryption") ) then
	echo "randomstring" >&! gtm_obfuscation_key.txt
	setenv gtm_obfuscation_key $PWD/gtm_obfuscation_key.txt
	setenv gtm_crypt_plugin libgtmcrypt_${encryption_lib}_${encryption_algorithm}${gt_ld_shl_suffix}
	setenv encrypt_env_rerun
	source $gtm_tst/com/set_encrypt_env.csh $tst_general_dir $gtm_dist $tst_src >>! $tst_general_dir/set_encrypt_env.log
	if ("TRUE" == "$gtm_test_tls" ) source $gtm_tst/com/set_tls_env.csh
	unsetenv encrypt_env_rerun
endif

# If it is a pro run and MUPIP is randomly set to dbg image, disable gtm_db_counter_sem_incr
# since the (few) dbg mupip processes would see it but the framework script (relying on $gtm_exe) won't expect left over ipcs
if ( ("pro" == "$tst_image") && ($concurr_randdbg) ) then
	unsetenv gtm_db_counter_sem_incr   # Since it is pro run, but a few mupip processes run with dbg image
	echo "unsetenv gtm_db_counter_sem_incr"	>>&! settings.csh
endif

setenv gtmgbldir stress
setenv bkupdir1 "backupdir1"
setenv bkupdir2 "backupdir2"
if ("BG" == $acc_meth) then
	setenv test_specific_gde $gtm_tst/$tst/u_inref/stress_pri.gde
	setenv gtm_test_sprgde_id "BG"	# to differentiate multiple dbcreates done in the same subtest
	$gtm_tst/com/dbcreate_base.csh stress
	setenv test_specific_gde $gtm_tst/$tst/u_inref/stress_sec.gde
	$sec_shell "$sec_getenv; cd $SEC_SIDE; setenv gtm_test_sec_sprgde_id_different 1 ; setenv gtm_test_sprgde_id ${gtm_test_sprgde_id}_sec ; $gtm_tst/com/dbcreate_base.csh stress"
else
	setenv test_specific_gde $gtm_tst/$tst/u_inref/stress_mm_pri.gde
	setenv gtm_test_sprgde_id "MM"	# to differentiate multiple dbcreates done in the same subtest
	$gtm_tst/com/dbcreate_base.csh stress
	setenv test_specific_gde $gtm_tst/$tst/u_inref/stress_mm_sec.gde
	$sec_shell "$sec_getenv; cd $SEC_SIDE; setenv gtm_test_sec_sprgde_id_different 1 ; setenv gtm_test_sprgde_id ${gtm_test_sprgde_id}_sec ; $gtm_tst/com/dbcreate_base.csh stress"
endif
#
unsetenv gtm_repl_instance
$MUPIP set -replication=on $tst_jnl_str -REG "*" >>& jnl.log
$sec_shell "$sec_getenv; cd $SEC_SIDE; unsetenv gtm_repl_instance ; $MUPIP set -replication=on $tst_jnl_str -REG '*' >>& jnl.log"
setenv gtm_repl_instance mumps.repl
#
setenv portno `$sec_shell "$sec_getenv; source $gtm_tst/com/portno_acquire.csh"`
setenv start_time `date +%H_%M_%S`
$sec_shell "$sec_getenv; echo $portno >&! $SEC_DIR/portno"
echo $start_time >&! $PRI_DIR/start_time
#
$gtm_tst/com/SRC.csh "." $portno $start_time >>&! $PRI_DIR/START_${start_time}.out
$sec_shell "$sec_getenv; cd $SEC_DIR; $gtm_tst/com/RCVR.csh ""."" $portno $start_time < /dev/null "">&!"" $SEC_DIR/START_${start_time}.out;"
$sec_shell "$sec_getenv; cd $SEC_DIR; $gtm_tst/com/backup_for_mupip_rollback.csh"	# take backup if needed by test for later mupip_rollback.csh invocations
#
$gtm_tst/$tst/u_inref/callstress.csh init 'lhuge^initdat' 'pri'
# SYNC is needed so initialization globals, like ^instance, are guaranteed to be available on secondaries as well.  See <stress_concurr_GVUNDEF_instance_assert>.
$gtm_tst/com/RF_sync.csh >>& sync.out

# point MUPIP to dbg version when running with pro to confirm mixing of pro and dbg images of same version on same database works fine
if ( ("pro" == "$tst_image") && ($concurr_randdbg) ) then
	set ORIGMUPIP = $MUPIP
	set ORIGDSE   = $DSE
	set DBGMUPIP  = ${MUPIP:s/pro/dbg/}
	set DBGDSE    = ${DSE:s/pro/dbg/}
	if ( (-e $DBGMUPIP) && (-e $DBGDSE) ) then
		set switchMUPIP = 1
	endif
	set DBGDIST   = ${gtm_dist:s/pro/dbg/}
	set DBGMUPIP  = "env gtm_dist=${DBGDIST} ${DBGMUPIP}"
	set DBGDSE    = "env gtm_dist=${DBGDIST} ${DBGDSE}"
endif
##
if ($?switchMUPIP) then
	setenv MUPIP $DBGMUPIP:q
	setenv DSE   $DBGDSE:q
endif
##
$pri_shell "$pri_getenv; cd $PRI_SIDE; $MUPIP integ -r '*'  >>& integ.out"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP integ -r '*'  >>& integ.out"
#
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/bkgrnd_reorg.csh >>& stress_reorg1.out"
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/bkgrnd_reorg.csh >>& stress_reorg2.out"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/bkgrnd_reorg.csh >>& stress_reorg.out"
#
if ($?choose_oli) then
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/$tst/u_inref/bkgrnd_oli.csh >>& stress_oli.out"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/bkgrnd_oli.csh >>& stress_oli.out"
endif
if ($?choose_eotf) then
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/bkgrnd_eotf.csh >>& stress_eotf.out"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/bkgrnd_eotf.csh >>& stress_eotf.out"
endif
if ($?choose_updown) then
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/bkgrnd_reorg_upgrd_dwngrd.csh >>& stress_reorg_upgrd_dwngrd.out"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/bkgrnd_reorg_upgrd_dwngrd.csh >>& stress_reorg_upgrd_dwngrd.out"
endif
#
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/$tst/u_inref/bkgrnd_back.csh 'PRI' >>& back.out"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/bkgrnd_back.csh 'SEC' >>& back.out"
#
if ($?switchMUPIP) then
	# Let a couple of MUPIP process run with pro image so that pro & dbg mupip act on the db at the same time
	setenv MUPIP $ORIGMUPIP
	setenv DSE   $ORIGDSE
endif
#$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/$tst/u_inref/bkgrnd_extract_load.csh 'PRI' >>& extract_load.out"
#$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/bkgrnd_extract_load.csh 'SEC' >>& extract_load.out"
#
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/$tst/u_inref/bkgrnd_extend.csh 'PRI' >>& extend.out"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/bkgrnd_extend.csh 'SEC' >>& extend.out"
#
$gtm_tst/com/rfstatus.csh "BEFORE"
$sec_shell "$sec_getenv; $gtm_tst/com/rfstatus.csh "BEFORE:" < /dev/null"
#
$gtm_tst/$tst/u_inref/callstress.csh run 12
@ status1 = $status
if ($status1) then
	echo "TEST failed in callstress.csh run 12. Exit status = $status1. Exiting test abruptly..."
	exit 1
endif
#
$gtm_tst/com/rfstatus.csh "AFTER"
$sec_shell "$sec_getenv; $gtm_tst/com/rfstatus.csh "AFTER:" < /dev/null"
#
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/close_reorg.csh >>& stress_reorg.out"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/close_reorg.csh >>& stress_reorg.out"
#
if ($?choose_oli) then
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/$tst/u_inref/stop_bkgrnd_oli.csh >>& stop_bkgrnd_oli.out"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/stop_bkgrnd_oli.csh >>& stop_bkgrnd_oli.out"
endif
if ($?choose_eotf) then
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/stop_bkgrnd_eotf.csh >>& stop_bkgrnd_eotf.out"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/stop_bkgrnd_eotf.csh >>& stop_bkgrnd_eotf.out"
endif
if ($?choose_updown) then
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/close_reorg_upgrd_dwngrd.csh >>& stress_reorg_upgrd_dwngrd.out"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/close_reorg_upgrd_dwngrd.csh >>& stress_reorg_upgrd_dwngrd.out"
endif

$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/$tst/u_inref/stop_cmupip.csh >>& stop_cmupip.out"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/stop_cmupip.csh >>& stop_cmupip.out"
setenv test_reorg NON_REORG
$tst_tcsh $gtm_tst/com/RF_SHUT.csh  "on"
$tst_tcsh $gtm_tst/com/RF_EXTR.csh
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/dbcheck_base.csh"
$sec_shell "$sec_getenv; cd $SEC_SIDE; setenv gtm_test_sec_sprgde_id_different 1 ; setenv gtm_test_sprgde_id ${gtm_test_sprgde_id}_sec ; $gtm_tst/com/dbcheck_base.csh"
# No application level checking is done for now: Layek: 8/10/2000
#
unsetenv test_replic
setenv test_reorg NON_REORG
#
#
\mkdir ./save1; \cp {*.dat*,*.mjl*} save1
#
if ($?switchMUPIP) then
	# Some real work apart from the background jobs
	setenv MUPIP $DBGMUPIP:q
	setenv DSE   $DBGDSE:q
endif
echo "Testing recover:"
# Following is for testing journal and database match
echo "Extract from original database..."
$MUPIP extract tmp.glo >>& extract.out
$tail -n +3  tmp.glo >! origdata.glo
\rm -f tmp.glo
#
#
$gtm_tst/$tst/u_inref/mupip_restore.csh >>& mupip_restore.out
echo '$MUPIP journal -recover -forward -verbose -fence=none *'
$MUPIP journal -recover -forward -verbose -fence=none  "*" >& forw_recover.log
set stat1=$status
$grep "successful" forw_recover.log
set stat2=$status
if ($stat1 != 0 || $stat2 != 0) then
	echo "TEST-E-RECOVFAIL Mupip recover -forw failed"
	exit 1
endif
if ($?switchMUPIP) then
	# Switch to original images because
	# a) dbcreate happened with pro so let dbcheck happen with pro too to see if the dbg access above change anything
	# b) To keep the reference file output of dbcheck.csh (##SOURCE_PATH##/mupip) simpler
	setenv MUPIP $ORIGMUPIP
	setenv DSE   $ORIGDSE
endif
$gtm_tst/com/dbcheck.csh -nosprgde
echo "Extact from database after forward recovery..."
$MUPIP extract tmp.glo >>& extract.out
if ($status) echo "Extract failed"
$tail -n +3  tmp.glo >! forwglo.glo
\rm -f tmp.glo
echo "diff origdata.glo forwglo.glo"
$tst_cmpsilent origdata.glo forwglo.glo
if ($status) then
	echo "TEST failed in MUPIP recover -FORWARD"
	exit 1
endif
#
#
if (! $gtm_test_jnl_nobefore) then
	\cp -f ./save1/{*.dat*,*.mjl*} .
	echo "$MUPIP journal -recover -backward -verbose '*' -since=0 0:0:1"
	$MUPIP journal -recover -backward "*" -verbose -since=\"0 0:0:1\" >& back_recover.log
	set stat1=$status
	$grep "successful" back_recover.log
	set stat2=$status
	if ($stat1 != 0 || $stat2 != 0) then
		echo "TEST-E-RECOVFAIL Mupip recover -back failed"
		exit 1
	endif
	$gtm_tst/com/dbcheck_filter.csh -nosprgde
	echo "Extact from database after backward recovery..."
	$MUPIP extract tmp.glo >>& extract.out
	if ($status) echo "Extract failed"
	$tail -n +3  tmp.glo >! backglo.glo
	\rm -f tmp.glo
	echo "diff origdata.glo backglo.glo"
	$tst_cmpsilent origdata.glo backglo.glo
	if ($status) then
		echo "TEST failed in MUPIP recover -BACKWARD"
		exit 1
	endif
	#
	echo "Testing rollback:"
	echo "Get JNLSEQNO from Secondary (B) at the first backup point..."
	setenv tst_seqno `$sec_shell "$sec_getenv; cd $SEC_SIDE/$bkupdir1; $gtm_tst/com/cur_jnlseqno.csh REGION 0 < /dev/null"`
	# take backup of db/jnl before doing rollback (just in case it fails and we need to debug)
	$sec_shell "$sec_getenv; cd $SEC_SIDE; mkdir ./save2; cp *.dat* *.mj* ./save2"
	#
	echo "Now do rollback:"
	$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$gtm_tst/com/mupip_rollback.csh -verbose -resync='$tst_seqno' -losttrans=lost.glo "*" >>&! rollback.log; $grep "successful" rollback.log'
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/dbcheck_filter.csh -nosprgde"
	$sec_shell "$sec_getenv; cd $SEC_SIDE/$bkupdir1; unsetenv gtm_repl_instance; "'$MUPIP extract backed.gbl >>&! backed.out; $tail -n +3 backed.gbl >! backed.glo'
	$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$MUPIP extract srcextr.gbl >>&! srcextr.out; $tail -n +3 srcextr.gbl >! srcextr.glo'
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $tst_cmpsilent ./$bkupdir1/backed.glo srcextr.glo ;if ($status) echo Rollback failed"
	#
endif
foreach x ( 1 2 )
	$grep "YDB-E-SEMWT2LONG" online${x}_loop.out >& /dev/null
	if (! $status) then
		mv online${x}_loop.out online${x}_loop.outx
		$grep -v -E "YDB-E-SEMWT2LONG|YDB-E-DBFILERR" online${x}_loop.outx >& online${x}_loop.out
	endif
end
