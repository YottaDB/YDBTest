#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# idbidmismatch2 : Exercise DBIDMISMATCH error in argumentless "mupip rundown"

@ section = 0
set echoline = "echo ---------------------------------------------------------------------------------------"

alias BEGIN "source $gtm_tst/com/BEGIN.csh"
alias END "source $gtm_tst/com/END.csh"

#TEST BEGINS#

BEGIN "Create backup.dat and mumps.dat"
$gtm_tst/com/dbcreate.csh backup 1
mv backup.dat backup.dat.orig
$gtm_tst/com/dbcreate.csh mumps 1
mv backup.dat.orig backup.dat
END

BEGIN "Access mumps.dat and crash it"
# at this point, gtmgbldir points to mumps.gld
$GTM << GTM_EOF
        set ^x=1
	zsy "dse all -buff"
        zsy "$kill9 "_\$j
GTM_EOF
END

#Get the shmid for crashed database
set shmid = `$gtm_exe/mupip ftok mumps.dat |& $tst_awk '/mumps/ {print $6}'`

BEGIN "Switch to backup.dat and access database. It should issue DBIDMISMATCH error"
# switch to backup.gld
cp mumps.dat backup.dat
mv backup.dat mumps.dat

$GTM << GTM_EOF
        set ^x=1
GTM_EOF
END

BEGIN "Issue MUPIP RUNDOWN and verify that shared memory is removed"
$MUPIP rundown >&! rundown.txt
$grep " id $shmid " rundown.txt >&! rundown.outx
if (! $status) then
	echo "Shared Memory Removed successdully"
endif
END

BEGIN "This database access should be clean"
$GTM << GTM_EOF
	write "set ^x=1"
        set ^x=1
	write "Clean database access"
GTM_EOF
END

$gtm_tst/com/dbcheck.csh
