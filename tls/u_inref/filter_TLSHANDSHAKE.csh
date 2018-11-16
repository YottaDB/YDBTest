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

if ($3 == "ALLOW_REPLNOTLS") then
	# This is a special indication by the caller that if TLS 1.3 is being used, allow either TLSIOERROR or REPLNOTLS
	# in the source server log file.
	set allow_replnotls = 1
else
	set allow_replnotls = 0
endif

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
else if (0 == $allow_replnotls) then
	# We did not see a TLSHANDSHAKE message. Then it is possible we see a TLSIOERROR message. Check that.
	set stat1 = `$MSR RUN INST1 'set msr_dont_trace; $grep -q TLSIOERROR '$src_logfile'; echo $status'`
	if (0 == $stat1) then
		$MSR RUN INST1 "set msr_dont_trace; $msr_err_chk $src_logfile 'W-TLSIOERROR' 'YDB-I-TEXT'"
		$gtm_tst/com/knownerror.csh $msr_execute_last_out "YDB-W-TLSIOERROR"
	endif
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
	echo "TEST-E-FAILED, YDB-W-TLSHANDSHAKE is expected in either $src_logfile or $rcv_logfile but found in neither."
	exit 1
endif

echo
echo "TEST-I-PASSED, TLSHANDSHAKE is found in replication logs as expected."
echo
