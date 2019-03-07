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
#
#
echo "# Switching to UTF-8 Mode"
$switch_chset "UTF-8"
echo '# Running $ZCONVERT in NOBADCHAR mode on $ZCHAR(128) (which is an invalid UTF8 byte sequence) but we expect no BADCHAR error'
$ydb_dist/mumps -run gtm8733
