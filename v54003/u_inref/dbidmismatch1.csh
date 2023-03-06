#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# dbidmismatch1 : Exercise DBIDMISMATCH error in "mupip rundown -reg *"
#

@ section = 0
set echoline = "echo ---------------------------------------------------------------------------------------"

alias BEGIN "source $gtm_tst/com/BEGIN.csh"
alias END "source $gtm_tst/com/END.csh"

#TEST BEGINS#
BEGIN "Choose randomly between -reg OR -file qualifier"
        @ choice = `$gtm_exe/mumps -run rand 2`
END

BEGIN "Create backup.dat and mumps.dat"
$gtm_tst/com/dbcreate.csh backup 1
mv backup.dat backup.dat.orig
$gtm_tst/com/dbcreate.csh mumps 1
mv backup.dat.orig backup.dat
END

BEGIN "Access mumps.dat and crash it"
# at this point, gtmgbldir points to mumps.gld
$GTM << GTM_EOF
	write "set ^x=1"
        set ^x=1
	zsy "dse all -buff"
        zsy "$kill9 "_\$j
GTM_EOF
END

BEGIN "get the ftok semid for mumps.dat. Then switch to backup.dat and access database. It should issue DBIDMISMATCH error"
set ftok_key = `$MUPIP ftok mumps.dat |& $grep mumps | $tst_awk '{print substr($10, 2, 10);}'`
set ftok_id = `$gtm_tst/com/ipcs -a | $grep $ftok_key | $tst_awk '{print $2}'`

# switch to backup.gld
cp mumps.dat backup.dat
mv backup.dat mumps.dat
$GTM << GTM_EOF
	write "set ^y=1"
        set ^y=1
GTM_EOF
END

BEGIN "Do MUPIP RUNDOWN and acccess database. This database access should be clean"
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
	write "clean database access"
GTM_EOF
END

BEGIN  "Remove leftover ftok semaphore"
echo "ftok id="$ftok_id
$gtm_tst/com/ipcrm -s $ftok_id
END

$gtm_tst/com/dbcheck.csh
