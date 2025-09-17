#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#test to make sure that setting allocation 7340026 and autoswitchlimit=7340025 gives a VALTOOBIG error.
echo "# Test that allocation=7340026 autoswitchlimit=7340025 gives VALTOOBIG error"
echo "# Previously, due to a syntax error with unbalanced quotes when using indirection, we got %YDB-F-CMD, Command expected but not found instead."

$gtm_dist/mumps -run GDE change -region DEFAULT -journal="(allocation=7340026,autoswitchlimit=7340025)"
