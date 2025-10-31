#!/usr/local/bin/tcsh -f
###########################################################
#
# Copyright (c) 2024-2026 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
###########################################################

# This script copies YDBTest code from the current directory's git repository to the run dir
# It is intended to be run by the 'tsync' alias

# Select directory to sync.
# If the current directory's .git repository is not a YDBTest repository then use $work_dir/YDBTest instead.
# This prevents copying some potentially massive repository.
set __tsyncdir = "`git rev-parse --show-toplevel >& /dev/stdout`"
if ( $? || ! -e "${__tsyncdir:q}/com/gtmtest.csh" ) then
	set __tsyncdir = "${work_dir:q}/YDBTest"
endif

# The --delete-excluded below prevents "cannot delete non-empty directory" errors
# if the test creates an excluded in the destination
rsync $* -av --delete --delete-excluded --exclude=.git "${__tsyncdir:q}/" $gtm_tst/
