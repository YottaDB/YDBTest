#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
if ("dbg" == $tst_image) then
	echo "TEST-E-IMAGE. This test should be run only in pro or bta"
	exit 1
endif
setenv gtm_test_jnl NON_SETJNL
# This test does backward recovery (and before image journaling) which is not suppored by MM access method. Force BG access method
source $gtm_tst/com/gtm_test_setbgaccess.csh

if !($?gtm_test_replay) then
	@ gtm7294todo = `$gtm_exe/mumps -run rand 3`
	echo "setenv gtm7294todo $gtm7294todo"	>>&! settings.csh
	setenv gtm_error_on_jnl_file_lost `$gtm_exe/mumps -run rand 2`
	echo "setenv gtm_error_on_jnl_file_lost $gtm_error_on_jnl_file_lost"	>>&! settings.csh
endif

# Randomly decide to do
# 0) 20000 updates and cause a.mjl to go into WAS_ON state because 3Mb space is not enough
# 1) 10000 updates : GT.M will be able to play updates into a.mjl but during rollback, there will be little room left and since rollback replays almost all of those journal records
# 2) 10000 updates and remove write permission to the journal directory just before rollback. It should exit with proper error message. But once the permission is set properly, a second attempt should work fine

# $gtm_com/IGS has option to MOUNT tmpfs only on linux systems.
if ("linux" != $gtm_test_osname) then
	set gtm7294todo = 2
endif
if (0 == $gtm7294todo) then
	set numupdates = 20000
	set expected_errors = "YDB-E-REPLSTATEOFF YDB-E-MUNOACTION"
	if ($gtm_error_on_jnl_file_lost) then
		# with gtm_error_on_jnl_file_lost, when GT.M processes updating the journals runs out of space a runtime error is issued (instead of turning-off journaling)
		set check_runtime_error = "YDB-E-JNLEXTEND YDB-E-NOSPACEEXT"
		# Which means, rollback will not issue YDB-E-REPLSTATEOFF. It will issue SYSTEM-E-ENO28 (like case (1) below)
		set expected_errors = "YDB-E-JNLACCESS SYSTEM-E-ENO28 YDB-E-MUNOACTION"
	endif
	# If gtm_test_freeze_on_error is turned on, the instance will be frozen due to DSKNOSPCAVAIL.
	# The test intends to check for the right errors and not freeze with DSKNOSPCAVAIL. So turn of gtm_test_freeze_on_error
	setenv gtm_test_freeze_on_error 0
else if (1 == $gtm7294todo) then
	set numupdates = 10000
	set expected_errors = "YDB-E-JNLACCESS SYSTEM-E-ENO28 YDB-E-MUNOACTION"
else if (2 == $gtm7294todo) then
	set numupdates = 10000
	set expected_errors = "GTM-W-JNLCRESTATUS SYSTEM-E-ENO13 YDB-E-JNLNOCREATE YDB-E-MUNOACTION"
endif

$gtm_tst/com/dbcreate.csh mumps 2
if !($?gtm_repl_instance) setenv gtm_repl_instance mumps.repl
set jnldir7294 = "../testfiles/gtm7294_jnlextlowspace"
mkdir $jnldir7294
if (1 >= $gtm7294todo) then
	$gtm_com/IGS MOUNT $jnldir7294 3248
	if ($status) then
		echo "Mounting tmpfs failed. Exiting test now"
		exit 1
	endif
	echo "$gtm_com/IGS UMOUNT testfiles/gtm7294_jnlextlowspace" >>& ../cleanup.csh
endif

$MUPIP replicate -instance -name=INSTA $gtm_test_qdbrundown_parms
# mupip journal rollback requires before image journaling
$MUPIP set -replic=on -journal=enable,on,before,file=$jnldir7294/a.mjl -reg AREG >&! AREG_jnl_on.out
if ($status) then
	echo "enabling journaling for region AREG failed. Check AREG_jnl_on.out. Exiting test now"
	exit 1
endif
$grep GTM-I-REPLSTATE AREG_jnl_on.out

$MUPIP set -replic=on -reg DEFAULT >&! DEFAULT_replic_on.out
if ($status) then
	echo "enabling replic for region DEFAULT failed. Check DEFAULT_replic_on.out. Exiting test now"
	exit 1
endif
$grep GTM-I-REPLSTATE DEFAULT_replic_on.out

source $gtm_tst/com/portno_acquire.csh > portno.out
@ port = `cat portno.out`
$MUPIP replic -source -start -secondary=${HOST}:$port -log=source.log -buf=1 -instsecondary=INSTB
echo "# Do updates and kill the GT.M process"
$GTM <<  GTM_EOF >&! gtm_updates.out
	f i=1:1:$numupdates  set ^a(i)=\$j(i,200)  set ^b(i)=\$j(i,200) set ^x(i)=\$j(i,200)
	zsystem "$kill9 "_\$j
GTM_EOF

echo "# Crash Now"
setenv PRI_SIDE `pwd`
$gtm_tst/com/primary_crash.csh
if (2 == $gtm7294todo) chmod u-w $jnldir7294
# Below backward rollback invocation is expected to fail. Therefore pass "-backward" explicitly to mupip_rollback.csh
# (and avoid implicit "-forward" rollback invocation that would otherwise happen by default).
$gtm_tst/com/mupip_rollback.csh -backward -lost=x.lost "*" >&! jnl_rollback.out
$gtm_tst/com/check_error_exist.csh jnl_rollback.out $expected_errors >&! expected_errors.outx
if ($status) then
	echo "The expected errors $expected_errors did not occur. Check expected_errors.outx"
else
	set subtestpass = 1
	echo "TEST-I-PASS. The expected errors did appear when journal rollback was attempted with insufficient disk space or permission"
endif

if ($?check_runtime_error) then
	# This means gtm_error_on_jnl_file_lost + case 0 : runtime error will be issued, filter it out"
	$gtm_tst/com/check_error_exist.csh gtm_updates.out $check_runtime_error >&! expected_runtime_errors.outx
	if ($status) then
		unset subtestpass
		echo "With gtm_error_on_jnl_file_lost, test case 0 expected GT.M runtime errors, but not seen. Check gtm_updates.out"
	endif
endif

if ( 2 == $gtm7294todo) then
	chmod u+w $jnldir7294
	# See mrep <GTM_7291_test_failures> for why "-backward" is needed below.
	$gtm_tst/com/mupip_rollback.csh -backward -lost=x.lost "*" >&! jnl_rollback_2.out
	if ($status) then
		echo "JNL-E-FAILED. Even after fixing the directory permissions journal rollback failed. Check jnl_rollback_2.out"
	endif
else if ($?subtestpass) then
	# If the test passed for 0 and 1, unmount right now and remove the unmount command from cleanup.csh
	$gtm_com/IGS UMOUNT $jnldir7294
	$grep -v "UMOUNT" ../cleanup.csh >&! ../cleanup.csh.bak
	mv ../cleanup.csh.bak ../cleanup.csh
endif

$gtm_tst/com/portno_release.csh

# dbcheck not done as for cases 0 and 1 there will be database corruption due to the crash and the rollback did not succeed
if ( 2 == $gtm7294todo) $gtm_tst/com/dbcheck.csh >&! dbcheck.out
