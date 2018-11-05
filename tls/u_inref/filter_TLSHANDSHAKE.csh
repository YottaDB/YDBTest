#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# The below script filters TLSHANDSHAKE (and/or TLSIOERROR) messages from the source and/or receiver logs.
# The TLSHANDSHAKE messages can be encountered by either one or both of the replication logs.
# So, a simple wait_for_log.csh scheme won't work.

set time_src = $1
set time_rcvr = $2
set src_logfile = SRC_${time_src}.log
set rcv_logfile = RCVR_${time_rcvr}.log

# First wait for a successful connection. This is guaranteed to happen because after the initial handshake failure, the connection
# will fallback to plaintext and proceed successfully.
$MSR RUN INST2 "set msr_dont_trace; $gtm_tst/com/wait_for_log.csh -log $rcv_logfile -message 'New History Content'"

# At this point, we are guaranteed that either one or both of the replication log files has the TLSHANDSHAKE message.
# Filter them out.
# Starting TLS 1.3, it is possible the source server log does not have a TLSHANDSHAKE message but a TLSIOERROR message
# in case of an expired client certificate. Account for that too in the search below.
set stat1 = `$MSR RUN INST1 'set msr_dont_trace; $grep -q TLSHANDSHAKE '$src_logfile'; echo $status'`
if (0 == $stat1) then
	$MSR RUN INST1 "set msr_dont_trace; $msr_err_chk $src_logfile 'W-TLSHANDSHAKE' 'YDB-I-TEXT'"
	$gtm_tst/com/knownerror.csh $msr_execute_last_out "YDB-W-TLSHANDSHAKE"
else
	# We did not see a TLSHANDSHAKE message. Then it is possible we see a TLSIOERROR message. Check that.
	set stat1 = `$MSR RUN INST1 'set msr_dont_trace; $grep -q TLSIOERROR '$src_logfile'; echo $status'`
	if (0 == $stat1) then
		$MSR RUN INST1 "set msr_dont_trace; $msr_err_chk $src_logfile 'W-TLSIOERROR' 'YDB-I-TEXT'"
		$gtm_tst/com/knownerror.csh $msr_execute_last_out "YDB-W-TLSIOERROR"
	endif
endif

set stat2 = `$MSR RUN INST2 'set msr_dont_trace; $grep -q TLSHANDSHAKE '$rcv_logfile'; echo $status'`
if (0 == $stat2) then
	$MSR RUN INST2 "set msr_dont_trace; $msr_err_chk $rcv_logfile 'W-TLSHANDSHAKE' 'YDB-I-TEXT'"
	$gtm_tst/com/knownerror.csh $msr_execute_last_out "YDB-W-TLSHANDSHAKE"
endif

if ((0 != $stat1) && (0 != $stat2)) then
	echo "TEST-E-FAILED, YDB-W-TLSHANDSHAKE is expected in either $src_logfile or $rcv_logfile but found in neither."
	exit 1
endif

echo
echo "TEST-I-PASSED, TLSHANDSHAKE is found in replication logs as expected."
echo
