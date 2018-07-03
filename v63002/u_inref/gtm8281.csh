#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Tests that the new maximum for source lines, xecute strings and direct mode input all accept up to 8192 bytes
#

# 1 terminating characters and 9 other characters outside of the big string
# Expect the line to be too long as a source line when n=8182, and too long as
# an xecute string or command in direct mode when n=8183
foreach n (8180 8181 8182 8283 8184)
	echo "# Generating big string with $n characters"
	$ydb_dist/mumps -run gtm8281 $n
	echo ""
	echo "# Using string as source line in an m file"
	$ydb_dist/mumps -run temp
	echo ""
	echo "# Using string as an xecute string"
	set bigstring=`cat temp.m`
	$ydb_dist/mumps -run xecutefn^gtm8281 "$bigstring"
	echo ""
	echo "# Using string as a command in direct mode"
	$ydb_dist/mumps -run dirmode^gtm8281 "$bigstring"
	rm temp.m
	echo ""
	echo "# --------------------------------------------------------------------"
	echo ""
end
