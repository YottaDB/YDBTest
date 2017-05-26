#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
set pidfile = "truncate_oscillator_parent.pid"
set oscfile = "OSCILLATOR.TXT_$$"
set oscend = "OSCILLATOR.END"

echo "===== BEGIN ALTERNATING TRUNCATES AND EXTENDS ====="
echo "PID  ""$$"
echo "PID  ""$$" >>& $pidfile
\touch $oscfile

@ cnt = 0
while (1)
	@ cnt = $cnt + 1
	if (-f "$oscend") then
		break
        else
		echo "===== $cnt ====="
		$MUPIP extend -bl=10 DEFAULT
		$MUPIP reorg -truncate
		$MUPIP extend -bl=10 DEFAULT
		$gtm_exe/mumps -run %XCMD 'hang .001'
   	endif
end
echo "===== END ALTERNATING TRUNCATES AND EXTENDS ====="
\rm -f $oscfile
