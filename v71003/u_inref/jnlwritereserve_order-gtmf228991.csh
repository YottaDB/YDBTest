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
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-F228991 - Test the following part of the release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-003_Release_Notes.html#GTM-F228991)

GT.M performs less work while holding an instance-wide lock during replication. This instance-wide lock controls any increment of the sequence number and prevents any replicated update instance-wide when held. In particular, GT.M processes now calculate the size of any journaling activity and perform the first phase of a database update in BG or the entire update in MM without needing to hold the instance lock. Previously, these operations were done only while holding that lock. (GTM-F228991)

This is a white box test that needs a debug build (it is excluded in the "pro" image). It does a
simple non-TP update under gdb and checks that "jnl_write_reserve()" is called inside "t_end()"
BEFORE "grab_lock()", which is what takes the instance-wide lock. Before GTM-F228991,
"jnl_write_reserve()" was called AFTER "grab_lock()".

CAT_EOF
echo ""

# "t_end()" takes the instance-wide lock only for a replicated update, so this needs an ACTIVE
# source server. Force -NOJNLFILEONLY (which is also the MUPIP default) so that the source server
# is a consumer of the journal pool.
setenv gtm_test_jnlfileonly 0
echo "setenv gtm_test_jnlfileonly 0" >> settings.csh

$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out

echo "# Start an ACTIVE source server with -NOJNLFILEONLY, and the receiver server"
$MSR START INST1 INST2

echo "# Run one non-TP update under gdb with breakpoints in t_end(), jnl_write_reserve() and grab_lock()"
# Notes on the gdb command file below.
#	a) "set breakpoint pending on" avoids an interactive y/n prompt if a symbol is not yet loaded.
#	b) "set confirm off" avoids the "Quit anyway?" prompt at the end.
#	c) Each breakpoint prints a marker and continues, so the update runs to completion and it is
#	   the ORDER of the markers in gdb.out that carries the result.
#	d) "jnl_write_reserve()" and "grab_lock()" have callers other than "t_end()", and a call from
#	   one of those can land between entering "t_end()" and the calls this test is about. A
#	   "grab_lock()" from the instance freeze machinery did exactly that and produced a FAIL
#	   against code whose ordering was correct. So each marker is tagged with whether its
#	   IMMEDIATE caller is "t_end()", and only those count towards the verdict. Calls from
#	   anywhere else are still logged, as GTMF228991-OTHER, since they are what makes an
#	   unexpected result readable.
#	e) The heredoc delimiter is quoted so that tcsh does no substitution inside the command file.
cat >! gdbcmds << 'CAT_EOF'
set breakpoint pending on
set confirm off
set pagination off
break t_end
commands
silent
printf "GTMF228991-ORDER: t_end\n"
continue
end
break jnl_write_reserve
commands
silent
if $_caller_is("t_end")
printf "GTMF228991-ORDER: jnl_write_reserve\n"
else
printf "GTMF228991-OTHER: jnl_write_reserve\n"
end
continue
end
break grab_lock
commands
silent
if $_caller_is("t_end")
printf "GTMF228991-ORDER: grab_lock\n"
else
printf "GTMF228991-OTHER: grab_lock\n"
end
continue
end
run -run oneupdate^gtmf228991
quit
'CAT_EOF'
gdb $gtm_dist/mumps -x gdbcmds -quiet >& gdb.out

echo "# Below is the order in which the breakpoints were reached (the full gdb log is in gdb.out)"
$tst_awk -f $gtm_tst/$tst/inref/gtmf228991_order.awk gdb.out

echo "# Shut down the source and receiver servers"
$MSR STOP INST1 INST2

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
