#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# This subtest *always* runs in UTF-8 mode. The subtest is disabled if the platform does not support unicode
#
setenv gtm_test_unicode "TRUE"
$switch_chset "UTF-8" >&! switch_utf8.log
#
# Drive test routine generator
#
$echoline
echo "Generating test routine"
$echoline
$gtm_dist/mumps -run gtm7896
echo ""
echo ""
#
# Drive actual test code
#
$echoline
echo "Driving generated test routine gtm7896a"
$echoline
# Filter this out so that badchar warnings are excluded
$gtm_dist/mumps -run gtm7896a >& tmp.txt
cat tmp.txt | $grep -v "%YDB-W-BADCHAR," | $grep -v "t" | $grep -v "\^--"
echo ""
echo ""
#
# Lastly drive the routine to test we still generate appropriate errors
#
$echoline
echo "Driving test routine gtm7896b"
$echoline
$gtm_dist/mumps -run gtm7896b
#
exit $status
