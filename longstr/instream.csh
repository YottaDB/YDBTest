#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#! /usr/local/bin/tcsh -f
# max_strlen [Mohammad] basic functionality with long string
# ac_loc_coll [Mohammad] local collation with long string
# biglcgb [Layek] Merge with long local string
echo "longstr  test starts"
setenv subtest_list "max_strlen ac_loc_coll biglcgb"
$gtm_tst/com/submit_subtest.csh
echo "longstr  test ends"
