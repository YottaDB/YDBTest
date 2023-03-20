#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2020-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################

# The env variable gtm_procstuckexec points to this script. The script obtains the stack trace for the blocking pid
# for various GT.M stuck messages.
# Usage and params: gtmprocstuck_get_stack_trace.csh message waiting_pid blockingpid count

set type = $1
set waiter = $2
set blocker = $3
set count = $4

setenv ydb_log `pwd`

# In case we are being called from the YDBPython wrapper while running with a YottaDB built with ASAN, LD_PRELOAD env var
# would be set. But in that case, we have seen invoking various utilities like curl/gdb cause the process to hang in a
# futex() system call. See https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1575#note_1229459519 for details.
# Therefore, unset the LD_PRELOAD env var before invloking %YDBPROCSTUCKEXEC (which uses "gdb").
unsetenv LD_PRELOAD

$ydb_dist/yottadb -run %YDBPROCSTUCKEXEC $type $waiter $blocker $count
exit $status

