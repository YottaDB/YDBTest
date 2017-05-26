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

# Replication possibilities
# 1) V62001 -> V62000 : works fine with or without trigger definition updates being replicated
# 2) V62000 -> V62001 : works fine with or without trigger definition updates being replicated
#
# 3) V62001 -> (V51000 thru V53004A) : works fine with or without trigger definition updates being replicated
# 		This is because V51000 thru V53004A does not support triggers.
#
# 4) V62001 -> (V54000 thru V61000)  : works fine as long as trigger definition updates are not replicated
#                                    : errors out if trigger definition updates are replicated
# 5) (V54000 thru V61000) --> V62001 : works fine as long as trigger definition updates are not replicated
#                                    : errors out if trigger definition updates are replicated

# 3) is tested by trig2notrig subtest. do the others here

# Disabled settings that do not work with MSR and prior versions
source $gtm_tst/com/disable_settings_msr_priorver.csh

alias knownerror 'mv \!:1 {\!:1}x ; $grep -vE "\!:2" {\!:1}x >&! \!:1 '
# prepare local and remote directories
$MULTISITE_REPLIC_PREPARE 7

# pv1 = randomly pick a version V54000 thru V61000
# pv2 = V62000
set ver_V62000 = `$gtm_tst/com/random_ver.csh -gte V62000 -lte V62000`
set ver_rand   = `$gtm_tst/com/random_ver.csh -gte V54000 -lte V61000`
if ( ("${ver_V62000}" =~ "*-E-*") || ("${ver_V62000}" =~ "*-E-*") ) then
	echo "Picking one of the prior versions failed : $ver_V62000 ; $ver_rand"
	exit 1
endif

cp msr_instance_config.txt msr_instance_config.bak1
$tst_awk '{	\
  if("INST2" == $1){if("VERSION:" == $2){sub("'$tst_ver'","'$ver_V62000'")};if("IMAGE:" == $2){sub("dbg","pro")}}; \
  if("INST3" == $1){if("VERSION:" == $2){sub("'$tst_ver'","'$ver_rand'")};  if("IMAGE:" == $2){sub("dbg","pro")}}; \
  if("INST4" == $1){if("VERSION:" == $2){sub("'$tst_ver'","'$ver_V62000'")};if("IMAGE:" == $2){sub("dbg","pro")}}; \
  if("INST6" == $1){if("VERSION:" == $2){sub("'$tst_ver'","'$ver_rand'")};  if("IMAGE:" == $2){sub("dbg","pro")}}; \
  print}' msr_instance_config.bak1 >&! msr_instance_config.txt

$MULTISITE_REPLIC_ENV

$gtm_tst/com/dbcreate.csh mumps 3 >&! dbcreate_testout.out

foreach name (a b c)
	echo '+^'${name}'(subs=:)   -command=S -xecute="set ^'${name}'trigged(subs)=$ztval"' >&! $name.trg
end

# 1) V62001 -> V62000 : works fine with or without trigger definition updates being replicated
$MSR START INST1 INST2
# 4) V62001 -> (V54000 thru V61000)  : works fine as long as trigger definition updates are not replicated
$MSR START INST1 INST3
get_msrtime
$gtm_exe/mumps -run %XCMD 'set ^a(1)=1'
$MSR SYNC INST1 INST3
# SRC of INST1-INST3 should fail with REPLNOHASHTREC while attempting to replicate a trigger
$MUPIP trigger -triggerfile=a.trg
$gtm_tst/com/wait_for_log.csh -log SRC_${time_msr}.log -message REPLNOHASHTREC
$gtm_tst/com/check_error_exist.csh SRC_${time_msr}.log REPLNOHASHTREC
$gtm_tst/com/wait_until_srvr_exit.csh src INSTANCE3
$MSR REFRESHLINK INST1 INST3
$MSR STOP INST1 INST2
$MSR STOPRCV INST1 INST3

# 2) V62000 -> V62001 : works fine with or without trigger definition updates being replicated
$MSR RUN SRC=INST1 RCV=INST4 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/b.trg _REMOTEINFO___RCV_DIR__/'
$MSR START INST4 INST5
$MSR RUN INST4 '$MUPIP trigger -triggerfile=b.trg'
$MSR RUN INST4 '$gtm_exe/mumps -run %XCMD "set ^b(1)=1"'
$MSR SYNC INST4 INST5
$MSR RUN INST5 '$gtm_exe/mumps -run %XCMD "zwrite ^?.E"'
$MSR STOP INST4 INST5

# 5) (V54000 thru V61000) --> V62001 : works fine as long as trigger definition updates are not replicated
$MSR RUN SRC=INST1 RCV=INST6 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/c.trg _REMOTEINFO___RCV_DIR__/'
$MSR START INST6 INST7
get_msrtime
# As long as a trigger is not installed INST6 INST7 should be working fine
$MSR RUN INST6 '$gtm_exe/mumps -run %XCMD "set ^c(1)=1"'
$MSR SYNC INST6 INST7
$MSR RUN INST7 '$gtm_exe/mumps -run %XCMD "zwrite ^?.E"'
# RCVR of INST6-INST7 should fail with REPLNOHASHTREC while attempting to replicate a trigger
# Trigger load output is different across versions (pre and post V54002)
$MSR RUN INST6 '$MUPIP trigger -triggerfile=c.trg >& load_ctrig.out'
$MSR RUN INST7 "$gtm_tst/com/wait_for_log.csh -log RCVR_${time_msr}.log -message REPLNOHASHTREC"
$MSR RUN INST7 "set msr_dont_chk_stat ; $gtm_tst/com/check_error_exist.csh RCVR_${time_msr}.log REPLNOHASHTREC"
knownerror $msr_execute_last_out GTM-E-REPLNOHASHTREC
echo "# The receiver would have exited with the above error. Manually shutdown the update process and passive server"
$MSR RUN INST7 'set msr_dont_chk_stat ;$MUPIP replic -receiver -shutdown -timeout=0 >&! updateproc_shut.out'
$MSR RUN INST7 '$MUPIP replic -source -shutdown -timeout=0 >&! passive_shut.out'
$MSR REFRESHLINK INST6 INST7
$MSR STOPSRC INST6 INST7
$MSR RUN INST7 'set msr_dont_trace ; source $gtm_tst/com/portno_release.csh'

$gtm_tst/com/dbcheck.csh >&! dbcheck_testout.out
