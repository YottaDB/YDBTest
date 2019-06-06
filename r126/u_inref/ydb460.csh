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
# Test of maximum line length for M source files currently 32766 (32KiB-2) characters
#
#

echo '# Test of maximum line length for M source files currently 32766 (32KiB-2) characters'

echo '# Generating M file with 32766 characters on one line'
$gtm_dist/mumps -run ydb460 > longline.m
echo '# Running longline.m'
$gtm_dist/mumps -run longline
