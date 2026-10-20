#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Sourced by recvpool_orphan-ydb1312.csh at the end of a stage. Checks that the receive pool left behind in that stage
# (ids in rcvshm and rcvsem) no longer exists, and removes whatever is left of it so a failing run leaves nothing behind.
set leftover = ""
$gtm_tst/com/ipcs -m | $tst_awk '{print $2}' | $grep -qw "$rcvshm"
if (0 == $status) then
	set leftover = "$leftover shared memory $rcvshm"
	$gtm_tst/com/ipcrm -m $rcvshm >& /dev/null
endif
$gtm_tst/com/ipcs -s | $tst_awk '{print $2}' | $grep -qw "$rcvsem"
if (0 == $status) then
	set leftover = "$leftover semaphore $rcvsem"
	$gtm_tst/com/ipcrm -s $rcvsem >& /dev/null
endif
if ("" == "$leftover") then
	echo "PASS : the receive pool left behind in this stage no longer exists"
else
	echo "WRONG : the receive pool left behind in this stage still existed (${leftover:s/ //}), removed it with ipcrm"
endif
