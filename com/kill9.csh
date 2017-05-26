#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

if !($?gtm_tst) then
	setenv gtm_tst $gtm_test/T990
	source $gtm_tst/com/set_specific.csh
endif

set origargs = "$*"
set stat = 0
source $gtm_tst/com/safe_kill.csh -9 $*
@ stat += $status
if ($stat) then
	echo "TEST-E-KILL9 $gtm_tst/com/safe_kill.csh reported a failure for: ${origargs}"
	if ($#killed_pids) then
		echo "TEST-I-KILL9 the following PIDs were killed: $killed_pids"
	endif
	exit 1
endif


foreach pid ($killed_pids)
	$gtm_tst/com/wait_for_proc_to_die.csh $pid
	@ stat += $status
end
exit $stat
