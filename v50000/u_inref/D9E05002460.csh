#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2005, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv gtm_test_jnlfileonly 0	# The test checks journal file users, so prevent the source server from being one.
unsetenv gtm_test_jnlpool_sync	# ditto
$gtm_tst/com/dbcreate.csh mumps 1
set portno=`$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
set pidsrc=`$MUPIP replicate -source -checkhealth |& $tst_awk  '($1 == "PID") && ($2 ~ /[0-9]*/) { print $2 }'`

$GTM << GTM_EOF >& gtm.log
	s ^u=1			; open db/jnl
	zsy "$gtm_tst/com/wait_until_src_backlog_below.csh 0; $MUPIP stop $pidsrc; $gtm_tst/com/wait_for_proc_to_die.csh $pidsrc -1"
	; wait for ^u to be transmitted, stop source server and wait for it to complete shutdown
	; SRC_SHUT.csh generates error as we are shutting down when GTM is still attached to jnlpool
	s ^v=2			; cause backlog
	zsystem "$gtm_tst/com/SRC.csh dontCARE $portno"	; Ideally, second arg should be empty string, but zsystem doesn't like
							; '', nor "". Since SRC.csh tests for "on" for $2, we pass "dontCARE"
							; to workaround zsystem's problem
	s ^w=3			; ^w will also be from jnlfile
	zsy "$gtm_tst/com/wait_until_src_backlog_below.csh 0"	; wait for ^w to be xmited
	s ^x=4			; ^x from jnlpool
	zsy "$gtm_tst/com/wait_until_src_backlog_below.csh 0"	; wait for ^x to be xmited
	h
GTM_EOF

$fuser mumps.mjl >&! fuser.out	# Capture output of fuser for analyzing fuser anomaly (if any)

set attach_pid=`cat fuser.out |& $tst_awk '{if ("mumps.mjl:" == $1) {print $2}}'`

if ( "" != "$attach_pid" ) then
	set pidsrc=`$MUPIP replicate -source -checkhealth |& $tst_awk  '($1 == "PID") && ($2 ~ /[0-9]*/) { print $2 }'`
	echo "Process $attach_pid is STILL attached to journal file; source server pid is $pidsrc"
endif

$gtm_tst/com/dbcheck.csh -extract
exit 0
