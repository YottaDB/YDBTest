#!/usr/local/bin/tcsh -f
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
#
#
#

echo '# New r128/V63006B subtest to test that mumps command will compile multiple M files interactively'

echo '# Attempting to compile "x.m y.m z.m"'
touch x.m y.m z.m
echo 'x.m y.m z.m' | $gtm_dist/mumps

echo '# checking for "x.o y.o z.o"'
ls x.o y.o z.o
if (0 == $status) then
	echo "PASS"
else
	echo "FAIL"
endif
