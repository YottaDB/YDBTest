#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Test that 'ZCompile "bar2.edit"' issues NOTMNAME error instead of compiling
# GT.M V6.3-006 started issuing the NOTMNAME error (see http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V6.3-006_Release_Notes.html#GTM-8178)
# But there was an inconsistency in ZCOMPILE that is addressed as part of YottaDB r1.26 (after integrating GT.M V6.3-006) and this is a test of that.
#

echo '# Test that '"'"'ZCompile "bar2.edit"'"'"' issues NOTMNAME error instead of compiling'
echo '# GT.M V6.3-006 started issuing the NOTMNAME error (see http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V6.3-006_Release_Notes.html#GTM-8178)'
echo '# But there was an inconsistency in ZCOMPILE that is addressed as part of YottaDB r1.26 (after integrating GT.M V6.3-006) and this is a test of that.'

echo 'touch bar2.edit.m'
touch bar2.edit.m
echo 'ZCompile "bar2.edit.m"'
echo 'ZCompile "bar2.edit.m"' | $ydb_dist/mumps -direct
ls bar2.o >& /dev/null
if ($status != 2) then
	echo 'bar2.o found when it should not exist'
	rm bar2.o
endif

echo 'ZCompile "bar2.edit"'
echo 'ZCompile "bar2.edit"' | $ydb_dist/mumps -direct
ls bar2.o >& /dev/null
if ($status != 2) then
	echo 'bar2.o found when it should not exist'
	rm bar2.o
endif

