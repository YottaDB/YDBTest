#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# test that database backed up by online backup does not have integrity errors

$gtm_tst/com/dbcreate.csh mumps 1 255 480 512 1000 64 # create database with block-size=1024, global-buffers=64
$MUPIP set -journal="enable,off" -reg "*"
if ("ENCRYPT" == $test_encryption) then
	sed 's/mumps\.dat/backup.dat/' $gtm_dbkeys > ${gtm_dbkeys}.all
	cat $gtm_dbkeys >> ${gtm_dbkeys}.all
	$gtm_dist/mumps -run CONVDBKEYS ${gtm_dbkeys}.all gtmcrypt.cfg.all
	mv $gtmcrypt_config ${gtmcrypt_config}.orig
	sed "s|##GTM_TST##|$gtm_tst|" gtmtls.cfg >&! $gtmcrypt_config
	cat ${gtmcrypt_config}.all >>&! $gtmcrypt_config
endif

# start four GT.M processes that update the database in an alternate pattern of sets and kills
$GTM << GTM_EOF
	set numjobs=4	; spawn off 4 children each of them doing updates
	do start^d001911
GTM_EOF

# do online backups once every second with varying journal state of the database
@ num = 1
while ($num < 11)
	@ count = 0
	foreach action ("on,nobefore" "on,before" "off")
		echo "Iteration number $num : With Journaling ""$action"""
		echo "	MUPIP backup DEFAULT backup.dat"
		$MUPIP backup -dbg DEFAULT backup.dat >& mupip_backup.log.$num.$count
		set exit_status = $status
		if ($exit_status != 0) then
			break
		endif
		echo "	MUPIP integ backup.dat"
		$MUPIP integ backup.dat >& mupip_integ.log.$num.$count
		set exit_status = $status
		if ($exit_status != 0) then
			$MUPIP integ backup.dat
			break
		endif
		rm backup.dat
		echo "	MUPIP set -journal=""$action"" -reg ""*"""
		$MUPIP set -journal="$action" -reg "*" >& mupip_set_journal.log.$num.$count
		set exit_status = $status
		if ($exit_status != 0) then
			break
		endif
		sleep 1
		@ count = $count + 1
	end
	if ($exit_status != 0) then
		break
	endif
	@ num = $num + 1
end

# stop the four GT.M processes
$GTM << GTM_EOF
	do stop^d001911
GTM_EOF

$gtm_tst/com/dbcheck.csh
