#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# disable implicit mprof testing to avoid interference with explicit mprof testing
unsetenv gtm_trace_gbl_name
echo ""
echo "D9D04-002317 mprof and tptimeout"
echo "make sure op_mprof routines restored"
# delta is set to be 2 in ztrapit.m, if the process times out in less than timeout+delta, it is assumed to pass.
set timeout=10
set longwait=20
$gtm_tst/com/dbcreate.csh mumps 1 255 1000 1024 500 4096
#
$GTM <<END
w "Testing for mprof",!
d ^mproftp($timeout,$longwait)
h
END
$GTM << END
if \$data(^errmsg)  zwr ^errmsg
END

$gtm_tst/com/dbcheck.csh
