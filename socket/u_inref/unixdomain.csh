#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014, 2015 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Test unnamed Unix domain socket directed to stdin and stdout of M process
# sockpair sets up the stdin and stdout for both of the following cases and communicates over sockets with
# sockpairm.m in the non-split $P and with sockpairm2.m in the split $P case.
#
# First Case:
# In the first case(sockpairm) the same socket is used for both stdin and stdout so $P is not split
# In this case zshow "D" output is written over stdout back to sockpair via a socket
#
# Second Case:
# In the second case a different socket is created by sockpair for stdin so $P is split.  In this case the
# message "(From parent.)" is written from the parent to sockpairm2 over the second socket.
# This M process reads the message and writes it to its stdout which is written back to the parent for writing
# to its stdout(terminal) prior to the zshow "D"
# The zshow "D" will show a split device in the second case.
#
cat > sockpairm.m << MPROG1
start
        zshow "D"
	quit
MPROG1

cat > sockpairm2.m << MPROG2
start
	read x:120
	write x,!
        zshow "D"
	quit
MPROG2

$gt_cc_compiler -o sockpair -I$gtm_tst/$tst/inref -I$gtm_dist $gtm_tst/$tst/inref/sockpair.c $gt_ld_syslibs
$echoline
echo '************************* non-split $P unix domain socket ***************************'
$echoline
sockpair
$echoline
echo '************************* split $P unix domain socket ***************************'
$echoline
sockpair 1
