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
# dbnammismatch2:  Exercise DBNAMEMISMATCH error in mu_rndwn_file
#

@ section = 0
set echoline = "echo ---------------------------------------------------------------------------------------"

alias BEGIN "source $gtm_tst/com/BEGIN.csh"
alias END "source $gtm_tst/com/END.csh"

#TEST BEGINS#
BEGIN "Choose randomly between -reg OR -file qualifier"
        @ choice = `$gtm_exe/mumps -run rand 2`
END

mkdir tmp

BEGIN "create mumps.dat database in tmp directory"
cd tmp
$gtm_tst/com/dbcreate.csh mumps 1
END

BEGIN "access database mumps.dat and crash it"
# at this point, gtmgbldir points to mumps.gld
$GTM << GTM_EOF
        set ^x=1
	zsy "dse all -buff"
        zsy "kill -9 "_\$j	; BYPASSOK kill
GTM_EOF
END

# come out of tmp directory
cd ..


BEGIN "create backup.dat"
setenv gtmgbldir backup.gld
$gtm_tst/com/dbcreate.csh backup 1
cp tmp/mumps.dat backup.dat
END

# change the permission on tmp to issue permission denied error
chmod -x tmp
BEGIN  "try to access backup.dat database to trigger DBNAMEMISMATCH error"
setenv gtmgbldir backup.gld
$GTM << GTM_EOF
        set ^x=1
GTM_EOF

END

BEGIN  "Do MUPIP rundown on backup.dat and then access it. Database access should be clean"
if ( $choice == 0 ) then
        echo 'mupip rundown -reg "*"'
        $MUPIP rundown -reg "*"
else
        echo 'mupip rundown -file backup.dat'
        $MUPIP rundown -file backup.dat
endif

chmod +x tmp
$GTM << GTM_EOF
	write "set ^x=1"
        set ^x=1
	write "Clean database access"
GTM_EOF
END

BEGIN  "do mupip rundown on mumps.dat to remove leftover ipcs"
cd tmp
setenv gtmgbldir mumps.gld
echo 'mupip rundown -reg "*"'
$MUPIP rundown -reg "*"
END

$gtm_tst/com/dbcheck.csh
