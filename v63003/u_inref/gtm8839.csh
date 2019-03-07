#!/usr/local/bin/tcsh -f
#################################################################
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
#
# Tests that $DEVICE displays full message when over 80 characters
#

# Setting environment variables to allow for custom $DEVICE message that will be over 80 characters
setenv ydb_white_box_test_case_enable 1
setenv ydb_white_box_test_case_number 138
$ydb_dist/mumps -run gtm8839

