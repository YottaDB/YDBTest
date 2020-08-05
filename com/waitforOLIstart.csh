#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2012, 2013 Fidelity Information Services, Inc	#
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
#
# This script uses the field in node local that synchronizes GT.M and the test.
# It waits until GT.M signals that it is ready to proceed by placing a "1" in the field.

set wait_time = 900	# We have seen test failures when this was 120 seconds hence bumped up to 900 seconds
while ($wait_time)
	$DSE cache -show -offset=$hexoffset -size=4 >&! dse_cache_show.out
	$grep "Value = 1" dse_cache_show.out >&! /dev/null
	if !($status) then
		break
	else
		sleep 1
		@ wait_time = $wait_time - 1
	endif
end
if (0 == $wait_time) then
	echo "# `date` TEST-E-TIMEOUT waited for $wait_time for online integ to initiate snapshot."
	exit
endif
