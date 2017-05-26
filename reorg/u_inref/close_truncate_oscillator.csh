#!/usr/local/bin/tcsh -f
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
set oscpat = "OSCILLATOR.TXT*"
set oscend = "OSCILLATOR.END"

echo "Signal truncate oscillator to exit"
\touch $oscend

# Wait for a maximum of 5 minutes
set timeout = 300
while ($timeout > 0)
	if (! -f $pidfile) then
		echo "Waiting for oscillator to start"
	else
		set nonomatch
		set oscfiles = $oscpat
		unset nonomatch
		if ("$oscfiles" == "$oscpat") then
			echo "$oscpat does not exist"
			echo "`date` : Test can end now"
			break
		else
			echo "Waiting for oscillator to exit"
		endif
        endif
	sleep 1
        @ timeout--
end
if ($timeout == 0) then
        echo "TEST-E-TIMEOUT : Timed out waiting for $oscpat to be removed. Please check the truncate/extend processes"
        \ls -ltr $pidfile $oscend $oscpat
        date
endif
