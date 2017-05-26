#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2007-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# C9D08-002392 Online backup has integrity errors in case wcs_recover() runs concurrently

# allocate more global buffers to reduce the chances of the test failing because secshr_db_clnup could not find a free buffer
$gtm_tst/com/dbcreate.csh mumps 5 -glo=4096

if ($?gtm_test_replay) then
	source $gtm_test_replay
else
	# Test with and without journaling. With replication will be tested in the stress test.
	@ jnlchoice = `$gtm_exe/mumps -run rand 2`
	echo "setenv jnlchoice $jnlchoice" >>&! settings.csh

	source $gtm_tst/com/wbox_test_prepare.csh "CACHE_RECOVER" 10000 100 settings.csh
		# sets env vars to enable white-box testing of cache recovery
endif

if ($jnlchoice == 0) then
	$MUPIP set $tst_jnl_str -region "*" >>&! jnl.log
endif

if ("ENCRYPT" == "$test_encryption" ) then
	mv $gtmcrypt_config ${gtmcrypt_config}.orig
	sed 's|dat: "'$cwd'/|dat: "|' ${gtmcrypt_config}.orig > $gtmcrypt_config
	setenv gtmcrypt_config $cwd/gtmcrypt.cfg
endif

$gtm_exe/mumps -run start^c002392

@ num = 1
echo " ------------------------------------------"
while ($num <= 10)
	set bakdir = "bak$num"
	mkdir $bakdir
	if ($tst_image == "pro") then
		$gtm_exe/mumps -run sleepshort^c002392	# random sleep in between backups
	else
		$gtm_exe/mumps -run sleeplong^c002392	# random sleep in between backups
	endif
	$MUPIP backup "*" $bakdir >& backup_$num.log
	# We used to see BACKUP2MANYKILL errors from MUPIP BACKUP occasionally in VMS in this test and had instituted a scheme
	# to work around this in the corresponding .com script. This had not been done in Unix since we had not yet seen the
	# error there. As part of the changes to C9G04-002783, mupip backup no longer issues the BACKUP2MANYKILL error but
	# instead issues a BACKUPKILLIP warning and proceeds. In addition it inhibits future kills during the time it waits
	# for kill-in-progress to become 0. Therefore we dont expect BACKUPKILLIP messages in the test. If ever we see it
	# in future testing, we need to use a scheme (similar to the previously handled BACKUP2MANYKILL errors) to handle it.
	cd $bakdir
	cp ../$gtmgbldir .
	$MUPIP integ -reg "*" >& ../backup_integ_$num.log
	set integ_status = $status
	cd ..
	if ($integ_status != 0) then
		echo " ===> MUPIP BACKUP : Iteration $num : FAILED <--"
		break
	else
		echo " ===> MUPIP BACKUP : Iteration $num : PASSED"
	endif
	@ num = $num + 1
end
echo " ------------------------------------------"
$gtm_exe/mumps -run stop^c002392

$gtm_tst/com/dbcheck.csh
