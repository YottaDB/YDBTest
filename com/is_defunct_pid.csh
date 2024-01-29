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

# This script exits with a value of 1 if the passed in pid ($1) is a defunct process. And 0 otherwise.

# $1 - process-id

set isdefunct = `ps -lp $1 | $tst_awk '{if ($2=="Z") print $2}'`
if ("Z" == "$isdefunct") then
	exit 1
else
	exit 0
endif

