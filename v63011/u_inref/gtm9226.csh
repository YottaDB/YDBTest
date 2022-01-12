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

$switch_chset "UTF-8" # Need this because the gtm9226 bug is UTF-8 only
echo '# This tests for a bug in $translate in versions prior to V6.3-011'
echo '# where the character length of the result was set incorrectly. This'
echo '# could happen if VIEW "NOBADCHAR" was enabled and $translate was'
echo '# passed a malformed UTF-8 byte sequence as the replacement string.'
$ydb_dist/mumps -run gtm9226^gtm9226
