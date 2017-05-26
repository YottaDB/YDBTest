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
# dbshmmismatch1 : If backup.dat points back to a shared memory id which in turn points back to mumps.dat,
#	 	   a mupip rundown of backup.dat should NOT touch shared memory as they do not correspond
#		   to each other. But in V54002, it actually runs down the shared memory.
#

@ section = 0
set echoline = "echo ---------------------------------------------------------------------------------------"

alias BEGIN "source $gtm_tst/com/BEGIN.csh"
alias END "source $gtm_tst/com/END.csh"

#TEST BEGINS#

BEGIN "Choose randomly between -reg OR -file qualifier"
        @ choice = `$gtm_exe/mumps -run rand 2`
END

BEGIN "Create backup.dat and mumps.dat database:"
$gtm_tst/com/dbcreate.csh backup 1
mv backup.dat backup.dat.orig
$gtm_tst/com/dbcreate.csh mumps 1
mv backup.dat.orig backup.dat

END

BEGIN "Access mumps.dat and crash it:"
# at this point, gtmgbldir points to mumps.gld
$GTM << GTM_EOF
	write "set ^x=1"
        set ^x=1
	zsy "dse all -buff"
        zsy "$kill9 "_\$j
GTM_EOF
END

#Make database file backup.dat to point to shared memory which in turn points to mumps.dat
echo
setenv gtmgbldir backup.gld
cp mumps.dat backup.dat

BEGIN "Issue REQRUNDOWN message with a DBSHMNAMEDIFF secondary error:"
$GTM << GTM_EOF
	write "write ^x"
	write ^x
GTM_EOF
END

BEGIN "Do mupip rundown on backup.dat. This should not touch shared memory as it is not related to backup.dat:"
$MUPIP rundown -reg "*"
END

#Do mupip rundown of backup.dat again and it should be fine.
#Then we should try GT.M and it should run fine without issues.
BEGIN "Do mupip rundown on backup.dat again and it should be fine. Accesss to backup.dat should also be fine:"
$MUPIP rundown -reg "*"
$GTM << GTM_EOF
	write "set ^y=1"
	set ^y=1
GTM_EOF
END

#We should then switch .gld to mumps.gld and then access GT.M.
BEGIN "Switch to mumps.dat and access it. It should access successfully."
setenv gtmgbldir mumps.gld
$GTM << GTM_EOF
	write "write ^x"
	write ^x
GTM_EOF
END

BEGIN "Mupip rundown on mumps.dat and access GT.M and that should be fine:"
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
if ( $choice == 0 ) then
        echo 'mupip rundown -reg "*"'
        $MUPIP rundown -reg "*"
else
        echo 'mupip rundown -file mumps.dat'
        $MUPIP rundown -file mumps.dat
endif

$GTM << GTM_EOF
	write "write ^x"
	write ^x
	write "clean database access"
GTM_EOF
END

$gtm_tst/com/dbcheck.csh
