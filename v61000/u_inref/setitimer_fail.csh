#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# This test simulates, via a white-box logic, an error return from timer_create()/setitimer(), which is used to"
echo "# start a new system timer or cancel an existing one. We expect appropriate error messages to be printed in the console."

echo "# Set the white-box test that simulates an error return from timer_create()/setitimer()."
set echo
setenv ydb_white_box_test_case_enable 1
setenv ydb_white_box_test_case_number 98
unset echo

echo "##################################################################"
echo "# Case 1. A timer_create()/setitimer() failure from direct mode. #"
echo "##################################################################"
$echoline

echo "# Try to issue a hang from direct mode, thus invoking the white-box test logic."
$ydb_dist/mumps -direct <<EOF
hang 0.1
quit
EOF

echo

echo "###################################################################"
echo "# Case 2. A timer_create()/setitimer() failure from an M routine. #"
echo "###################################################################"
$echoline

echo "# Produce a simple M file test.m for testing."
cat <<EOF >&! test.m
test
  hang 0.2
  quit
EOF

echo "# Invoke the M program with a hang, thus triggering the white-box test logic."
$ydb_dist/mumps -run test

unsetenv ydb_white_box_test_case_enable
