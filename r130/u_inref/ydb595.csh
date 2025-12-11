#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Test that yottadb -version outputs the same values as ZYRELEASE, ZVERSION and ZRELDATE"
echo "# but formatted slightly differently."

$ydb_dist/yottadb -version > version.txt
set zyr=`$ydb_dist/yottadb -run ^%XCMD 'write $ZYRELEASE' | awk '{print $2}'`
cat version.txt | grep 'YottaDB release:' | sed "s/${zyr}/##ZYRELEASE##/;"

set zv=`$ydb_dist/yottadb -run ^%XCMD 'write $ZVERSION' | awk '{print $1 " " $2}'`
cat version.txt | grep 'Upstream base version:' | sed "s/${zv}/##ZVERSION##/;"

set plat=`$ydb_dist/yottadb -run ^%XCMD 'write $ZVERSION' | awk '{print $4}'`
cat version.txt | grep 'Platform:' | sed "s/${plat}/##ARCH##/"

set zdate=`$ydb_dist/yottadb -run ^%XCMD 'write $ZRELDATE' | awk '{print $1 " " $2}'`
cat version.txt | grep 'Build date/time:' | sed -i "s/-//g" "version.txt"
cat version.txt | grep 'Build date/time:' | sed "s/${zdate}/##ZRELDATE##/;"

set sha=`$ydb_dist/yottadb -run ^%XCMD 'write $ZRELDATE' | awk '{print $3 " " $4}'`
cat version.txt | grep 'Build commit SHA:' | sed "s/${sha}/##SHA##/;"

# Verify Compiler and Build Type added in r2.04
cat version.txt | grep 'Compiler:'
# Cannot verify compiler version as we don't have anything in YDBTest that grabs the version
cat version.txt | grep 'Build Type:'
cat version.txt | grep 'ASAN:'

# Checks that production releases do not contain the string (dirty) when using ZRELDATE and issues a failure if true
if ( "$zyr" !~ *r9* && "$sha" =~ *\(dirty\)* ) then
	echo 'FAILURE: $ZRELDATE contains "(dirty)" even though $ZYRELEASE is a production release (i.e. not r9*)'
else
	echo 'PASS: $ZRELDATE contains "(dirty)" only if $ZYRELEASE is a development release (i.e. r9*)'
endif
