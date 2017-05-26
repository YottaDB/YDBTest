#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# mprndwnnoarg: Test argumentless mupip rundown behavior.
#		If there are TWO shared memory segments both of which point to the SAME db file name,
#		and one of them is actively being used, argumentless mupip rundown should clean up
#		the shared memory segment that no longer corresponds back to the db file name

@ section = 0
set echoline = "echo ---------------------------------------------------------------------------------------"

alias BEGIN "source $gtm_tst/com/BEGIN.csh"
alias END "source $gtm_tst/com/END.csh"

#TEST BEGINS#

BEGIN "Choose randomly between -reg OR -file qualifier"
        @ choice = `$gtm_exe/mumps -run rand 2`
END

BEGIN "create database mumps.dat:"
$gtm_tst/com/dbcreate.csh mumps 1
END

set syslog_before = `date +"%b %e %H:%M:%S"`

BEGIN "Access the database(hence create the shared memory) and crash the database"
# gtmgbldir points to mumps.gld
$GTM << GTM_EOF
write "set ^x=1"
set ^x=1
zsy "dse all -buff"
zsy "$kill9 "_\$j
GTM_EOF
END

BEGIN "Do argumentless MUPIP RUNDOWN while two shared memory points to same db file name"
echo "test that active shared memory is not rundown"
mv mumps.dat old_mumps.dat
$MUPIP create
$GTM << GTM_EOF
write "set ^x=11"
set ^x=11
zsy "mupip rundown >&! rundown.txt"
write "set ^x=22"
set ^y=22 ; test that shared memory was NOT removed by mupip rundown in previous step
write "Shared memory is not removed by mupip rundown in previous command"
GTM_EOF
END

BEGIN "get the shmid for mumps.dat and old_mumps.dat and verfiy its validity"
@ old_shmid = `$gtm_exe/mupip ftok old_mumps.dat | $tst_awk '/mumps/ {print $6}'`
@ new_shmid = `$gtm_exe/mupip ftok mumps.dat | $tst_awk '/mumps/ {print $6}'`

if ( $old_shmid <= 0) then
	echo "Error: shmid of shared memory attached to old_mumps.dat is invalid"
endif

if ( $new_shmid != -1) then
	echo "Error: mumps.dat is not properly halted"
endif
END

BEGIN "Verify that shared memory corresponding to old_mumps.dat ($old_shmid) is removed"
$grep -E "SHMREMOVED.* id $old_shmid " rundown.txt
if ($status != 0) then
        echo "No SHMREMOVED message found for shmid = $old_shmid"
endif
$gtm_tst/com/ipcs -m | $tst_awk '{print $2}' | $grep -w $old_shmid
if (  $status == 0 ) then
        echo "ipcs -a output still shows shmid = $old_shmid existing"
endif
END

BEGIN "Verify that access to old_mumps.dat should issue MUPIP RUNDOWN required"
mv mumps.dat mumps.dat.bkup
mv old_mumps.dat mumps.dat

$GTM << GTM_EOF
write "set ^y=1"
s ^y=1
GTM_EOF
END

BEGIN "do MUPIP RUNDOWN on old_mumps.dat(now mumps.dat) and then access it. It should work fine"
if ( $choice == 0 ) then
        echo 'mupip rundown -reg "*"'
        $MUPIP rundown -reg "*"
else
        echo 'mupip rundown -file mumps.dat'
        $MUPIP rundown -file mumps.dat
endif

$GTM << GTM_EOF
write "set ^y=1"
s ^y=1
GTM_EOF
END

$gtm_tst/com/dbcheck.csh
