#!/usr/local/bin/tcsh -f
#################################################################
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
# Script to filter out MUKILLIP errors and friends from online integ output. See
# https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1059#note_428431536 for details on how this is possible.

# Since the concurrent updates happening during online integ include KILLs, it is possible to see MUKILLIP errors
# (and associated secondary errors like DBMRKBUSY etc.) in the online integ output. Therefore filter them away from
# the sight of error catching logic in test framework.
$grep -q YDB-W-MUKILLIP $1.out
if (! $status) then
	# Filter out YDB-W-MUKILLP and associated errors. The list of such errors can be found from dbcheck_base_filter.csh
	# KILLABANDONED is removed from that list because that requires processes to be killed which is not the case in
	# the tests using this script. But we might need to add that eventually if needed by those tests.
	mv $1.out $1.outx
	$grep -vE "MUKILLIP|DBMRKBUSY|DBLOCMBINC|DBMBPFLDLBM|INTEGERRS" $1.outx >&! $1.out
endif
