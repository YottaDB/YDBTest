#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

if ("pro" == "$tst_image") then
	exit
endif
echo ""
$echoline
echo "Create database and start replication"
$echoline
echo ""
$gtm_tst/com/dbcreate.csh mumps 1

echo ""
$echoline
echo "Wait for connection to be established"
$echoline
echo ""
setenv start_time `cat start_time`
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/RCVR_${start_time}.log.updproc -message 'New History Content' -duration 30"

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 84

echo ""
$echoline
echo "Shutdown Receiver Server and do a concurrent argument-less MUPIP RUNDOWN"
$echoline
echo ""
($sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replic -receiv -shutdown -timeout=0" >&! recv_shut.out & 	\
		; echo $! >&! recv_shut_pid.log)	>&! bg_recv_shut.out

# Wait until the whitebox test case gives us a go
$gtm_tst/com/wait_for_log.csh -log recv_shut.out -message 'GTMRECV_SHUTDOWN' -duration 30

# Now, start an argument-less rundown
$MUPIP rundown >&! mupip_rundown1.outx
# Wait for shutdown command to complete
set recv_shut_pid = `cat recv_shut_pid.log`
$gtm_tst/com/wait_for_proc_to_die.csh $recv_shut_pid 120
cat recv_shut.out

echo ""
$echoline
echo "Shutdown Primary Source Server and do a concurrent argument-less MUPIP RUNDOWN"
$echoline
echo ""
($MUPIP replic -source -shutdown -timeout=0 >&! src_shut.out & ; echo $! >&! src_shut_pid.log) >&! bg_src_shut.out

# Wait until the whitebox test case gives us a go
$gtm_tst/com/wait_for_log.csh -log src_shut.out -message 'GTMSOURCE_SHUTDOWN' -duration 30

# Now, start an argument-less rundown
$MUPIP rundown >&! mupip_rundown1.outx
# Wait for shutdown command to complete
set src_shut_pid = `cat src_shut_pid.log`
$gtm_tst/com/wait_for_proc_to_die.csh $src_shut_pid 120
cat src_shut.out

unsetenv gtm_white_box_test_case_enable

# Manually shutdown the passive source server
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replic -source -shutdown -timeout=0" >&! passive_src_shut.out

$gtm_tst/com/portno_release.csh
$gtm_tst/com/dbcheck.csh -noshut
