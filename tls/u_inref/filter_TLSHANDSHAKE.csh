#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2026 YottaDB LLC and/or its subsidiaries.	#
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

# At this point, we are guaranteed that either one or both of the replication log files has the TLSHANDSHAKE message, or
# that the source server log has a TLSIOERROR or REPLNOTLS message instead. Filter them out.
# Starting TLS 1.3, it is possible the source server log has neither a TLSHANDSHAKE nor a TLSIOERROR message, but a REPLNOTLS
# message instead, when the receiver server disconnects on the invalid certificate before the source server sends its first
# application data. Account for all three in the search below.
set stat1 = `$MSR RUN INST1 'set msr_dont_trace; $grep -q TLSHANDSHAKE '$src_logfile'; echo $status'`
if (0 == $stat1) then
	$MSR RUN INST1 "set msr_dont_trace; $msr_err_chk $src_logfile 'W-TLSHANDSHAKE' 'YDB-I-TEXT'"
	$gtm_tst/com/knownerror.csh $msr_execute_last_out "YDB-W-TLSHANDSHAKE"
else
	# We did not see a TLSHANDSHAKE message. Allow for a TLSIOERROR or REPLNOTLS message in source server log.
	# In this case, we cannot include either the TLSIOERROR or REPLNOTLS warning full text in the reference file
	# (to keep reference file deterministic) so we just check the occurrence of one of these messages and signal success.
	set stat1 = `$MSR RUN INST1 'set msr_dont_trace; $grep -q TLSIOERROR '$src_logfile'; echo $status'`
	set stat2 = `$MSR RUN INST1 'set msr_dont_trace; $grep -q W-REPLNOTLS '$src_logfile'; echo $status'`
	if ((0 == $stat1) || (0 == $stat2)) then
		echo "TEST-I-PASS, Found a TLSIOERROR or REPLNOTLS message in source server log file as expected"
		if (0 == $stat1) then
			# We know a YDB-W-TLSIOERROR showed up in the source server log. Remove it as otherwise the
			# test framework will catch it later causing a test failure.
			$gtm_tst/com/knownerror.csh $src_logfile "YDB-W-TLSIOERROR"
		else
			# We know a YDB-W-REPLNOTLS showed up in the source server log. Remove it as otherwise the
			# test framework will catch it later causing a test failure.
			$gtm_tst/com/knownerror.csh $src_logfile "YDB-W-REPLNOTLS"
		endif
	else
		echo "TEST-E-FAIL, Expected but did not find either TLSIOERROR or REPLNOTLS message in source server log file"
	endif
endif

set stat2 = `$MSR RUN INST2 'set msr_dont_trace; $grep -q TLSHANDSHAKE '$rcv_logfile'; echo $status'`
if (0 == $stat2) then
	$MSR RUN INST2 "set msr_dont_trace; $msr_err_chk $rcv_logfile 'W-TLSHANDSHAKE' 'YDB-I-TEXT'"
	$gtm_tst/com/knownerror.csh $msr_execute_last_out "YDB-W-TLSHANDSHAKE"
endif

if ((0 != $stat1) && (0 != $stat2)) then
	echo "TEST-E-FAILED, Expected TLSHANDSHAKE or TLSIOERROR in $src_logfile, or TLSHANDSHAKE in $rcv_logfile."
	exit 1
endif

# Suppress TLSCONNINFO messages in the source server log. These are expected when the TLS handshake succeeds
# and the source server then tries to log information about the peer certificate and the connection, which fails
# because the certificate is invalid, before the connection is torn down and falls back to plaintext.
$gtm_tst/com/knownerror.csh $src_logfile "YDB-W-TLSCONNINFO"

echo
echo "TEST-I-PASSED, TLSHANDSHAKE is found in replication logs as expected."
echo
