#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# GTM-7083 replic test cases

# Disabled settings that do not work with MSR and prior versions
source $gtm_tst/com/disable_settings_msr_priorver.csh

# Since an upgrade takes place, some previous journal files will be older versions and trigupgrd_test.csh will fail
unsetenv gtm_test_trig_upgrade
# INST3,INST4 wouldn't have been used at the time of first dbcheck.
## if $gtm_custom_errors is set, they would fail with FTOKERR/ENO2.
unsetenv gtm_custom_errors
# Helpers can log FILERENAME messages that would normally appear in the outref, so disable them.
setenv gtm_test_updhelpers 0
##
alias knownerror 'mv \!:1 {\!:1}x ; $grep -vE "\!:2" {\!:1}x >&! \!:1 '


if ($?gtm_test_replay) then
	set prior_ver = $gtm7083_priorver
else
	# A post V62000 version can replicate with triggers enabled only with V62000 and not any versions prior to it
	# For now only V62000-V62001 requires trigger upgrade. Change the -lte when this changes
	$gtm_tst/com/random_ver.csh -gte V62000 -lte V62000 >&! prior_ver.txt
	if ($status) then
		echo "TEST-E-PRIORVER. Error obtaining random prior version. Check prior_ver.txt"
		cat prior_ver.txt
		exit
	else
		set prior_ver = `cat prior_ver.txt`
	endif
	echo "setenv gtm7083_priorver $prior_ver"	>>&! settings.csh
endif

$MULTISITE_REPLIC_PREPARE 4
cp msr_instance_config.txt msr_instance_config.bak1
$tst_awk '{if("VERSION:" == $2){sub("'$tst_ver'","'$prior_ver'")};print}' msr_instance_config.bak1 >&! msr_instance_config.txt

$gtm_tst/com/dbcreate.csh mumps >&! dbcreate_priorver.out
cat > gbl.trg << CAT_EOF
+^GBL(:) -commands=set -xecute="write ""trigger executed"",!" -name=trigname
CAT_EOF

cat > new.trg << CAT_EOF
+^new(:) -commands=set -xecute="write ""trigger executed"",!" -name=newtrig
CAT_EOF

#        --> Have A->B replication working with V62000 and NO triggers installed. Then upgrade A to V62001. There should be NO
#                need to run MUPIP TRIGGER -UPGRADE. All tools should work just fine including trigger loading.

$MSR START INST1 INST2
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 10'
$MSR SYNC INST1 INST2
$MSR STOPSRC INST1 INST2

echo "# Now upgrade INST1 to current version"
cp msr_instance_config.txt msr_instance_config.bak2
$tst_awk '{if(("VERSION:" == $2) && ("INST1" == $1)){sub("'$prior_ver'","'$tst_ver'")};print}' msr_instance_config.bak2 >&! msr_instance_config.txt
$GDE exit >& gde_upgrade1.out
$MUPIP set $tst_jnl_str -noprevjnlfile -region "*" >>&! jnl.log
$MSR STARTSRC INST1 INST2

echo "# Installing triggers should work fine"
$MUPIP trigger -triggerfile=gbl.trg
$gtm_exe/mumps -run %XCMD "set ^GBL(1)=1"
$gtm_tst/com/dbcheck.csh -extract INST1 INST2 >&! dbcheck1.out
sed 's;.*'$prior_ver'/'$tst_image'/mupip;##FILTERED##/mupip;' dbcheck1.out

# Instead of a completely new subtest, just use fresh Instances INST3 and INST4 for the next testcase
#        --> Have A->B replication working with V62000 and SOME triggers installed. Then upgrade A to V62001. There should be a
#                need to run MUPIP TRIGGER -UPGRADE. Otherwise any utility that requires examining and interpreting ^#t global
#                should issue NEEDTRIGUPGRD error.
#        --> Have A->B replication working with SOME triggers using V62000. Now upgrade A to V62001. Run MUPIP TRIGGER -UPGRADE.
#                Now install triggers on A and see if they get replicated on B. The update process should have issued
#                NEEDTRIGUPGRD error and exited. Restart the update process and it should issue the same error and error out.
#                Now do a MUPIP TRIGGER -UPGRADE on secondary and restsrat the update process and it should run fine.
#                Replication should resume without issues.
#

$MSR RUN SRC=INST1 RCV=INST3 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/{gbl,new}.trg _REMOTEINFO___RCV_DIR__/'
$MSR START INST3 INST4
$MSR RUN INST3 '$MUPIP trigger -triggerfile=gbl.trg'
$MSR RUN INST3 '$gtm_tst/com/simpleinstanceupdate.csh 10'
$MSR SYNC INST3 INST4
$MSR STOP INST3 INST4
echo "# Now upgrade INST3 and INST4 to current version"
cp msr_instance_config.txt msr_instance_config.bak3
$tst_awk '{if(("VERSION:" == $2) && (("INST3" == $1) || ("INST4" == $1))){sub("'$prior_ver'","'$tst_ver'")};print}' msr_instance_config.bak3 >&! msr_instance_config.txt
$MSR RUN INST3 '$GDE exit >& gde_upgrade2.out'
$MSR RUN INST3 'set msr_dont_trace ; $MUPIP set $tst_jnl_str -noprevjnlfile -region "*" >>&! jnl.log'
$MSR RUN INST4 '$GDE exit >& gde_upgrade3.out'
$MSR RUN INST3 'set msr_dont_trace ; $MUPIP set $tst_jnl_str -noprevjnlfile -region "*" >>&! jnl.log'
$MSR START INST3 INST4
get_msrtime
echo "# Anything that requires examining triggers should issue NEEDTRIGUPGRD error"
$MSR RUN INST3 'set msr_dont_chk_stat ; echo "" | $MUPIP trigger -select '
knownerror $msr_execute_last_out GTM-E-NEEDTRIGUPGRD
$MSR RUN INST3 'set msr_dont_chk_stat ; $gtm_exe/mumps -run %XCMD "set ^GBL(1)=1"'
knownerror $msr_execute_last_out GTM-E-NEEDTRIGUPGRD
echo "# The same commands should work fine after trigger -upgrade"
$MSR RUN INST3 '$MUPIP trigger -upgrade'
echo "# trigger -upgrade should cut new journal file with no back link"
$MSR RUN INST3 '$MUPIP journal -show=header -forward mumps.mjl|& $grep "Prev journal file name"'
echo "# journal extract of the trigger-upgrade jnl file should show an empty LGTRIG record and ^#t USET/UKILL records."
$MSR RUN INST3 'set prevmjl = `ls -rt mumps.mjl_* | $tail -1` ; $MUPIP journal -extract -forw -detail $prevmjl >&! jnlextract.out'
$MSR RUN SRC=INST3 RCV=INST1 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/mumps.mjf _REMOTEINFO___RCV_DIR__/inst3mumps.mjf'
$tst_awk -F '\\' '/TLGTRIG|UKILL|USET/ {sub(".*::","") ; print $1, $NF}' inst3mumps.mjf
$MSR RUN INST3 'echo "" | $MUPIP trigger -select '
$MSR RUN INST3 '$gtm_exe/mumps -run %XCMD "set ^GBL(1)=1"'
$MSR RUN INST3 '$MUPIP trigger -triggerfile=new.trg'
$MSR RUN INST3 'echo "" | $MUPIP trigger -select '
echo "# When the new trigger gets replicated to the receiver, updproc would exit with NEEDTRIGUPGRD"
$MSR RUN INST4 "set msr_dont_trace ; $gtm_tst/com/wait_for_log.csh -log RCVR_${time_msr}.log.updproc -message NEEDTRIGUPGRD"
$MSR RUN INST4 "$msr_err_chk RCVR_$time_msr.log.updproc NEEDTRIGUPGRD"
knownerror $msr_execute_last_out GTM-E-NEEDTRIGUPGRD
echo "# Simply restarting update process will still result in the same NEEDTRIGUPGRD error"
$MSR RUN INST4 '$MUPIP replicate -receiver -start -updateonly'
$MSR RUN INST4 "set msr_dont_trace ; $gtm_tst/com/wait_for_log.csh -log RCVR_${time_msr}.log.updproc -message NEEDTRIGUPGRD"
$MSR RUN INST4 "$msr_err_chk RCVR_$time_msr.log.updproc NEEDTRIGUPGRD"
knownerror $msr_execute_last_out GTM-E-NEEDTRIGUPGRD
echo "# Restarting update process after upgrading the triggers on the reciever side should work fine"
$MSR RUN INST4 '$MUPIP trigger -upgrade'
$MSR RUN INST4 '$MUPIP replicate -receiver -start -updateonly'
$MSR RUN INST3 '$gtm_exe/mumps -run %XCMD "set ^new(1)=1"'
$MSR RUN INST3 '$MUPIP trigger -triggerfile=new.trg'
$gtm_tst/com/dbcheck.csh -extract INST3 INST4 >&! dbcheck2.out
sed 's;.*'$prior_ver'/'$tst_image'/mupip;##FILTERED##/mupip;' dbcheck2.out
