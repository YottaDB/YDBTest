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

# This script is invoked from tests which need to speed up the update rate of SLOWFILL.
# Default update rate is 1 update per second.
# Callers of this script though will get an update rate of 50 updates per second (i.e. one update every 0.02 seconds)
# If this is a 1-CPU box though, we have seen many hours for the backlog to clear in some tests so we set the
#	update rate at 10 updates per second (i.e. one update every 0.01 seconds).

if (! $gtm_test_singlecpu) then
	setenv gtm_test_wait_factor 0.02
else
	setenv gtm_test_wait_factor 0.10
endif
