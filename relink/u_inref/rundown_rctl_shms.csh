#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This script removes (and report) all relinkctl and rtnobj shared memory segments
# associated with the specified directory.

set arg = $1
set file = $2
set shm_to_remove = $3

if ("" == $shm_to_remove) then
	set shm_to_remove = "both"
endif

# Do an RCTLDUMP and obtain relinkctl and rtnobj shared memory IDs.
$gtm_dist/mupip rctldump $arg >&! $file

if (("rtnobj" == $shm_to_remove) || ("both" == $shm_to_remove)) then
	set rtnobj_shmids = `$tst_awk '/Rtnobj shared memory/ {print $8}' $file`
	foreach shmid ($rtnobj_shmids)
		$gtm_tst/com/ipcrm -m $shmid
		echo "TEST-I-INFO, Removed rtnobj shared memory segment $shmid."
	end
endif

if (("relinkctl" == $shm_to_remove) || ("both" == $shm_to_remove)) then
	set relinkctl_shmids = `$tst_awk '/Relinkctl shared memory/ {print $6}' $file`
	foreach shmid ($relinkctl_shmids)
		$gtm_tst/com/ipcrm -m $shmid
		echo "TEST-I-INFO, Removed relinkctl shared memory segment $shmid."
	end
endif
