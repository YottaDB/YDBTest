#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set server_pid = `cat gtcm_server.pid`

$ps | $grep -v grep | $grep " $server_pid " >& gtcm_ps_${server_pid}.out
$gtm_tst/com/is_proc_alive.csh $server_pid

if ($status) then
	echo "GT.CM Server is already gone. Nothing to crash"
	exit 1
endif

$kill9 $server_pid
echo "After kill..." >>& gtcm_ps.out
$ps | $grep -v grep | $grep " $server_pid " >>& gtcm_ps_${server_pid}.out


# since it is not necessary anymore to "reserve" the port, remove /tmp/test_${portno}.txt
$gtm_tst/com/portno_release.csh
