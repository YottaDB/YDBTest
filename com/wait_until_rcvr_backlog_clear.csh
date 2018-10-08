#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
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

set timeout = $1
if ("" == "$timeout") set timeout = 1800	# keep in sync with com/wait_until_src_backlog_below.csh
set sleepinc = 5
while ($timeout > 0)
	$gtm_tst/com/is_rcvr_backlog_clear.csh
	if (! $status) exit 0
	sleep $sleepinc
	@ timeout = $timeout - $sleepinc
end
exit 1
