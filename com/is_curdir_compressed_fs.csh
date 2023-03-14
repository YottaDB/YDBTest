#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# $1 - directory path; if no argument is passed, current directory (pwd) is assumed.
#
# Prints 1 if the filesystem holding the directory passed in $1 is a compressed file system
# Prints 0 otherwise.
# Prints nothing and returns $status of -1 in case of error.
#
# Compressed file systems will not return the allocated space of the uncompressed file when a "du" is run.
# They will instead return the allocated space for the compressed file. And this will disturb the flow of some
# tests that rely on this (e.g. v62002/gtm5894). Such tests use this script so they can be not run on compressed
# file systems.

set dir = "$1"
if ("$dir" == "") then
	set dir = "."
endif

set mountpoint = `df $dir | tail -1 | $tst_awk '{print $NF}'`
if ($status) then
	echo "TEST-E-ISCURDIRCMPFS : Error while determining filesystem for directory $dir"
	exit -1
endif

set filesystype = `grep $mountpoint /etc/mtab | sed 's/rw.*//g' | $tst_awk '{print $NF}'`

# For ext4 and xfs, compression does not seem to be supported at this point.
# For f2fs, compression is supported but filesystem space is consumed at the same rate as if compression was disabled.
# Therefore, the compression check is currently done only for ZFS filesystems.
set is_compressed = 0
if ("$filesystype" == "zfs") then
	set compressed = `zfs get compression $mountpoint | tail -1 | $tst_awk '{print $3}'`
	if ("$compressed" != "off") then
		set is_compressed = 1
	endif
endif
echo $is_compressed
exit 0
