#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "`date` : Signalling to stop online_eotf.csh"
touch EOTF.END

set timeout = 3600	# A wait of 300 seconds is usually enough but with -encrypt it has been seen to take as much as half an hour
while ($timeout > 0)
	ls EOTF.RUNNING
	if ($status != 0) then
		echo "EOTF.RUNNING does not exist"
		echo "`date` : All REORG ENCRYPT processes have been completed"
		break
	else
		echo "`date` : Waiting for REORG ENCRYPT processes to complete"
		sleep 1
	endif
	@ timeout = $timeout - 1
end
if ($timeout <= 0) then
	echo "TEST-E-TIMEOUT : Timed out waiting for EOTF.RUNNING to be removed. Please check the REORG ENCRYPT processes if hung"
endif

