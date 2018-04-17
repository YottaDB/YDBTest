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

# $1 - ydb* env var	# from the ydbenvname column in ydb_logicals_tab.h
# $2 - gtm* env var	# from the gtmenvname column in ydb_logicals_tab.h

unsetenv $1
if ($2 != "") then
	unsetenv $2
endif

