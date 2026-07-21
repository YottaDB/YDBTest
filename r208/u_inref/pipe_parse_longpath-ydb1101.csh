#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#-------------------------------------------------------------------------------------------------#"
echo '# [#1101] PIPE OPEN with PARSE does not read past the end of its $PATH buffer when $PATH is long   #'
echo "#-------------------------------------------------------------------------------------------------#"
echo

# parse_pipe() copies $PATH into a YDB_PATH_MAX (PATH_MAX+1) byte buffer and truncates anything longer.
# The truncated copy used to be left unterminated, so the STRTOK_R walking it read past the end of the
# buffer. That is an over-read, so the YottaDB memory manager's red-zone checks (which only verify that
# guard bytes were not *written*) cannot see it -- only ASAN can, and only when YottaDB is using the
# system malloc/free. On a non-ASAN image this subtest still exercises the path and checks the OPEN
# fails cleanly, but it takes an ASAN image to actually catch a regression here.
if ($gtm_test_libyottadb_asan_enabled) then
	source $gtm_tst/com/set_gtmdbglvl_to_use_system_malloc_free.csh
endif

# Build a $PATH comfortably past PATH_MAX (4096) out of directories that do not exist, so that the
# command lookup fails and parse_pipe() has to walk every one of them. The real $PATH is appended so
# the rest of the process environment stays usable.
set longpath = `$tst_awk 'BEGIN {s = ""; for (i = 0; i < 200; i++) { s = s sprintf("/ydb1101_no_such_dir_%04d:", i) } printf "%s", s}'`
echo '## Run [ydb1101path] routine with an over-long $PATH'
env PATH="${longpath}${PATH}" $ydb_dist/yottadb -run ydb1101path
