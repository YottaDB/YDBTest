#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# SELinux adds a . at the end of the permissions column in an ls -l output.
# But test reference files that rely on ls -l output need to not see the dot.
# This script helps by removing the dot from the ls -l output.
# For example "-rwxr-xr-x." gets changed to "-rwxr-xr-x"

# All test scripts that do an "ls -l" and redirect that output to a test reference file need to use
# "$gtm_tst/com/lsminusl.csh" instead to have a portable reference file.

ls -l $* | $tst_awk '{if ($1 ~ /-.*\./) gsub("\\.","",$1); print $0}'
