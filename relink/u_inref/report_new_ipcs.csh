#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This script reports left-over relinkctl files and new IPCs based on the PIDs of the processes that last attached to them.
# A segment counts as new only if it is not in shms<index-1>.log, the snapshot taken before this step started.
# Matching on the PID alone is not enough because a segment last attached by an unrelated process that has
# since exited carries that process's PID, which the OS can reuse for a process of this step.

set index = $1
set pids = "$2"
@ previndex = $index - 1

# Make sure there are no left-over relinkctl files.
ls gtm-* >&! /dev/null
if (! $status) then
	echo "TEST-E-FAIL, There are left-over relinkctl files:"
	ls -l gtm-*
endif

# Make sure there are no left-over shared memory segments.
# The fields, as reordered by com/ipcs.awk, are as follows:
# owner  shmid  lpid  cpid
$gtm_tst/com/ipcs -mp > shms${index}.log
$tst_awk 'NR == FNR {old[$2]; next} ($3 ~ mymatch) && !($2 in old) {print $0}' mymatch='^('$pids')$'	\
	shms${previndex}.log shms${index}.log > newshms${index}.log
if (! -z newshms${index}.log) then
	echo "TEST-E-FAIL, There are left-over shared memory segments:"
	cat newshms${index}.log
endif
