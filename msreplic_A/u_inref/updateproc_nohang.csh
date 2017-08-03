#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Disabled settings that do not work with MSR and prior versions
source $gtm_tst/com/disable_settings_msr_priorver.csh

setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn 1
# double random prior versions are used. Avoid complex checking and disable UTF-8 (not important in this test case)
$switch_chset "M" >&! switch_chset1.out

$MULTISITE_REPLIC_PREPARE 3

if (2 == $test_replic_mh_type) then
	set minver = "V54002"
else
	set minver = "V51000"
endif
# Versions prior to V54002 has a bug in receiver server misinterpreting incoming journal record format if it comes from a cross-endian source.
set prior_ver2 = `$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/com/random_ver.csh -gte $minver"`
set prior_ver3 = `$MSR RUN INST3 "set msr_dont_trace ; $gtm_tst/com/random_ver.csh -gte $minver"`
if ( "${prior_ver2}" =~ "*-E-*" || "${prior_ver3}" =~ "*-E-*" ) then
	echo "Either prior_ver2 or prior_ver3 is bad"
	echo "prior_ver2 : '${prior_ver2}'"
	echo "prior_ver3 : '${prior_ver3}'"
	exit -1
endif
echo "$prior_ver2" > priorver2.txt
echo "$prior_ver3" > priorver3.txt
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver2
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver3

# If either random version is prior to V60002 disable IPv6
if ( `expr "$prior_ver2" \<= "V60002"` || `expr "$prior_ver3" \<= "V60002"` ) then
	setenv test_no_ipv6_ver 1
	echo "setenv test_no_ipv6_ver $test_no_ipv6_ver" >> settings.csh
endif


# kill/restart of update process will hang for ever if prior version is < V55000 and the replication is cross-endian
# In order to keep the reference file consistent, the "kill update process" message is printed even if it is not killed for the above reason

# Tweak configuration file to have prior_ver as the version in INST2 and INST3
set ins_file = $tst_working_dir/msr_instance_config.txt
cp $ins_file ${ins_file}_bak
$tst_awk 'BEGIN{FS = "\t"; OFS = "\t"} {if (($1 == "INST2") && ($2 ~ "VERSION")) $3 = "'$prior_ver2'"; if (($1 == "INST2") && ($2 ~ "IMAGE")) $3 = "pro"; print}' $ins_file > /tmp/msr_instance_config_{$$}.txt
mv /tmp/msr_instance_config_{$$}.txt $ins_file
$tst_awk 'BEGIN{FS = "\t"; OFS = "\t"} {if (($1 == "INST3") && ($2 ~ "VERSION")) $3 = "'$prior_ver3'"; if (($1 == "INST3") && ($2 ~ "IMAGE")) $3 = "pro"; print}' $ins_file > /tmp/msr_instance_config_{$$}.txt
mv /tmp/msr_instance_config_{$$}.txt $ins_file
if ($?test_no_ipv6_ver) then
	sed 's/\.v6//g;s/\.v46//g' < $ins_file > /tmp/msr_instance_config_{$$}.txt
	mv /tmp/msr_instance_config_{$$}.txt $ins_file
endif
$MULTISITE_REPLIC_ENV

# For versions prior to V55000 killing update process of a cross-endian receiver will result in a hang.
if ((2 == $test_replic_mh_type) && (`expr $prior_ver2 \< "V55000"` )) then
	set dont_kill_updproc2 = 1
endif
if ((2 == $test_replic_mh_type) && (`expr $prior_ver3 \< "V55000"` )) then
	set dont_kill_updproc3 = 1
endif
$gtm_tst/com/dbcreate.csh mumps 1 >&! dbcreate_output.out
# On some platforms specifying multiple substitution strings in the same command does not work so use two separate sed commands
sed 's|/'$prior_ver2'/|/##FILTERED##PRIORVER##/|' dbcreate_output.out | sed 's|/'$prior_ver3'/|/##FILTERED##PRIORVER##/|'

# =========== Test case (1) begin ===========
# Start replication normally
$MSR STARTSRC INST1 INST2
$MSR RUN INST2 '$MUPIP replic -instance_create -name=$gtm_test_cur_pri_name; $gtm_tst/com/jnl_on.csh $test_jnldir -replic=on'
$MSR RUN RCV=INST2 '$MUPIP replic -source -start -passive -log=passive_source.log -buf=1 -instsecondary=INSTANCE1'
$MSR RUN RCV=INST2 '$MUPIP replic -receiv -start -listen=__RCV_PORTNO__ -log=RCVR_restart.log -buf=$tst_buffsize'

# Get the pid of update process on the secondary and kill/restart it
$MSR RUN INST2 '$MUPIP replic -receiver -checkhealth ' >&! checkhealthINST2_1.out
set updprocpid = `$tst_awk '/PID.*Update process/{print $2}' checkhealthINST2_1.out`
echo "# Kill the update process on INST2"
if !( $?dont_kill_updproc2 ) then
	$MSR RUN INST2 "set msr_dont_trace ; $kill9 $updprocpid"
	$MSR RUN INST2 '$MUPIP replicate -receiver -start -updateonly' >&! INST2_restart_updprocess.out
endif
# A few updates
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 50'
# =========== Test case (1) end ===========


# =========== Test case (2) begin ===========
# Get the pid of update process on the secondary and kill/restart it
$MSR RUN INST2 '$MUPIP replic -receiver -checkhealth ' >&! checkhealthINST2_2.out
set updprocpid = `$tst_awk '/PID.*Update process/{print $2}' checkhealthINST2_2.out`
echo "# Kill the update process on INST2"
if !( $?dont_kill_updproc2 ) then
	$MSR RUN INST2 "set msr_dont_trace ; $kill9 $updprocpid"
	$MSR RUN INST2 '$MUPIP replicate -receiver -start -updateonly' >&! INST2_restart_updprocess_2.out
endif
# A few upates
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 50'
# =========== Test case (2) end ===========

# =========== Test case (3) begin ===========
# Start only the receiver side
setenv portno_13 `$MSR RUN INST3 'set msr_dont_trace;source $gtm_tst/com/portno_acquire.csh'`
$MSR RUN INST3 '$MUPIP replic -instance_create -name=$gtm_test_cur_pri_name; $gtm_tst/com/jnl_on.csh $test_jnldir -replic=on'
$MSR RUN RCV=INST3 '$MUPIP replic -source -start -passive -log=passive_source.log -buf=1 -instsecondary=INSTANCE1'
$MSR RUN RCV=INST3 'set msr_dont_trace ; $MUPIP replic -receiv -start -listen='$portno_13' -log=RCVR_INST1_INST3.log -buf=$tst_buffsize'
# Get the pid of update process on the secondary and kill/restart it
$MSR RUN INST3 '$MUPIP replic -receiver -checkhealth ' >&! checkhealthINST3_1.out
set updprocpid = `$tst_awk '/PID.*Update process/{print $2}' checkhealthINST3_1.out`
echo "# Kill the update process on INST3"
if !( $?dont_kill_updproc3 ) then
	$MSR RUN INST3 "set msr_dont_trace ; $kill9 $updprocpid"
endif
# Start the source side and do updates
$MSR RUN SRC=INST1 RCV=INST3 'set msr_dont_trace ; $MUPIP replic -source -start -secondary=__RCV_HOST__:'$portno_13' -buff=$tst_buffsize -log=SRC_INST1_INST3.log -instsecondary=__RCV_INSTNAME__'
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 50'
# Now start the update process only
if !( $?dont_kill_updproc3 ) then
	$MSR RUN INST3 '$MUPIP replicate -receiver -start -updateonly' >&! INST3_restart_updprocess.out
endif
# And a few more updates
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 50'
# =========== Test case (3) end ===========

# Since the framework is manually hacked to introduce prior versions at the remote sides, regular framework commands like MSR SYNC or MSR STOP won't work
$MSR RUN SRC=INST1 RCV=INST2 '$gtm_tst/com/wait_until_src_backlog_below.csh 0'
$MSR RUN SRC=INST1 RCV=INST3 '$gtm_tst/com/wait_until_src_backlog_below.csh 0'
$MSR RUN RCV=INST2 SRC=INST1 '$gtm_tst/com/wait_until_rcvr_backlog_clear.csh'
$MSR RUN RCV=INST3 SRC=INST1 '$gtm_tst/com/wait_until_rcvr_backlog_clear.csh'
$MSR RUN RCV=INST2 SRC=INST1 '$MUPIP replic -receiv -shutdown -timeout=0 > SHUT_receiver.log ; $MUPIP replic -source -instsecondary=__SRC_INSTNAME__ -shutdown -timeout=0 > SHUT_passivesource.log'
$MSR RUN RCV=INST3 SRC=INST1 '$MUPIP replic -receiv -shutdown -timeout=0 > SHUT_receiver.log ; $MUPIP replic -source -instsecondary=__SRC_INSTNAME__ -shutdown -timeout=0 > SHUT_passivesource.log'
$MSR RUN SRC=INST1 RCV=INST3 '$MUPIP replic -source -shut -timeout=0 -instsecondary=__RCV_INSTNAME__ >&! SHUT_SRC_INST1_INST3.log'
$MSR RUN INST3 "set msr_dont_trace ; source $gtm_tst/com/portno_release.csh $portno_13"

$gtm_tst/com/dbcheck.csh -extract >&! dbcheck_output.out
sed 's|/'$prior_ver2'/|/##FILTERED##PRIORVER##/|' dbcheck_output.out | sed 's|/'$prior_ver3'/|/##FILTERED##PRIORVER##/|'
# msr_instance_config.txt was hacked above to change remote_ver and remote_image to pro. The hacked msr_instance_config.txt is sourced by submit_subtest.csh as part of error catching mechanism
# due to this sourcing, in -multisite scenario, the priorver which is set here as remote_ver spills over to the next subtest too
# so put back the original msr_instance_config.txt
mv ${ins_file} ${ins_file}_used_by_test
mv ${ins_file}_bak $ins_file
