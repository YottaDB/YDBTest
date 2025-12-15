#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set tnum = $1
foreach server ("SOURCE" "RECEIVER")
	set log = "${tnum}-${server}start.logx"
	if ($server == "RECEIVER") then
		# Include the path to the remote if checking the replication server log
		set log = "${SEC_SIDE}/$log"
	endif
	foreach buffer ("SNDBUF" "RCVBUF")
		set bufspec = "none"
		set buf_expected = `cat ${tnum}-${server}_${buffer}-exp.logx`

		# Get timestamp for setsockopt(..., SO_$buffer, ...) on $server server
		set sockbufts = `grep "SO_$buffer" $log | head -1 | sed 's/^.* \([0-9]\+\.[0-9]\+\).*setsockopt.*$/\1/g'`
		# Get timestamp for write(..., SO_$buffer, ...) on $server server
		if ($server == "SOURCE") then
			# Connection established message of the format: "Connected to secondary, using TCP send buffer size [0-9]* receive buffer size [0-9]*"
			set msg = "Connected to secondary"
			$gtm_tst/com/wait_for_log.csh -log $log -message $msg
		else
			# Connection established message of the format: "Connection established, using TCP send buffer size [0-9]* receive buffer size [0-9]*"
			set msg = "Connection established"
			$gtm_tst/com/wait_for_log.csh -log $log -message $msg
		endif
		set connestts = `grep "$msg" $log | sed 's/^.* \([0-9]\+\.[0-9]\+\).*write.*$/\1/g'`

		# Set buffer-specific variables for use in various checks below
		if ($buffer == "SNDBUF") then
			if ($server == "SOURCE") then
				set min = $source_min_SNDBUF
			else
				set min = $receiver_min_SNDBUF
			endif
			set opt = "-sendbuffsize"
			set optbuf = "send"
			set bufname = "send"
			set buf_reported = `grep "$msg" $log | sed 's/^.*send buffer size \([0-9]*\).*$/\1/g'`
			# The buffer size reported by the server should be double that expected by the test,
			# per the doubling done by the kernel as described in the release note at
			# https://gitlab.com/YottaDB/DB/YDBTest/-/issues/696. However, the value expected to be doubled
			# depends on whether the expected value exceeds the system maximum for the given buffer.
			# In the latter case, expect double the system max rather than the value specified by the test.
			if ("T1" == $tnum) then
				# In the case of Test 1, the value is set below the system default,
				# so the latter will take precedence and not be doubled since it is already
				# in effect and no additional setsockopt calls are made
				set dbuf_expected = $default_SNDBUF
			else if ($buf_expected > $max_SNDBUF) then
				set dbuf_expected = $max_SNDBUF
			else
				set dbuf_expected = $buf_expected
			endif
			if ($buf_expected == $default_SNDBUF) then
				# $opt set to the system default value, expect no setsockopt output for SO_SNDBUF
				set bufspec = "system default"
			else if (($buf_expected == $receiver_def_SNDBUF) && ($server == "RECEIVER")) then
				# $opt set to the internal default value, expect no setsockopt output for SO_SNDBUF
				set bufspec = "internal default"
			else if (($buf_expected == $source_def_SNDBUF) && ($server == "SOURCE")) then
				# $opt set to the internal default value, expect no setsockopt output for SO_SNDBUF
				# set bufspec = "internal default"
				set bufspec = "none"
			endif
		else
			if ($server == "SOURCE") then
				set min = $source_min_RCVBUF
			else
				set min = $receiver_min_RCVBUF
			endif
			set opt = "-recvbuffsize"
			set optbuf = "recv"
			set bufname = "receive"
			set buf_reported = `grep "$msg" $log | sed 's/^.*receive buffer size \([0-9]*\).*$/\1/g'`
			# The buffer size reported by the server should be double that expected by the test,
			# per the doubling done by the kernel as described in the release note at
			# https://gitlab.com/YottaDB/DB/YDBTest/-/issues/696. However, the value expected to be doubled
			# depends on whether the expected value exceeds the system maximum for the given buffer.
			# In the latter case, expect double the system max rather than the value specified by the test.
			if ("T1" == $tnum) then
				# In the case of Test 1, the value is set below the system default,
				# so the latter will take precedence and not be doubled since it is already
				# in effect and no additional setsockopt calls are made
				set dbuf_expected = $default_RCVBUF
			else if ($buf_expected > $max_RCVBUF) then
				set dbuf_expected = $max_RCVBUF
			else
				set dbuf_expected = $buf_expected
			endif
			if ($buf_expected == $default_RCVBUF) then
				# $opt set to the system default value, expect no setsockopt output for SO_RCVBUF
				set bufspec = "system default"
			else if (($buf_expected == $source_def_RCVBUF) && ($server == "SOURCE")) then
				# $opt set to the internal default value, expect no setsockopt output for SO_RCVBUF
				set bufspec = "internal default"
			endif
		endif

		if (("$bufspec" != "none") && ("T1" != $tnum)) then
			echo "# Confirm SO_$buffer not set by $server server"
			$gtm_tst/com/wait_for_log.csh -log $log -message "exited with 0"
			grep SO_$buffer $log
			if ($status == 1) then
				echo -n "PASS: SO_$buffer not"
			else
				echo -n "FAIL: SO_$buffer"
			endif
			echo " set by $server server, when $opt set to $bufspec"
			continue
		endif
		if ("T1" == $tnum) then
			$gtm_tst/com/wait_for_log.csh -log $log -message BUFFSIZETOOSMALL
			set buf_actual = `grep BUFFSIZETOOSMALL $log | grep $optbuf | head -1 | sed 's/.*"GTM-W-BUFFSIZETOOSMALL, TCP .* buffer size passed to .* too small, setting to minimum size of \([0-9]*\).".*$/\1/g'`
		else
			$gtm_tst/com/wait_for_log.csh -log $log -message $buffer
			set buf_actual = `grep "^.*setsockopt.*SO_$buffer" $log | head -1 | sed 's/^.*, \[\([0-9]*\)\].*/\1/'`
			#  setsockopt not called for T1 scenario, so skip the below logic in that case
			echo "# Confirm $server SO_$buffer set BEFORE connection established"
			if !($?sockbufts) then
				echo "FAIL: SO_$buffer NOT set by setsockopt in $log"
				continue
			endif
			if !($?connestts) then
				echo "FAIL: Connection not established in $log"
				continue
			endif
			if (1 == `echo "$sockbufts < $connestts" | bc`) then
				echo "PASS: SO_$buffer set prior to connection being established"
			else
				echo "FAIL: SO_$buffer NOT set prior to connection being established: SO_$buffer set at $sockbufts, but connection established at $connestts"
			endif
		endif

		echo "# Confirm setsockopt on $server set SO_$buffer=$buf_expected"
		if ($?buf_actual) then
			if ($buf_expected != $buf_actual) then
				echo "FAIL: SO_$buffer=$buf_actual, but $opt=$buf_expected expected"
			else
				echo "PASS: SO_$buffer=$buf_actual for $opt=$buf_expected"
			endif
		else
			echo "FAIL: SO_$buffer not set on server $server"
			continue
		endif

		if ("T1" == $tnum) then
			# In this case since the kernel/tcp-stack may dynamically set a value that cannot be easily determined in advance.
			# Since the kernel/tcp-stack is not part of GT.M or YottaDB, it is okay to check only for the minimum value to satisfy
			# the requirement that the release note line `act as if the minimum size had been specified instead` is tested.
			# See the discussion at https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2474#note_2899738066 for details.
			echo "# Confirm $server reports at least $min for $bufname buffer, i.e. the internal minimum"
		else
			@ doublebuf = $dbuf_expected * 2
			echo "# Confirm $server reports 2x $dbuf_expected for $bufname buffer, i.e. $doublebuf"
		endif
		if ($?buf_reported) then
			if ("T1" == $tnum) then
				if ($buf_reported < $min) then
					echo "FAIL: $server reports $bufname buffer set to $buf_reported, but at least $min expected"
					continue
				endif
			else
				if ($doublebuf != $buf_reported) then
					echo "FAIL: $server reports $bufname buffer set to $buf_reported, but $doublebuf expected"
					continue
				endif
			endif
			echo "PASS: $server reports $bufname buffer set to $buf_reported"
		else
			echo "FAIL: $server did not report $bufname buffer set"
			continue
		endif
	end
end
