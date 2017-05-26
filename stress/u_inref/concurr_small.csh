#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This test is intended to run all mupip functionality concurrently,
# which do not need standalone database access.
# Currently: 10 GTM process starts concurrently on multiple region
# repliction is always running
# mupip reorg runs always on both side
# After a while backup/extend/extract starts on both side
# The below is the instance topology of the test
#
# INST1 (A)(non-supplementary) ------>	INST2 (P)(supplementary)
#	|					|
#	|					|
#	V					V
# INST3 (B)(non-supplementary)		INST4 (Q)(supplementary)
#
# The test could use the new MSR framework to pickup default suppl/non-suppl topolgy and RF_EXTR b/w INST1 and INST2 will be possible then
#
# Source random settings for the subtest
source $gtm_tst/$tst/u_inref/concurr_settings.csh

# Earlier this test created backup, database and journal files with unicode names if the test was submitted
# with $gtm_chset=UTF-8 randomness. Due to the frequency in stress test failures, difficulty in debugging these failures
# under unicode names and the fact that # test/unicode/u_inref/filenames.csh already exercises unicode file names for all
# GT.M resources, do not play with unicode file names in this test.

setenv gtmgbldir stress
setenv bkupdir1 "backupdir1"
setenv bkupdir2 "backupdir2"
if ("BG" == $acc_meth) then
	setenv gtm_test_sprgde_id "ID1_BG"	# to differentiate multiple dbcreates done in the same subtest
	setenv test_specific_gde $gtm_tst/$tst/u_inref/stress_pri.gde
else
	setenv gtm_test_sprgde_id "ID1_MM"	# to differentiate multiple dbcreates done in the same subtest
	setenv test_specific_gde $gtm_tst/$tst/u_inref/stress_mm_pri.gde
endif

# use an external filter in the source and receiver servers
source $gtm_tst/com/random_extfilter.csh	# sets gtm_tst_ext_filter_src and gtm_tst_ext_filter_rcvr env vars
setenv gtm_tst_ext_filter_spaces 10		# override random choice to avoid too high a value causing huge test runtimes
# Do this BEFORE MULTISITE_REPLIC_PREPARE to make sure MSR instances get a copy of the env var gtm_tst_ext_filter_spaces
# in case this test is run with -multisite (which it currently is not).

$MULTISITE_REPLIC_PREPARE 4
$gtm_tst/com/dbcreate_base.csh stress
unsetenv gtm_repl_instance
$MUPIP set -replication=on $tst_jnl_str -REG "*" >>& jnl.log
#
set sprgdeset = "echo setenv gtm_test_sec_sprgde_id_different 1 >> env_supplementary.csh; echo setenv gtm_test_sprgde_id "
if ("BG" == $acc_meth) then
	set sprgdeset2 = "$sprgdeset ""ID2_BG"""	# to differentiate multiple dbcreates done in the same subtest
	set sprgdeset3 = "$sprgdeset ""ID3_BG"""	# to differentiate multiple dbcreates done in the same subtest
	set sprgdeset4 = "$sprgdeset ""ID4_BG"""	# to differentiate multiple dbcreates done in the same subtest
	setenv test_specific_gde $gtm_tst/$tst/u_inref/stress_sec.gde
else
	set sprgdeset2 = "$sprgdeset ""ID2_MM"""	# to differentiate multiple dbcreates done in the same subtest
	set sprgdeset3 = "$sprgdeset ""ID3_MM"""	# to differentiate multiple dbcreates done in the same subtest
	set sprgdeset4 = "$sprgdeset ""ID4_MM"""	# to differentiate multiple dbcreates done in the same subtest
	setenv test_specific_gde $gtm_tst/$tst/u_inref/stress_mm_sec.gde
endif

# Use different gtm_test_sprgde_id for INST2/INST3/INST4 since they use a separate dbcreate (than INST1).
$MSR RUN INST2 "set msr_dont_trace ; $sprgdeset2 >> env_supplementary.csh"
$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/com/dbcreate_base.csh stress"
$MSR RUN INST2 'set msr_dont_trace ; unsetenv gtm_repl_instance ; $MUPIP set -replication=on $tst_jnl_str -REG "*" >>& jnl.log'
#
$MSR RUN INST3 "set msr_dont_trace ; $sprgdeset3 >> env_supplementary.csh"
$MSR RUN INST3 "set msr_dont_trace ; $gtm_tst/com/dbcreate_base.csh stress"
$MSR RUN INST3 'set msr_dont_trace ; unsetenv gtm_repl_instance ; $MUPIP set -replication=on $tst_jnl_str -REG "*" >>& jnl.log'
#
$MSR RUN INST4 "set msr_dont_trace ; $sprgdeset4 >> env_supplementary.csh"
$MSR RUN INST4 "set msr_dont_trace ; $gtm_tst/com/dbcreate_base.csh stress"
$MSR RUN INST4 'set msr_dont_trace ; unsetenv gtm_repl_instance ; $MUPIP set -replication=on $tst_jnl_str -REG "*" >>& jnl.log'

# Now that all the set -replic commands are done, set gtm_repl_instance.
setenv gtm_repl_instance mumps.repl

#
setenv test_replic_suppl_type 1
$MSR STARTSRC INST1 INST2
$MSR STARTRCV INST1 INST2 helper
$MSR RUN INST2 'set msr_dont_trace ; $gtm_tst/com/backup_for_mupip_rollback.csh'	# take backup if needed by test for later mupip_rollback.csh invocations
setenv test_replic_suppl_type 0
$MSR STARTSRC INST1 INST3
$MSR STARTRCV INST1 INST3 helper
setenv test_replic_suppl_type 2
$MSR START INST2 INST4
#
##
$MSR RUN INST1 "set msr_dont_trace ; $gtm_tst/$tst/u_inref/callstress.csh init 'lsmall^initdat' 'INST1'" > init_callstress_inst1.out
#
$MSR SYNC ALL_LINKS
$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/$tst/u_inref/callstress.csh init 'lsmall^initdat' 'INST2'" > init_callstress_inst2.out
#
$MSR RUN INST1 'set msr_dont_trace ; $MUPIP integ -r "*"  >>& integ.out'
$MSR RUN INST2 'set msr_dont_trace ; $MUPIP integ -r "*"  >>& integ.out'
#
$MSR RUN INST1 "set msr_dont_trace ; $gtm_tst/com/bkgrnd_reorg.csh >>& stress_reorg1.out"
$MSR RUN INST1 "set msr_dont_trace ; $gtm_tst/com/bkgrnd_reorg.csh >>& stress_reorg2.out"
$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/com/bkgrnd_reorg.csh >>& stress_reorg.out"
#
if ($?choose_oli) then
	$MSR RUN INST1 "set msr_dont_trace ; $gtm_tst/$tst/u_inref/bkgrnd_oli.csh >>& stress_oli.out"
	$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/$tst/u_inref/bkgrnd_oli.csh >>& stress_oli.out"
endif
if ($?choose_eotf) then
	$MSR RUN INST1 "set msr_dont_trace ; $gtm_tst/com/bkgrnd_eotf.csh >>& stress_eotf.out"
	$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/com/bkgrnd_eotf.csh >>& stress_eotf.out"
endif
if ($?choose_updown) then
	$MSR RUN INST1 "set msr_dont_trace ; $gtm_tst/com/bkgrnd_reorg_upgrd_dwngrd.csh >>& stress_reorg_upgrd_dwngrd.out"
	$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/com/bkgrnd_reorg_upgrd_dwngrd.csh >>& stress_reorg_upgrd_dwngrd.out"
endif
#
$MSR RUN INST1 "set msr_dont_trace ; $gtm_tst/$tst/u_inref/bkgrnd_back.csh 'PRI' >>& back.out"
$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/$tst/u_inref/bkgrnd_back.csh 'SEC' >>& back.out"
#
#$MSR RUN INST1 "set msr_dont_trace ; $gtm_tst/$tst/u_inref/bkgrnd_extract_load.csh 'PRI' >>& extract_load.out"
#$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/$tst/u_inref/bkgrnd_extract_load.csh 'SEC' >>& extract_load.out"
#
$MSR RUN INST1 "set msr_dont_trace ; $gtm_tst/$tst/u_inref/bkgrnd_extend.csh 'PRI' >>& extend.out"
$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/$tst/u_inref/bkgrnd_extend.csh 'SEC' >>& extend.out"
#
$MSR RUN SRC=INST1 RCV=INST2 "set msr_dont_trace ; $gtm_tst/com/rfstatus.csh BEFORE"
$MSR RUN RCV=INST2 SRC=INST1 "set msr_dont_trace ; $gtm_tst/com/rfstatus.csh BEFORE: < /dev/null"
#
$MSR RUN INST1 '$gtm_tst/$tst/u_inref/callstress.csh run 12 >&! callstress.out & ' >&! bg_callstress_INST1.out
$MSR RUN INST2 '$gtm_tst/$tst/u_inref/callstress.csh run 12 >&! callstress.out & ' >&! bg_callstress_INST2.out
$MSR RUN INST1 '$gtm_tst/com/wait_for_log.csh -log callstress.out -waitcreation -duration 1200 -message "Application Level Verification Ends"'
$MSR RUN INST2 '$gtm_tst/com/wait_for_log.csh -log callstress.out -waitcreation -duration 1200 -message "Application Level Verification Ends"'
#
$MSR RUN SRC=INST1 RCV=INST2 "set msr_dont_trace ; $gtm_tst/com/rfstatus.csh AFTER"
$MSR RUN RCV=INST2 SRC=INST1 "set msr_dont_trace ; $gtm_tst/com/rfstatus.csh AFTER: < /dev/null"
#
$MSR RUN INST1 "set msr_dont_trace ; $gtm_tst/com/close_reorg.csh >>& stress_reorg.out"
$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/com/close_reorg.csh >>& stress_reorg.out"
#
if ($?choose_oli) then
	$MSR RUN INST1 "set msr_dont_trace; $gtm_tst/$tst/u_inref/stop_bkgrnd_oli.csh >>& stop_bkgrnd_oli.out"
	$MSR RUN INST2 "set msr_dont_trace; $gtm_tst/$tst/u_inref/stop_bkgrnd_oli.csh >>& stop_bkgrnd_oli.out"
endif
if ($?choose_eotf) then
	$MSR RUN INST1 "set msr_dont_trace; $gtm_tst/com/stop_bkgrnd_eotf.csh >>& stop_bkgrnd_eotf.out"
	$MSR RUN INST2 "set msr_dont_trace; $gtm_tst/com/stop_bkgrnd_eotf.csh >>& stop_bkgrnd_eotf.out"
endif
if ($?choose_updown) then
	$MSR RUN INST1 "set msr_dont_trace ; $gtm_tst/com/close_reorg_upgrd_dwngrd.csh >>& stress_reorg_upgrd_dwngrd.out"
	$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/com/close_reorg_upgrd_dwngrd.csh >>& stress_reorg_upgrd_dwngrd.out"
endif
#
$MSR RUN INST1 "set msr_dont_trace ; $gtm_tst/$tst/u_inref/stop_cmupip.csh >>& stop_cmupip.out"
$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/$tst/u_inref/stop_cmupip.csh >>& stop_cmupip.out"
setenv test_reorg NON_REORG
setenv test_replic_suppl_type 1
$MSR STOP INST1 INST2 ON
setenv test_replic_suppl_type 0
$MSR STOP INST1 INST3 ON
setenv test_replic_suppl_type 2
$MSR STOP INST2 INST4 ON
echo ""
echo "Doing database extract diff of INST1 and INST3"
$MSR EXTRACT INST1 INST3
echo ""
echo "Doing database extract diff of INST2 and INST4"
$MSR EXTRACT INST2 INST4

echo ""
echo "Doing dbcheck of INST1"
$MSR RUN INST1 "set msr_dont_trace ; $gtm_tst/com/dbcheck_base.csh"
echo ""
echo "Doing dbcheck of INST2"
$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/com/dbcheck_base.csh"
echo ""
echo "Doing dbcheck of INST3"
$MSR RUN INST3 "set msr_dont_trace ; $gtm_tst/com/dbcheck_base.csh"
echo ""
echo "Doing dbcheck of INST4"
$MSR RUN INST4 "set msr_dont_trace ; $gtm_tst/com/dbcheck_base.csh"
echo ""
# No application level checking is done for now: Layek: 8/10/2000
#
unsetenv test_replic
setenv test_reorg NON_REORG
#
#
\mkdir ./save1; \cp {*.dat*,*.mjl*} save1
#
echo "Testing recover:"
# Following is for testing journal and database match
echo "Extact from original database..."
$MUPIP extract tmp.glo >>& extract.out
$tail -n +3  tmp.glo >! origdata.glo
\rm -f tmp.glo
#
#
$gtm_tst/$tst/u_inref/mupip_restore.csh >>& mupip_restore.out
echo "$MUPIP journal -recover -forward -verbose -fence=none *"
$MUPIP journal -recover -forward -verbose -fence=none  "*" >& forw_recover.log
set stat1=$status
$grep "successful" forw_recover.log
set stat2=$status
if ($stat1 != 0 || $stat2 != 0) then
	echo "TEST-E-RECOVFAIL Mupip recover -forw failed"
	exit 1
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
	echo "TEST falied in MUPIP recover -FORWARD"
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
		echo "TEST falied in MUPIP recover -BACKWARD"
		exit 1
	endif
	#
	echo "Testing rollback:"
	echo "Get JNLSEQNO from Secondary (B) at the first backup point..."
	setenv tst_seqno `$MSR RUN INST2 "set msr_dont_trace ; cd $bkupdir1 ; $gtm_tst/com/cur_jnlseqno.csh REGION 0 < /dev/null"`
	$MSR RUN INST2 "set msr_dont_trace ; mkdir ./save2; cp *.dat* *.mj* ./save2"
	#
	#
	#
	echo "Now do rollback:"
	$MSR RUN INST2 'set msr_dont_trace ; $gtm_tst/com/mupip_rollback.csh -verbose -resync=$tst_seqno -losttrans=lost.glo "*" >>&! rollback.log; $grep successful rollback.log'
	$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/com/dbcheck_filter.csh -nosprgde"
	$MSR RUN INST2 "set msr_dont_trace ; cd $bkupdir1; unsetenv gtm_repl_instance; $MUPIP extract backed.gbl >>&! backed.out; $tail -n +3 backed.gbl >! backed.glo"
	$MSR RUN INST2 "set msr_dont_trace ; $MUPIP extract srcextr.gbl >>&! srcextr.out; $tail -n +3 srcextr.gbl >! srcextr.glo"
	$MSR RUN INST2 "set msr_dont_trace ; $tst_cmpsilent ./$bkupdir1/backed.glo srcextr.glo ;if ($status) echo Rollback falied"
	#
endif
