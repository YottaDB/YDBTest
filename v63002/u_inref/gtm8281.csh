#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Tests that the new maximum for source lines, xecute strings and direct mode input all accept up to 32766 bytes
#

# 1 terminating characters and 7 other characters outside of the big string
# Expect the line to be too long as a source line when n=32758, and too long as
# an xecute string or command in direct mode when n=32759
foreach n (32756 32757 32758 32759 32760)
	echo "# Generating big string with $n characters"
	$ydb_dist/mumps -run gtm8281 $n "temp$n.m"
	echo ""
	echo "# Using string as source line in an m file"
	$ydb_dist/mumps -run temp$n >& source.outx
	if ("" == `diff check.out source.outx`) then
		echo "# a <repeated $n times> executed correctly"
	else
		echo "# a <repeated $n times> too long"
		cat source.outx
	endif
	echo ""
	echo "# Using string as an xecute string"
	set bigstring=`cat temp$n.m`
	$ydb_dist/mumps -run xecutefn^gtm8281 "$bigstring" >& xecute.outx
	if ("" == `diff check.out xecute.outx`) then
		echo "# a <repeated $n times> executed correctly"
	else
		echo "# a <repeated $n times> too long"
		cat xecute.outx
	endif
	echo ""
	echo "# Using string as a command in direct mode"
	$ydb_dist/mumps -run dirmode^gtm8281 "$bigstring" >& dirmode.outx
	if ("" == `diff check.out dirmode.outx`) then
		echo "# a <repeated $n times> executed correctly"
	else
		echo "# a <repeated $n times> too long"
		cat dirmode.outx
	endif
	echo ""
	echo "# --------------------------------------------------------------------"
	echo ""
end
