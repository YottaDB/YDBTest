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
# This module is derived from FIS GT.M.
#################################################################

if (-e $gtm_exe/yottadb) then
	# r1.26 or above version where $ydb_dist/yottadb is the primary executable (not $ydb_dist/mumps)
	# Cannot use "file" on "mumps" as it would say "soft link" instead of "64-bit executable" like we expect.
	# So use "file" on "yottadb", the primary executable.
	set exe = "yottadb"
else
	# pre-r1.26. We are guaranteed $gtm_exe/mumps exists. Use that for "file" check.
	set exe = "mumps"
endif

file $gtm_exe/$exe | $grep -c "64-bit" > /dev/null

if ( "$?" == 0 ) then
	setenv cur_platform_size 1
else
	setenv cur_platform_size 0
endif
