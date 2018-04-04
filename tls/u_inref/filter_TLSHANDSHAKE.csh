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
# The below script filters TLSHANDSHAKE messages from the source and/or receiver logs. The TLSHANDSHAKE messages can be encountered
# by either one or both of the replication logs. So, a simple wait_for_log.csh scheme won't work.

set time_src = $1
set time_rcvr = $2
set src_logfile = SRC_${time_src}.log
set rcv_logfile = RCVR_${time_rcvr}.log
set outfile = chk_TLSHANDSHAKE_${time_src}_${time_rcvr}.outx

# First wait for a successful connection. This is guaranteed to happen because after the initial handshake failure, the connection
# will fallback to plaintext and proceed successfully.
$MSR RUN INST2 "set msr_dont_trace; $gtm_tst/com/wait_for_log.csh -log $rcv_logfile -message 'New History Content'"

# At this point, we are guaranteed that either one or both of the replication log files has the TLSHANDSHAKE message. Filter them
# out.
set stat1 = `$MSR RUN INST1 'set msr_dont_trace; $grep -q TLSHANDSHAKE '$src_logfile'; echo $status'`
if (0 == $stat1) then
	$MSR RUN INST1 "set msr_dont_trace; $msr_err_chk $src_logfile 'W-TLSHANDSHAKE' 'YDB-I-TEXT'" >>&! $outfile
	$gtm_tst/com/knownerror.csh $msr_execute_last_out "GTM-W-TLSHANDSHAKE"
endif

set stat2 = `$MSR RUN INST2 'set msr_dont_trace; $grep -q TLSHANDSHAKE '$rcv_logfile'; echo $status'`
if (0 == $stat2) then
	$MSR RUN INST2 "set msr_dont_trace; $msr_err_chk $rcv_logfile 'W-TLSHANDSHAKE' 'YDB-I-TEXT'" >>&! $outfile
	$gtm_tst/com/knownerror.csh $msr_execute_last_out "GTM-W-TLSHANDSHAKE"
endif

if ((0 != $stat1) && (0 != $stat2)) then
	echo "TEST-E-FAILED, GTM-W-TLSHANDSHAKE is expected in either $src_logfile or $rcv_logfile but found in neither."
	exit 1
endif

echo
echo "TEST-I-PASSED, TLSHANDSHAKE is found in replication logs as expected."
echo

#$gtm_tst/com/knownerror.csh multisite_replic.log "GTM-W-TLSHANDSHAKE"
