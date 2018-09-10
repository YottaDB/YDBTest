#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

# This script reports left-over relinkctl files and new IPCs based on the potential creators' PIDs.

set index = $1
set pids = "$2"

# Make sure there are no left-over relinkctl files.
ls gtm-* >&! /dev/null
if (! $status) then
	echo "TEST-E-FAIL, There are left-over relinkctl files:"
	ls -l gtm-*
endif

# Make sure there are no left-over shared memory segments.
$gtm_tst/com/ipcs -mp > shms${index}.log
if ("Linux" == $HOSTOS) then
	# On Linux the fields are as follows:
	# shmid  owner  cpid  lpid
	@ new_shm_count = `$tst_awk '$3 ~ mymatch {print $0}' mymatch='^('$pids')$' shms${index}.log | wc -l`
else
	# On all other platforms the fields are as follows:
	# T  ID  KEY  MODE  OWNER  GROUP  CPID  LPID
	@ new_shm_count = `$tst_awk '$7 ~ mymatch {print $0}' mymatch='^('$pids')$' shms${index}.log | wc -l`
endif
if ($new_shm_count) then
	echo "TEST-E-FAIL, There are left-over shared memory segments:"
	if ("Linux" == $HOSTOS) then
		$tst_awk '$3 ~ mymatch {print $0}' mymatch='^('$pids')$' shms${index}.log
	else
		$tst_awk '$7 ~ mymatch {print $0}' mymatch='^('$pids)')$' shms${index}.log
	endif
endif
