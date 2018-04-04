#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
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

# Since the concurrent updates happening during the online integ include KILLs, it is possible to see MUKILLIP errors
# (and associated secondary errors like DBMRKBUSY etc.) in the online integ output. Therefore filter them away from
# the sight of error catching logic in test framework.
$grep -q YDB-W-MUKILLIP stress_oli.out
if (! $status) then
	# Filter out YDB-W-MUKILLP and associated errors. The list of such errors can be found from dbcheck_base_filter.csh
	# KILLABANDONED is removed from that list because that requires processes to be killed which is not the case in
	# the stress test. But we might need to add that eventually since the test does do MUPIP STOP of reorg processes.
	mv stress_oli.out stress_oli.outx
	$grep -vE "MUKILLIP|DBMRKBUSY|DBLOCMBINC|DBMBPFLDLBM|INTEGERRS" stress_oli.outx >&! stress_oli.out
endif
