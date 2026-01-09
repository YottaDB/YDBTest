#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This is a test framework wrapper around "scp" calls in the test system.
# It is to handle errors from "scp" by issuing a SCP-E-FAIL error. That way
# a failure to scp is seen as the first failure point in an otherwise complicated test.
# Not having this framework can cause hard to analyze test failures where the
# scp error at the very beginning of the test can be hidden in obscure log files.

scp -q $*
if ($status) then
	echo "SCP-E-FAIL : [scp -q $*] failed with non-zero status"
	exit -1
endif

exit 0
