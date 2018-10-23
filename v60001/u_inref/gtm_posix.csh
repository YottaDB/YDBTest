#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv ydb_xc_ydbposix $ydb_dist/plugin/ydbposix.xc

# create test file for linerepl.m
cat >& tempfile <<EOF
The quick
brown fox
jumps over
the lazy
dog.
EOF

echo "Contents of tempfile:"
cat tempfile
echo
echo "modified by:"
echo '$gtm_exe/mumps -r linerepl --match=/the/ --replace=:A: tempfile'
$gtm_exe/mumps -r linerepl --match=/the/ --replace=:A: tempfile
echo
echo "Contents of tempfile after linerepl change:"
cat tempfile

echo ""
echo "Executing posixtest and expect PASS for all"
echo ""

$gtm_exe/mumps -r posixtest
