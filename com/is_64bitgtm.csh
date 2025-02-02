#################################################################
#								#
# Copyright (c) 2019-2024 YottaDB LLC and/or its subsidiaries.	#
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

set machtype = `uname -m`
if (("x86_64" == "$machtype") || ("aarch64" == "$machtype")) then
	setenv cur_platform_size 1
else
	setenv cur_platform_size 0
endif

