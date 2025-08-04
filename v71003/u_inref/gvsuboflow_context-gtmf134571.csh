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
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-F134571 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-003_Release_Notes.html#GTM-F134571)

GT.M issues a GVSUBOFLOW error message with the length of the exceeded subscript, in certain cases it appends the string "..." indicating the subscript is incomplete. Previously, GT.M issued a less informative GVSUBOFLOW error message. (GTM-F134571)

CAT_EOF
echo

$gtm_tst/com/dbcreate.csh mumps 1 -key_size=1019 >&! dbcreate.out

echo "# Run routines that each generate a GVSUBOFLOW error. Expect the context message to include:"
echo "# 1. The length of the subscript and the max subscript length"
echo "# 2. The subscript to be truncated, with OR without '...'"
echo "# The routines cover these cases:"
echo "# 1. Simple subscript overflow that greatly exceeds max length"
echo "# 2. Short subscripts precede a long subscript"
echo "# 3. Short subscripts follow a long subscript"
echo "# 4-14. Simple subscript overflow at a variety of key sizes (1013-1023)"
echo "#    See the following discussions for details:"
echo "#    + https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2406#note_2672568670"
echo "#    + https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1847#note_3472432051"
echo "# Previously:"
echo "# 1. The subscript length and max would be omitted "
echo "# 2. The ellipsis would be omitted and a '*' character would be emitted instead."
echo '# Test 1: Run [$gtm_dist/mumps -r %XCMD '"'"'set i=2000,^x($j(" ",i))=i quit'"'"']. Expect the GVSUBOFLOW message to be truncated with "...":'
$gtm_dist/mumps -r %XCMD 'set i=2000,^x($j(" ",i))=i quit'
echo '# Test 2: Run [$gtm_dist/mumps -r %XCMD '"'"'set i=1014,^x(i,$j("a",i),i+1)=i quit'"'"']. Expect the GVSUBOFLOW message to be truncated with "...":'
$gtm_dist/mumps -r %XCMD 'set i=1014,^x(i,i+1,$j("a",i))=i quit'
echo '# Test 3: Run [$gtm_dist/mumps -r %XCMD '"'"'set i=1014,^x(i,$j("a",i),i+1)=i quit'"'"']. Expect the GVSUBOFLOW message to be truncated with "...":'
$gtm_dist/mumps -r %XCMD 'set i=1014,^x($j("a",i),i,i+1)=i quit'
echo '# Test 4: Run [$gtm_dist/mumps -r %XCMD '"'"'set i=1013,^x($j("a",i))=i quit'"'"']. Expect no GVSUBOFLOW message :'
$gtm_dist/mumps -r %XCMD 'set i=1013,^x($j("a",i))=i quit'
echo '# Test 5: Run [$gtm_dist/mumps -r %XCMD '"'"'set i=1014,^x($j("a",i))=i quit'"'"']. Expect no GVSUBOFLOW message :'
$gtm_dist/mumps -r %XCMD 'set i=1014,^x($j("a",i))=i quit'

set test_num = 5
foreach i (`seq 1015 1021`)
	@ test_num = $test_num + 1
	echo "# Test $test_num"': Run [$gtm_dist/mumps -r %XCMD '"'set i=$i,^x("'$j("a",i))=i quit'"'"']. Expect the GVSUBOFLOW message not to be truncated and omit "...":'
	$gtm_dist/mumps -r %XCMD "set i=$i"',^x($j("a",i))=i quit'
end
foreach i (`seq 1022 1025`)
	@ test_num = $test_num + 1
	echo "# Test $test_num"': Run [$gtm_dist/mumps -r %XCMD '"'set i=$i,^x("'$j("a",i))=i quit'"'"']. Expect the GVSUBOFLOW message to be truncated with "...":'
	$gtm_dist/mumps -r %XCMD "set i=$i"',^x($j("a",i))=i quit'
end

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
