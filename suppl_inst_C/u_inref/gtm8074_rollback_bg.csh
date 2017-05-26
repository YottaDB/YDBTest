#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Helper script used by gtm8074.csh to background rollback and kill it after a while
#
$MUPIP journal -rollback -backward -verbose -fetchresync=$1 -verbose "*" >&! rollback1.log &	# BYPASSOK("-rollback")
	# mupip_journal.csh is not used above because the test relies on $! being the pid of the
	# mupip journal rollback process. Passing a .csh script would cause $! to be the pid of
	# the .csh script and the rollback pid to be a child pid which is not directly accessible here.
echo $! >&! rollback_pid.txt
set pid = `cat rollback_pid.txt`
$gtm_tst/com/wait_for_log.csh -log rollback1.log -message "Waiting for a connection" -waitcreation
$kill9 $pid
