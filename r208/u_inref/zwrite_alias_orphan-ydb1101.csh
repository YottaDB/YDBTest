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
echo '# [#1101] ZWRITE of an orphaned alias container does not overflow its subscript work array         #'
echo "#-------------------------------------------------------------------------------------------------#"
echo

# The overflow is a single array element, so with the default allocator it lands in size-class slack and
# goes unnoticed. Arrange for it to be detectable: under ASAN use the system malloc/free so ASAN can see
# the end of the allocation, otherwise turn on the YottaDB memory manager's red-zone/backfill checks so
# the stray write clobbers a guard zone that is verified on free.
if ($gtm_test_libyottadb_asan_enabled) then
	source $gtm_tst/com/set_gtmdbglvl_to_use_system_malloc_free.csh
else
	setenv gtmdbglvl 0x3F1
endif

# 31 is MAX_LVSUBSCRIPTS, the depth that used to write one element past the end of the work array.
# 30 is the in-bounds case just below the boundary. Both must come out clean.
foreach nsubs (30 31)
	echo "## Run [ydb1101zwr] with $nsubs subscripts"
	$ydb_dist/yottadb -run ydb1101zwr $nsubs
	echo
end

unsetenv gtmdbglvl
