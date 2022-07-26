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
echo '# Test for GTM-9295 - Various $[Z]TRANSLATE() fixes'
$switch_chset UTF-8
echo
echo '# Drive gtm9295 sub-issue A test routine'
$gtm_dist/mumps -run partA^gtm9295
echo
echo '# Drive gtm9295 sub-issue B test routine'
$gtm_dist/mumps -run partB^gtm9295
echo
echo '# Drive gtm9295 sub-issue C test routine'
$gtm_dist/mumps -run partC^gtm9295
