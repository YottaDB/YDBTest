#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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


# A tool to wait until the receiver server described by the passed log file has exited.
# usage :
# $gtm_tst/com/wait_until_rcvr_exit.csh <receiver-server-log-file>
#
# Exits immediately, and without an error, if the log does not exist or names no pid, since that means
# no receiver server got as far as starting and there is nothing to wait for.
#
# The pid comes from the log rather than from MUPIP REPLICATE -RECEIV -CHECKHEALTH, which this script
# used to use. A checkhealth stops reporting a receiver server as alive the moment it begins shutting
# down, which is well before it exits: "gtmrecv_end1" clears "recv_serv_pid" and only then detaches
# from the receive pool and, if an external filter is in use, waits for that filter to stop, which has
# been seen to take ten seconds. For all of that window a checkhealth yielded no pid, this script had
# nothing to wait for, and it returned while the receiver server was still running and still attached
# to the journal pool. A caller that went on to run something needing sole access, such as
# MUPIP REPLICATE -SOURCE -SHUTDOWN -TIMEOUT=0, then found the receiver server in its way. The log
# records the pid when the server starts, so it does not depend on when the question is asked.
#
# Waiting for the receiver server alone is enough. It reaps its update process in "gtmrecv_endupd" and
# its helpers in "gtmrecv_end_helpers", which waits for each of them, so nothing it started outlives it.

if ($#argv == 0) then
	echo ""
	echo "$0 <receiver-server-log-file>"
	echo ""
	exit -1
endif

set rcvrlog = "$1"
if (! -e "$rcvrlog") then
	exit 0
endif

# The line the pid comes from, where the leading timestamp makes a fixed field number unwise:
#	... : %YDB-I-REPLINFO, GTM Replication Receiver Server with Pid [70997] started on ...
# That wording is built in "sr_unix/gtmrecv.c" (search for "Receiver Server with Pid"), so if it ever
# changes this script stops finding a pid and callers stop waiting. It returns quietly in that case
# rather than failing, so the symptom would be the intermittent failure this replaced coming back.
set rcvrpid = `$tst_awk 'index($0, "Receiver Server with Pid") {for (i = 1; i <= NF; i++) if ("Pid" == $i) {p = $(i + 1); gsub(/[^0-9]/, "", p); if ("" != p) {print p; exit}}}' "$rcvrlog"`

if ("" != "$rcvrpid") then
	$gtm_tst/com/wait_for_proc_to_die.csh $rcvrpid
endif
