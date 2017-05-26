#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2010, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# ztrig_nonull:
# Test $ztrigger on a line followed by another command.  Incorrect operation from
# $ztrigger could corrupt the next command.

$gtm_tst/com/dbcreate.csh mumps 1

# [GTM-7180] $ztrigger does not properly handle scenarios where the command is preceded by an extended reference
cp mumps.gld a.gld
echo '+^a   -command=SET -xecute="set lumps=1"' >&! a.trg

$gtm_exe/mumps -run %XCMD 'set x=$ztrigger("I","-*") kill ^a,^b,^c'

# Don't break up the following commands into separate lines to make them shorter.  The test needs to have
# multiple commands on the same line in order to make sure that $ztrigger is not setting a NULL into the
# string_pool - on a different string.

$GTM << EOF
	set tr=\$ztrigger("i","-*") set tr=\$ztrigger("i","+^a -command=set -xecute=""zsystem """" $gtm_exe/mumps -run %XCMD set ^c=101"""" set ^b=2"" ")
	set tr=\$ztrigger("i","+^a -command=set -xecute=""zsystem """" $gtm_exe/mumps -run %XCMD set ^c=101"""" set ^b=2"" ") kill ^a,^b,^c
	set tr=\$ztrigger("i","-*") set tr=\$ztrigger("i","+^a -command=set -xecute=""zsystem """" $gtm_exe/mumps -run %XCMD set ^c=101"""" set ^b=2"" ") kill ^a,^b,^c
	; GTM-7180 \$ztrigger preceded by an extended reference
	set ^|"a.gld"|b=2  set tr=\$ztrigger("i","+^a -command=set -xecute=""set a=1""")
	set ^|"a.gld"|b=3  set tr=\$ztrigger("file","a.trg")
EOF

$gtm_tst/com/dbcheck.csh -extract
