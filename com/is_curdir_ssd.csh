#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# $1 - directory path whose owning disk type we want to determine.
#    - if no argument is passed, current directory (pwd) is assumed.
#
# Prints 1 if the disk holding the directory passed in $1 is a SSD disk
# Prints 0 if it is a HDD OR if we are not sure.
# Prints nothing and returns $status of -1 in case of error.
#

set dir = "$1"
if ("$dir" == "") then
	dir = "."
endif

set filesystem = `df $dir | tail -1 | $tst_awk '{print $1}'`
if ($status) then
	echo "TEST-E-ISCURDIRSSD : Error while determining filesystem for directory $dir"
	exit -1
endif
# 'not a block device' error comes from running lsblk on the a file system mounted in docker.
set diskname = `lsblk -no pkname $filesystem |& grep -v 'not a block device'`
# Note down exit status from above command. Do not check it right away as in the case of zFS, we could see a non-zero exit
# status but "$diskname" could be the empty string. So first check if the output is the empty string. If so, return HDD.
# Otherwise, check the status and if it is non-zero, issue an error.
set cmd_status = $status
if ($diskname == "") then
	# lsblk command could not find a disk name. An example such filesystem would be
	#   a) "/dev/mapper/home-aes". In this case, it is most likely a Logical Volume comprising mutiple disks.
	#   b) zfs. In this case, it is possibly a pool of file systems.
	# In either case, we cannot be sure. Return HDD in this case.
	echo 0
	exit 0
endif
if ($cmd_status) then
	echo "TEST-E-ISCURDIRSSD : Error while determining diskname for filesystem $filesystem corresponding to directory $dir"
	exit -1
endif
set rotational = `cat /sys/block/$diskname/queue/rotational`
if ($status) then
	echo "TEST-E-ISCURDIRSSD : Error while determining rotational for diskname $diskname corresponding to directory $dir"
	exit -1
endif
if ($rotational) then
	# HDD
	echo 0
	exit 0
else
	# SSD
	echo 1
	exit 0
endif
