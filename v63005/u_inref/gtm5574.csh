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
#
#

# Set to avoid wrapping from bc
setenv BC_LINE_LENGTH 0
foreach n (10)
	echo "# Conversions using an $n digit number"
	$ydb_dist/mumps -run gtm5574 $n
	echo "-------------------------------------------"
end
