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
# orphanshm: 	Test argumentless mupip rundown behavior.
#		If there is an orphaned shared memory segment pointing to a database file that has been since removed,
#		an argumentless rundown should clean up this shared memory segment.
#

@ section = 0
set echoline = "echo ---------------------------------------------------------------------------------------"

alias BEGIN "source $gtm_tst/com/BEGIN.csh"
alias END "source $gtm_tst/com/END.csh"

#TEST BEGINS#
BEGIN "Choose randomly between -reg OR -file qualifier"
        @ choice = `$gtm_exe/mumps -run rand 2`
END

BEGIN "Create database mumps.dat"
$gtm_tst/com/dbcreate.csh mumps 1
END

set syslog_before = `date +"%b %e %H:%M:%S"`

BEGIN "Access database mumps.dat(Hence create shared memory) and crash it"
# at this point, gtmgbldir points to mumps.gld
$GTM << GTM_EOF
	write "set ^x=1"
        set ^x=1
	zsy "dse all -buff"
        zsy "$kill9 "_\$j
GTM_EOF
END

#Get shmid for crashed databse, rename mumps.dat to old_mumps.dat and do argumentless MUPIP RUNDOWN
set old_shmid = `$gtm_exe/mupip ftok mumps.dat | $tst_awk '/mumps/ {print $6}'`
mv mumps.dat old_mumps.dat
$MUPIP rundown >&! rundown.txt

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

BEGIN "Verify that accessing old_mumps.dat, by renaming it to mumps.dat, gives MUPIP RUNDOWN required message"
mv old_mumps.dat mumps.dat
$GTM << GTM_EOF
	write "set ^y=1"
	set ^y=1
GTM_EOF
END

BEGIN "Verify that old_mumps.dat(now mumps.dat) can be accessed after doing mupip rundown"
if ( $choice == 0 ) then
        echo 'mupip rundown -reg "*"'
        $MUPIP rundown -reg "*"
else
        echo 'mupip rundown -file mumps.dat'
        $MUPIP rundown -file mumps.dat
endif
$GTM << GTM_EOF
	write "set ^y=1"
	set ^y=1
GTM_EOF
END

$gtm_tst/com/dbcheck.csh
