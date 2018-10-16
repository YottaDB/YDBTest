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

set hostn = "$HOST:r:r:r"

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

# need to setup syslog_info for some Linux boxes as rules in posixtest.m have conflicts
if ((jackal == $hostn) || (carmen == $hostn) || (tuatara == $hostn)) setenv syslog_info /var/log/messages

echo ""
echo "Executing posixtest and expect PASS for all"
echo ""

$gtm_exe/mumps -r posixtest
