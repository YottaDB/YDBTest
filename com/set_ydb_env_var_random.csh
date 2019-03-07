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

# $1 - ydb* env var	# from the ydbenvname column in ydb_logicals_tab.h
# $2 - gtm* env var	# from the gtmenvname column in ydb_logicals_tab.h
# $3 - value		# to set the env var to

unsetenv $1
if ($2 != "") then
	unsetenv $2
endif

set rand_num = `$gtm_tst/com/genrandnumbers.csh 1 0 1`	 # generate one random numbers between 0 and 1

if (0 == $rand_num) then
	setenv $1 "$3"
	# Once ydb* env var is set, set gtm* env var to an arbitrary value. It does not matter as the ydb* env var prevails.
	# The below is a test of that code change.
	setenv $2 "abcdefgh"
else
	if ($2 != "") then
		setenv $2 "$3"
	endif
endif
