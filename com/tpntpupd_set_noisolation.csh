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

# Randomly set ydb_app_ensures_isolation env var to list of globals that need VIEW "NOISOLATION" set.
# If not set, tpntpupd.m (invoked later from caller script) will do the needed VIEW "NOISOLATION" call.
if (! $?gtm_test_replay) then
	@ rand = `$gtm_exe/mumps -run rand 2`
	# If rand = 0 -> set env var here
	if (0 == $rand) then
		set noisolist = "^aa,^aaa,^aaaa,^bb,^bbb,^bbbb,^cc,^ccc,^cccc,^dd,^ddd,^dddd"
		set noisolist = "$noisolist,^ee,^eee,^eeee,^ff,^fff,^ffff,^gg,^ggg,^gggg,^hh,^hhh,^hhhh"
		set noisolist = "$noisolist,^ii,^iii,^iiii"
		setenv ydb_app_ensures_isolation "$noisolist"
		echo "setenv ydb_app_ensures_isolation $noisolist"	>> settings.csh
	endif
	# If rand = 1 (i.e. ydb_app_ensures_isolation env var is not set) -> do VIEW "NOISOLATION" command later
endif

