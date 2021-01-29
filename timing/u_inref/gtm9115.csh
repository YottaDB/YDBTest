#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
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

echo '\nTesting performance of current %DO vs previous %DO'
$ydb_dist/yottadb -r compdectooct^gtm9115

echo '\nTesting Performance of current %OD vs previous %OD'
$ydb_dist/yottadb -r compocttodec^gtm9115

echo '\nTesting Performance of current %HO vs previous %HO'
$ydb_dist/yottadb -r comphextooct^gtm9115

echo '\nTesting Performance of current %OH vs previous %OH'
$ydb_dist/yottadb -r compocttohex^gtm9115
