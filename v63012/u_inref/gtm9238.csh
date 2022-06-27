#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# GTM-9238 - Test that when ZSTRPLLIM is set, only a single STPCRIT message comes out prior to getting an STPOFLOW error.'
echo
echo '# Drive gtm9238 M code'
$ydb_dist/yottadb -run gtm9238^gtm9238
echo
echo '# If this test ran "correctly", it left both a core file and a fatal-error file behind which'
echo '# will fail this test even though they may be expected. Verify that the fatal-error file contains'
echo '# an STPOFLOW error in it so we know if the process got a fatal error for the correct reason or'
echo '# not. If we find the STPOFLOW error, then the single core file that this error created would be'
echo '# for this error and can be renamed along with the fatal error file to gtm9238_corefile and'
echo '# gtm9238_fatal_error_file.txt respectively so they do not cause test failures.'
# Verify we have one fatal error file and one core
set fatalCnt = `ls -1 YDB_FATAL_ERROR.ZSHOW_DMP_*.txt | wc -l`
if ("1" != "$fatalCnt") then
    echo '# More than one fatal error file discovered - terminating'
    exit 1
endif
set coreCnt = `ls -l core.* | wc -l`
if ("1" != "$coreCnt") then
    echo '# More than one core file discovered - terminating'
    exit 1
endif
# Locate the fatal error file
set fatalErrorFile = `ls -1 YDB_FATAL_ERROR.ZSHOW_DMP_*.txt`
if (! -e $fatalErrorFile) then
    echo '# Fatal error file not found - unexpected condition - terminating'
    exit 1
endif
$grep '$ZSTATUS="150384284,chewStringPool+4^gtm9238,%YDB-F-STPOFLOW, String pool space overflow"' $fatalErrorFile
set saveStatus = $status
if (0 != $status) then
    echo '# $ZSTATUS containing STPOFLOW error not found in the created fatal error file - terminating'
    exit 1
endif
# At this point we know the fatal error file and core were both produced by STPOFLOW so rename both
mv $fatalErrorFile gtm9238_fatal_error_file.txt
mv core.* gtm9238_core
echo
echo '# Verify that setting $ZSTRPLLIM below the minimum sets the value to the minimum ($ydb_string_pool_limit'
echo '# is set to 40K, then to 30K). So both of these should display as 150K.'
setenv ydb_string_pool_limit 40000
setenv ydb_etrap "do showZSTRPLLIMHandler"
$ydb_dist/yottadb -run showzstrpllim^gtm9238
echo "# Return code $status"
unsetenv ydb_string_pool_limit
