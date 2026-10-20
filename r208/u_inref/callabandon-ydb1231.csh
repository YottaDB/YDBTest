#!/usr/local/bin/tcsh -f
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

# WBTEST_ABANDONEDKILL holds this process in phase II of its first KILL, so it has to run in the
# background for the caller to be able to terminate it there.
( $gtm_exe/mumps -run abandon^ydb1231 >&! abandon.outx ) &
