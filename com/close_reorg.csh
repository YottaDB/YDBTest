#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
set reorgpat = "REORG.TXT*"
set reorgend = "REORG.END"

echo "Stop REORG"
date
set nonomatch
set reorgfiles = $reorgpat
unset nonomatch
if ("$reorgfiles" == "$reorgpat") then
   echo "TEST-E-ONLINE_REORG : Online reorg is not executing"
   exit 1
endif
#
# Signal all reorg processes to exit
#
\touch $reorgend

# Wait for a maximum of 360 minutes (i.e. 21600 seconds) for active reorg process to exit.
# On the Pi-Zeros we have seen one reorg take 2 hours 20 minutes to finish in one case. Hence this huge timeout.
set timeout = 21600
while ($timeout > 0)
	set nonomatch
	set reorgfiles = $reorgpat
	unset nonomatch
	if ("$reorgfiles" == "$reorgpat") then
		echo "No $reorgpat files found"
		echo "`date` : All reorg processes has exited now"
		break
	else
		echo "`date` : Waiting for reorg processes to exit"
	endif
	sleep 1
	@ timeout = $timeout - 1
end
if ($timeout == 0) then
	echo "TEST-E-TIMEOUT : Timed out waiting for REORG.TXT* to be removed. Please check the online_reorg processes"
	set nonomatch
	\ls -ltr $reorgend $reorgpat
	unset nonomatch
	date
else
	mv ${reorgend} ${reorgend}_`date +%H_%M_%S`
endif
