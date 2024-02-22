#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set todo = "$1"
switch ($todo)
case "picktest":
	set testname = "$2"
	set controlfile = "$3"
	set short_host = "$4"
	set gtm_tst = "$5"

	source $gtm_tst/com/set_specific.csh

	if !(-e $controlfile) touch $controlfile
	set picked = `$tst_awk '{if ($1 == "'$testname'") {print $3 ; exit}}' $controlfile`
	if ("" == "$picked") then
		# This test was not picked by other servers. Note down in the file that this test is being picked up
		set picked_time = `date +%Y%m%d_%H%M%S`
		echo "$testname $short_host $picked_time $$" | $tst_awk '{printf "%-19s : %-15s : %s : %6s\n",$1,$2,$3,$4}' >>&! $controlfile
		# Just in case two different servers executed the line to check for the test in controlfile at the same time,
		# Both of them would see it as unpicked and both would pick it up.
		# Lets check the control file once more to see if this server is the first host to pick, if not skip it
		set ppid = `grep -w $testname $controlfile | head -1 | $tst_awk '{print $7;}'`
		if ($ppid == $$) then
			echo $short_host
		else
			echo "_${picked}_"
		endif
	else
		# Append underscore to signal that this test was already picked (even if it is the same server)
		# This is to differentiate it from the plain $short_host name that would be returned if the test wasn't picked earlier
		echo "_${picked}_"
	endif
breaksw
case "donetest":
	set testname = "$2"
	set short_host = "$3"
	set log_line_stat = "$4"
	set donefile = "$5"
	set gtm_tst = "$6"
	source $gtm_tst/com/set_specific.csh
	set done_time = `date +%Y%m%d_%H%M%S`
	echo "$testname $short_host $log_line_stat $done_time" | $tst_awk '{printf "%-19s : %-15s : %6s : %s\n",$1,$2,$3,$4}' >>&! $donefile
breaksw
endsw
