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
#########################
\touch NOT_DONE.BACKUP
setenv baktmpdir `pwd`"/backtmpdir"
if ($?test_in_utf8mode) then
	setenv baktmpdir `pwd`"/ƐƑƟ一丄下丕丢串久"
endif
mkdir $baktmpdir
setenv GTM_BAKTMDIR $baktmpdir
$gtm_tst/com/backup_dbjnl.csh $bkupdir1 "*.gld" cp nozip
$gtm_tst/com/backup_dbjnl.csh $bkupdir2 "*.gld" cp nozip
$GTM << aaa
for  hang 1  quit:\$GET(^lasti(2,^instance))>2
for  hang 1  quit:\$GET(^lasti(3,^instance))>2
for  hang 1  quit:\$GET(^lasti(4,^instance))>2
aaa
echo "===== BEGIN ONLINE BACKUP at `date`====="
#########################
@ backup_succeeded = 0
set baklogfile = online1_back.out
$MUPIP backup -on "*" $bkupdir1 -replinstance=backup1 -dbg >&! $baklogfile
set ret = $status
echo "MUPIP BACKUP return status = $ret" >>&! online1_loop.out
$DSE all -dump -all >>&! online1_loop.out	# get dse dump of ALL regions in one command
# We used to see BACKUP2MANYKILL errors from MUPIP BACKUP occasionally in this test and had instituted a scheme
# to work around this by repeating the backup. As part of the changes to C9G04-002783, mupip backup no longer
# issues the BACKUP2MANYKILL error but instead issues a BACKUPKILLIP warning and proceeds. In addition it inhibits
# future kills during the time it waits for kill-in-progress to become 0. Therefore we dont expect BACKUPKILLIP messages
# in this test. If ever we see it in future testing, we need to use a scheme (similar to the previously handled
# BACKUP2MANYKILL errors) to handle it.
if (0 == $ret) then
	cat $baklogfile
	echo "Backup finished successfully"
	@ backup_succeeded = 1
	echo "---------------- Online Backup finished successfully at `date` ----------------- " >>&! online1_loop.out
else
	echo "ONLINEBACK-E-EXITSTATUS1 : backup exit status = $status"
endif
if ("$1" == "PRI") then
	set creg="CREG"
	set breg="BREG"
else
	set creg="REGIONHASLONGNAME9012345678901C"
	set breg="REGIONHASLONGNAME9012345678901B"
endif
$DSE << aaa >>& reserve.out
find -REG=$creg
ch -file -reserved_bytes=16
find -REG=$breg
ch -file -reserved_bytes=128
quit
aaa

#
# This should be done only if backup_succeeded
#
if (1 == $backup_succeeded) then
	#
	# Note this is changing directory to backed up database and no integ error should be there
	#
	# Set gtmcrypt_config environment variable to make sure that path of gtmcrypt_config is consistent through out the test run"
	if ("ENCRYPT" == $test_encryption) then
		# The below assumes $gtmcrypt_config is set to just gtmcrypt.cfg (without the path)
		set echo ; set verbose
		sed 's|dat: "'$cwd'/|dat: "|' $gtmcrypt_config >&! $bkupdir1/$gtmcrypt_config
	endif
	cd $bkupdir1
	### $gtm_tst/com/dbcheck_base.csh -nosprgde
	echo "ipcs output before integ:"
	echo "========================="
	# At this point, gtm_repl_instance is set to mumps.repl. Since bkupdir1 doesn't have mumps.repl, the INTEG below will error
	# out with FTOKERR if $gtm_custom_errors is set (causing it to open jnlpool). Since the backup databases are not tied to any
	# replication instance, unsetenv gtm_repl_instance.
	unsetenv gtm_repl_instance
	$MUPIP integ -reg -noonline "*"
	setenv gtm_repl_instance mumps.repl
	if ($status) then
		$gtm_tst/com/ipcs -a
	endif
	#
	# Change directory to source directory of backup
	#
	cd ..
else
	echo "TEST-E-BACKUP First BACKUP TEST FAILED at `date`"
endif
#########################
$GTM << aaa
for  hang 1  quit:\$GET(^lasti(2,^instance))>8
for  hang 1  quit:\$GET(^lasti(3,^instance))>8
for  hang 1  quit:\$GET(^lasti(4,^instance))>8
aaa
echo "===== BEGIN INCREMENTAL BACKUP at `date` ====="
$MUPIP freeze -on "*"
set baklogfile = online2_back.out
$MUPIP backup -on -i "*" $bkupdir2 -dbg >&! $baklogfile
set ret = $status
echo "MUPIP BACKUP -INCREMENTAL return status = $ret" >>&! online2_loop.out
$DSE all -dump -all >>&! online2_loop.out	# get dse dump of ALL regions in one command
$MUPIP freeze -off "*"
if (0 == $ret) then
	cat $baklogfile
	echo "Incremental backup finished successfully"
	echo "---------------- Incremental Backup finished successfully at `date` -------------- " >>&! online2_loop.out
else
	echo "ONLINEBACK-E-EXITSTATUS2 : backup exit status = $status"
endif
########################
#
\rm -f NOT_DONE.BACKUP
