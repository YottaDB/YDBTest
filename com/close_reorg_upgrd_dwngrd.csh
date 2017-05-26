#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2005-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# $1 = reorg output message filename
if (! -e reorg_upgrd_dwngrd.pid) exit # means the online_reorg_upgrd_dwngrd never started

set updwnpat = "MUPIP_UPGDWNG.TXT*"
set updwnend = "MUPIP_UPGDWNG.END"

date
echo "Stop MUPIP"
set nonomatch
set updwnfiles = $updwnpat
unset nonomatch
if ("$updwnfiles" == "$updwnpat") then
   if (! $?reorg_upgrd_dwngrd_crash) then
	   echo "TEST-E-MUPIP is not executing!"
   else
	   # it was crashed, as we've been told by $?reorg_upgrd_dwngrd_crash
	   echo "TEST-I-MUPIP is not executing!"
   endif
   exit
endif
#
# Signal all reorg processes to exit
#
date
\touch $updwnend

# Wait for a maximum of 30 minutes
set timeout = 1800
while ($timeout > 0)
	set nonomatch
	set updwnfiles = $updwnpat
	unset nonomatch
	if ("$updwnfiles" == "$updwnpat") then
		echo "No $updwnpat files found"
		echo "`date` : All reorg upgrade_downgrade processes have exited now"
		break
	else
		echo "`date` : Waiting for reorg processes to exit"
		sleep 1
	endif
	@ timeout = $timeout - 1
end
if ($timeout == 0) then
	echo "TEST-E-TIMEOUT : Timed out waiting for MUPIP_UPGDWNG.TXT* to be removed. Please check the online_reorg_upgrd_dwngrd processes"
	set nonomatch
	\ls -ltr $updwnpat $updwnend
	date
else
	mv ${updwnend} ${updwnend}_`date +%H_%M_%S`
endif
