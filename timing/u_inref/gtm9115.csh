#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "This portion of the test was moved from v63009 due to test failures when other tests were run in parallel."

set try = 0
while($try < 3)
	@ try = $try + 1
	echo '\nTesting performance of current %DO vs previous %DO' >&! try${try}.out
	$ydb_dist/yottadb -r compdectooct^gtm9115 >> try${try}.out

	echo '\nTesting Performance of current %OD vs previous %OD' >> try${try}.out
	$ydb_dist/yottadb -r compocttodec^gtm9115 >> try${try}.out

	echo '\nTesting Performance of current %HO vs previous %HO' >> try${try}.out
	$ydb_dist/yottadb -r comphextooct^gtm9115 >> try${try}.out

	echo '\nTesting Performance of current %OH vs previous %OH' >> try${try}.out
	$ydb_dist/yottadb -r compocttohex^gtm9115 >> try${try}.out
	grep -q FAILED try${try}.out
	if (0 != $status) then
		break
	endif
end
cat try${try}.out
