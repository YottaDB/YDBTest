#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# dbshmmismatch2: If backup.dat points back to a shared memory id which in turn points back to mumps.dat,
#                 a mupip rundown of backup.dat should NOT touch shared memory as they do not correspond
#                 to each other irrespective of whether processes are accessing mumps.dat or not

@ section = 0
set echoline = "echo ---------------------------------------------------------------------------------------"

alias BEGIN "source $gtm_tst/com/BEGIN.csh"
alias END "source $gtm_tst/com/END.csh"

#TEST BEGINS#

BEGIN "Create backup.dat and mumps.dat database:"
foreach dbname (backup mumps)
	setenv ydb_gbldir $dbname.gld
	$GDE << GDE_EOF
	change -segment DEFAULT -file=$dbname.dat
GDE_EOF
	$MUPIP create
end
END

cat <<CAT_EOF >&! backup.m
backup	;
	set ^x=1
CAT_EOF

BEGIN "Do MUPIP RUNDOWN on backup.dat while mumps.dat is still accessing shared memory:"

cat <<_RUNDOWN_ >&! muprndwn.csh
# point backup.dat database to same share memory which mumps.dat will be accessing
setenv ydb_gbldir backup.gld
cp mumps.dat backup.dat
# issue MUPIP RUNDOWN required message
/$gtm_exe/mumps -run backup
\$MUPIP rundown -reg "*"
_RUNDOWN_

setenv ydb_gbldir mumps.gld
$GTM << GTM_EOF
	write "set ^m=1"
        set ^m=1
        zsy "tcsh muprndwn.csh"
	write "set ^n=1"
	set ^n=1	; test that shared memory was NOT removed by mupip rundown in previous step
GTM_EOF
END

BEGIN "Access to backup.dat should be fine:"
setenv ydb_gbldir mumps.gld
$GTM << GTM_EOF
	write "set ^b=1"
        set ^b=1
GTM_EOF
END

BEGIN "Access to mumps.dat should be fine:"
setenv ydb_gbldir mumps.gld
$GTM << GTM_EOF
	write "write ^m"
        write ^m
GTM_EOF
END
