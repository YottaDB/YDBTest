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
# Prints the filesystem type holding the directory passed in $1.
# Prints nothing and returns $status of -1 in case of error.
#

set dir = "$1"
if ("$dir" == "") then
	set dir = "."
endif

set mountpoint = `df $dir | tail -1 | $tst_awk '{print $NF}'`
if ($status) then
	echo "TEST-E-ISCURDIRCMPFS : Error while determining filesystem for directory $dir"
	exit -1
endif

set filesystype = `grep " $mountpoint " /etc/mtab | sed 's/rw.*//g' | $tst_awk '{print $NF}'`
echo $filesystype

