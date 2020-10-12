#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2017-2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################

if (! -e NOT_DONE.OLI) exit # means ONLINE INTEG never started before

date
echo "Stop ONLINE INTEG"

\touch OLI.STOP

set timeout = 1800
while ($timeout > 0)
	\ls ./NOT_DONE.OLI
	if ($status != 0) then
		echo "NOT_DONE.OLI does not exist"
		echo "All ONLINE INTEG processes have been completed. Test can end now"
		break
	else
		echo "Waiting for ONLINE INTEG processes to complete"
		sleep 5
	endif
	@ timeout = $timeout - 5
end
if ($timeout <= 0) then
	echo "TEST-E-TIMEOUT waiting for NOT_DONE.OLI to be removed. Please check the ONLINE INTEG processes if it's hung"
endif

# Filter MUKILLIP and associated errors out of streee_oli.out
$gtm_tst/com/filter_mukillip_from_oli_output.csh stress_oli
