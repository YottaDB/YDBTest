#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
#

echo "# Test to check how well ^%RI and ^%RO handle long code line lengths up to 1MiB."
echo "# YDB will automatically break up lines longer than 8KiB since it will exceed the code line length limit."
echo "# Previously the code line length limit was 2044 characters."

echo "# This test verifies that the code line length limit is now greater than 2044 characters and will not have"
echo "# an increased line count using both ^%RI and ^%RO."
$gtm_dist/mumps -r gtm9145 > temp.m
echo "# Checking file size"
stat -c %s temp.m
echo "# Checking line count"
wc -l temp.m
echo "# Beginning test by using ^%RO"
$GTM << aaa
DO ^%RO
temp

file.ro
RO File to test code line length limit of %RI and %RO

zwr
aaa

echo "# Testing ^%RI"
$GTM << aaa
DO ^%RI

file.ro

zwr
aaa

echo "# Verifying that there is only 1 line"
wc -l temp.m
