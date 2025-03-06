#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2019-2025 YottaDB LLC and/or its subsidiaries.	#
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

echo '# ------------------------------------------------------------------------'
echo '# Test that '"'"'ZCompile "bar2.edit"'"'"' does NOT issue a NOTMNAME error'
echo '# ------------------------------------------------------------------------'
echo '# GT.M V6.3-006 started issuing a NOTMNAME error (see http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V6.3-006_Release_Notes.html#GTM-8178)'
echo '# But there was an inconsistency in ZCOMPILE that is addressed as part of YottaDB r1.26 (after integrating GT.M V6.3-006)'
echo '# and this test was originally written to test that change.'
echo
echo '# But GT.M V7.1-001 changed this behavior and stopped issuing the NOTMNAME error in this case'
echo '# Therefore this test has been revised to no longer expect a NOTMNAME error'

echo 'touch bar2.edit.m'
touch bar2.edit.m
echo '# ZCompile "bar2.edit.m"'
echo '# Expect a NOTMNAME and ZLNOOBJECT error'
echo 'ZCompile "bar2.edit.m"' | $ydb_dist/mumps -direct
ls bar2.o >& /dev/null
if ($status != 2) then
	echo 'bar2.o found when it should not exist'
	rm bar2.o
endif

echo '# ZCompile "bar2.edit"'
echo '# Expect NO error and expect bar2.o to be created'
echo 'ZCompile "bar2.edit"' | $ydb_dist/mumps -direct
ls bar2.o >& /dev/null
if ($status != 0) then
	echo 'bar2.o NOT found whereas expect it to exist'
else
	rm bar2.o
endif

