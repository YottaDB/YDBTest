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
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-F235980 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-002_Release_Notes.html#GTM-F235980)

GT.M recognizes the -[NO]{SEND|RECV}BUFFSIZE=n qualifiers for use with MUPIP REPLICATE -{SOURCE|RECEIVER} -START invocations. These qualifiers affect the TCP send and receive buffers associated with the socket GT.M uses for replication, rather than the receive/journal pools. When invoked with -{SEND|RECV}BUFFSIZE=n, where n is a positive decimal or hexadecimal (0x) integer, GT.M attempts to increase the specified socket buffer size to match the provided value. If the specified buffer is already larger than the provided value, GT.M does not attempt to reduce its size. By default, GT.M attempts to increase the size of the send buffer (SO_SNDBUF) or receive buffer (SO_RCVBUF) if either is smaller than the internal default value specified below.

		SO_SNDBUF	SO_RCVBUF
Source		1MiB		1KiB
Receiver	1KiB		1MiB

If a user requests a size for either buffer smaller than necessary to support GT.M replication, GT.M will print a BUFFSIZETOOSMALL warning, act as if the minimum size had been specified instead, and continue. Due to a quirk in how the Linux kernel reports socket buffer sizes, users of GT.M on Linux can expect GT.M to report a final size approximately twice what is requested; the additional space is used internally by the kernel. When invoked with -NO{SEND|RECV}BUFFSIZE, GT.M leaves the management of the initial size of the specified buffer to the execution environment, including the system defaults, local configuration settings, and operating system. In some cases, such as when the operating system dynamically manages the size of the relevant buffers, this can may lead to better performance in conditions which call for larger sizes than the GT.M default. Previously GT.M enforced a fixed minimum size for each buffer and did not permit the explicit request of receive and send buffer sizes. In addition, GT.M now correctly sets the buffer sizes, when warranted, before establishing a connection. Previously, GT.M waited until after the source and receiver had established a connection to perform any modification of the buffer sizes, which prevented the TCP connection from taking full advantage of any increase in size. (GTM-F236066) (GTM-F235980)

CAT_EOF
echo

if ($?gtm_db_counter_sem_incr) then
	if ($gtm_db_counter_sem_incr > 4096) then
		setenv gtm_db_counter_sem_incr 4096
	endif
endif
$MULTISITE_REPLIC_PREPARE 2

# Create a database for test routine data
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out

cp $gtm_tst/$tst/inref/setbufsize.sh .
cp $gtm_tst/$tst/inref/logcheck.csh .

echo "# Initialize variables with default and max buffer size limits"
setenv default_SNDBUF `sysctl net.ipv4.tcp_wmem | sed 's/.*=[[:space:]]*[0-9]*[[:space:]]*\([0-9]*\)[[:space:]]*[0-9]*/\1/g'`	# System default SO_SNDBUF size
setenv default_RCVBUF `sysctl net.ipv4.tcp_rmem | sed 's/.*=[[:space:]]*[0-9]*[[:space:]]*\([0-9]*\)[[:space:]]*[0-9]*/\1/g'`	# System default SO_RCVBUF size
setenv max_SNDBUF `cat /proc/sys/net/core/wmem_max`	# System max SO_SNDBUF size
setenv max_RCVBUF `cat /proc/sys/net/core/rmem_max`	# System max SO_RCVBUF size

set INT_MAX = 2147483647
set KiB = 1024
set MiB = 1048576
setenv source_def_SNDBUF $MiB	# Originating instance internal send default: 1 MiB
setenv source_def_RCVBUF $KiB	# Originating instance internal receive default: 1 KiB
setenv receiver_def_SNDBUF $KiB	# Replicating instance internal send default: 1 KiB
setenv receiver_def_RCVBUF $MiB	# Replicating instance internal receive default: 1 MiB

setenv source_min_SNDBUF 16384	# Originating instance minimum send buffer size: 16 KiB
setenv source_min_RCVBUF 512	# Originating instance minimum receive buffer size: 512 bytes
setenv receiver_min_SNDBUF 512	# Replicating instance minimum send buffer size: 512 bytes
setenv receiver_min_RCVBUF 16384	# Replicating instance minimum receive buffer size: 16 KiB
echo

echo "### Test 1: MUPIP REPLICATE with -SENDBUFFSIZE and -RECVBUFFSIZE set too low"
set tnum = T1

echo "## Source server"
@ lt_source_min_SNDBUF = $source_min_SNDBUF - 1
@ lt_source_min_RCVBUF= $source_min_RCVBUF - 1
echo "#  1. -SENDBUFFSIZE between 1 and 1 less than the minimum ($source_min_SNDBUF - 1), expect the minimum value ($source_min_SNDBUF)"
echo "#  2. -RECVBUFFSIZE between 1 and 1 less than the minimum ($source_min_RCVBUF - 1), expect the minimum value ($source_min_RCVBUF)"
# Run MSR instances with strace to track setsockopt calls
setenv gtm_test_replic_prefix "strace -ttt -s 256 -f -o ${tnum}-SOURCEstart.logx -e trace=setsockopt,write,writev"
setenv gtm_test_sendbuffsize "`setbufsize.sh $tnum SOURCE SNDBUF 1 $lt_source_min_SNDBUF $source_min_SNDBUF`"
setenv gtm_test_recvbuffsize "`setbufsize.sh $tnum SOURCE RCVBUF 1 $lt_source_min_RCVBUF $source_min_RCVBUF`"
echo "# Start the source server"
$MSR STARTSRC INST1 INST2

echo "## Receiver server"
echo "#  1. -SENDBUFFSIZE between 1 and 1 less than the minimum ($receiver_min_SNDBUF - 1), expect the minimum value ($receiver_min_SNDBUF)"
echo "#  2. -RECVBUFFSIZE between 1 and 1 less than the minimum ($receiver_min_RCVBUF - 1), expect the minimum value ($receiver_min_RCVBUF)"
@ lt_receiver_min_SNDBUF = $receiver_min_SNDBUF - 1
@ lt_receiver_min_RCVBUF= $receiver_min_RCVBUF - 1
# Run MSR instances with strace to track setsockopt calls
setenv gtm_test_replic_prefix "strace -ttt -s 256 -f -o ${tnum}-RECEIVERstart.logx -e trace=setsockopt,write,writev"
setenv gtm_test_sendbuffsize "`setbufsize.sh $tnum RECEIVER SNDBUF 1 $lt_receiver_min_SNDBUF $receiver_min_SNDBUF`"
setenv gtm_test_recvbuffsize "`setbufsize.sh $tnum RECEIVER RCVBUF 1 $lt_receiver_min_RCVBUF $receiver_min_RCVBUF`"
echo "# Start the receiver server"
$MSR STARTRCV INST1 INST2

echo "## Check output for BUFFSIZETOOSMALL and correct SO_SNDBUF and SO_RCVBUF values"
./logcheck.csh $tnum
echo "# Expect BUFFSIZETOOSMALL errors"
grep BUFFSIZETOOSMALL $tnum-SOURCEstart.logx | sed 's/^.*"\(GTM-W-BUFFSIZETOOSMALL, TCP .* buffer size passed to .* too small, setting to minimum size of [0-9]*.\)".*$/\1/g'
grep BUFFSIZETOOSMALL $SEC_SIDE/$tnum-RECEIVERstart.logx | sed 's/^.*"\(GTM-W-BUFFSIZETOOSMALL, TCP .* buffer size passed to .* too small, setting to minimum size of [0-9]*.\)".*$/\1/g'
$gtm_tst/com/check_error_exist.csh srcstartcmd.out BUFFSIZETOOSMALL >& ${tnum}SOURCE.errx
$gtm_tst/com/check_error_exist.csh $SEC_SIDE/recvstartcmd.out BUFFSIZETOOSMALL >& ${tnum}RECEIVER.errx
echo "# Stop the source and receiver servers"
$MSR STOP INST1 INST2
echo

echo "### Test 2: MUPIP REPLICATE without -SENDBUFFSIZE or -RECVBUFFSIZE"
set tnum = T2
unsetenv gtm_test_sendbuffsize
unsetenv gtm_test_recvbuffsize
echo "# Start the source server"
setenv gtm_test_replic_prefix "strace -ttt -s 256 -f -o ${tnum}-SOURCEstart.logx -e trace=setsockopt,write,writev"
$MSR STARTSRC INST1 INST2
echo "# Start the receiver server"
setenv gtm_test_replic_prefix "strace -ttt -s 256 -f -o ${tnum}-RECEIVERstart.logx -e trace=setsockopt,write,writev"
$MSR STARTRCV INST1 INST2
echo "## Check output for correct SO_SNDBUF and SO_RCVBUF values"
echo "# On the source server, expect SO_SNDBUF=$source_def_SNDBUF (GT.M internal default value) and SO_RCVBUF unset"
set log = "${tnum}-SOURCEstart.logx"
set buffer = SNDBUF
$gtm_tst/com/wait_for_log.csh -log $log -message $buffer
set actual_source_SNDBUF = `grep "^.*setsockopt.*SO_$buffer" "$log" | head -1 | sed 's/^.*, \[\([0-9]*\)\].*/\1/'`
if ($source_def_SNDBUF != $actual_source_SNDBUF) then
	echo -n "FAIL"
else
	echo -n "PASS"
endif
echo ": SO_SNDBUF=$actual_source_SNDBUF, $source_def_SNDBUF expected"
grep SO_RCVBUF $log
if ($status == 1) then
	echo "PASS: SO_RCVBUF not set by source instance, -RECVBUFFSIZE not set"
else
	echo "FAIL: SO_RCVBUF set by source instance, -RECVBUFFSIZE not set"
endif
echo "# On the replicating server, expect SO_RCVBUF=$receiver_def_RCVBUF (GT.M internal default value) and SO_SNDBUF unset"
set log = "$SEC_SIDE/${tnum}-RECEIVERstart.logx"
set buffer = RCVBUF
$gtm_tst/com/wait_for_log.csh -log $log -message $buffer
set actual_receiver_RCVBUF = `grep "^.*setsockopt.*SO_$buffer" "$log" | head -1 | sed 's/^.*, \[\([0-9]*\)\].*/\1/'`
if ($receiver_def_RCVBUF != $actual_receiver_RCVBUF) then
	echo -n "FAIL"
else
	echo -n "PASS"
endif
echo ": SO_RCVBUF=$actual_receiver_RCVBUF, $receiver_def_RCVBUF expected"
grep SO_SNDBUF $log
if ($status == 1) then
	echo "PASS: SO_SNDBUF not set by replicating instance, -SENDBUFFSIZE not set"
else
	echo "FAIL: SO_SNDBUF set by replicating instance, -SENDBUFFSIZE not set"
endif
echo "# Stop the source and receiver servers"
$MSR STOP INST1 INST2
echo

echo "### Test 3: MUPIP REPLICATE with -SENDBUFFSIZE and -RECVBUFFSIZE between the GT.M minimum and system default SO_SNDBUF and SO_RCVBUF values"
set tnum = T3
echo "## Source server"
echo "#  1. -SENDBUFFSIZE between minimum ($source_min_SNDBUF) and system default ($default_SNDBUF), expect no change in value"
echo "#  2. -RECVBUFFSIZE between minimum ($source_min_RCVBUF) and system default ($default_RCVBUF), expect no change in value"
setenv gtm_test_replic_prefix "strace -ttt -s 256 -f -o ${tnum}-SOURCEstart.logx -e trace=setsockopt,write,writev"
setenv gtm_test_sendbuffsize "`setbufsize.sh $tnum SOURCE SNDBUF $source_min_SNDBUF $default_SNDBUF`"
setenv gtm_test_recvbuffsize "`setbufsize.sh $tnum SOURCE RCVBUF $source_min_RCVBUF $default_RCVBUF`"
echo "# Start the source server"
$MSR STARTSRC INST1 INST2
echo "## Receiver server"
echo "#  1. -SENDBUFFSIZE between minimum ($receiver_min_SNDBUF) and system default ($default_SNDBUF), expect no change in value"
echo "#  2. -RECVBUFFSIZE between minimum ($receiver_min_RCVBUF) and system default ($default_RCVBUF), expect no change in value"
setenv gtm_test_replic_prefix "strace -ttt -s 256 -f -o ${tnum}-RECEIVERstart.logx -e trace=setsockopt,write,writev"
setenv gtm_test_sendbuffsize "`setbufsize.sh $tnum RECEIVER SNDBUF $receiver_min_SNDBUF $default_SNDBUF`"
setenv gtm_test_recvbuffsize "`setbufsize.sh $tnum RECEIVER RCVBUF $receiver_min_RCVBUF $default_RCVBUF`"
echo "# Start the receiver server"
$MSR STARTRCV INST1 INST2
# Connection established message of the format: "Connected to secondary, using TCP send buffer size [0-9]* receive buffer size [0-9]*"
$gtm_tst/com/wait_for_log.csh -log "${tnum}-SOURCEstart.logx" -message "Connected to secondary"
# Connection established message of the format: "Connection established, using TCP send buffer size [0-9]* receive buffer size [0-9]*"
$gtm_tst/com/wait_for_log.csh -log "${SEC_SIDE}/${tnum}-RECEIVERstart.logx" -message "Connection established"
echo "## Check output for correct SO_SNDBUF and SO_RCVBUF values"
echo "## Expect no change to either buffer on either server, since the system default is chosen whenever it exceeds the GT.M minimum."
foreach server ("SOURCE" "RECEIVER")
	if ("$server" == "RECEIVER") then
		set log = "$SEC_SIDE/${tnum}-${server}start.logx"
	else
		set log = "${tnum}-${server}start.logx"
	endif
	foreach buffer ("SNDBUF" "RCVBUF")
		grep $buffer $log
		if ($status == 1) then
			echo "PASS: No change to $buffer on $server server"
		else
			echo "FAIL: $buffer unexpectedly changed on $server server"
		endif
	end
end
echo "# Stop the source and receiver servers"
$MSR STOP INST1 INST2
echo

echo "### Test 4: MUPIP REPLICATE with -SENDBUFFSIZE and -RECVBUFFSIZE between the system default SO_SNDBUF and SO_RCVBUF values and 1 MiB"
set tnum = T4
echo "## Source server"
echo "#  1. -SENDBUFFSIZE between the system default ($default_SNDBUF) and 1 MiB ($MiB), expect the specified value"
echo "#  2. -RECVBUFFSIZE between the system default ($default_RCVBUF) and 1 MiB ($MiB), expect the specified value"
setenv gtm_test_replic_prefix "strace -ttt -s 256 -f -o ${tnum}-SOURCEstart.logx -e trace=setsockopt,write,writev"
setenv gtm_test_sendbuffsize "`setbufsize.sh $tnum SOURCE SNDBUF $default_SNDBUF $MiB`"
setenv gtm_test_recvbuffsize "`setbufsize.sh $tnum SOURCE RCVBUF $default_RCVBUF $MiB`"
echo "# Start the source server"
$MSR STARTSRC INST1 INST2
echo "## Receiver server"
echo "#  1. -SENDBUFFSIZE between the system default ($default_SNDBUF) and 1 MiB ($MiB), expect the specified value"
echo "#  2. -RECVBUFFSIZE between the system default ($default_RCVBUF) and 1 MiB ($MiB), expect the specified value"
setenv gtm_test_replic_prefix "strace -ttt -s 256 -f -o ${tnum}-RECEIVERstart.logx -e trace=setsockopt,write,writev"
setenv gtm_test_sendbuffsize "`setbufsize.sh $tnum RECEIVER SNDBUF $default_SNDBUF $MiB`"
setenv gtm_test_recvbuffsize "`setbufsize.sh $tnum RECEIVER RCVBUF $default_RCVBUF $MiB`"
echo "# Start the receiver server"
$MSR STARTRCV INST1 INST2
echo "## Check output for correct SO_SNDBUF and SO_RCVBUF values"
./logcheck.csh $tnum
echo "# Stop the source and receiver servers"
$MSR STOP INST1 INST2
echo

echo "### Test 5: MUPIP REPLICATE with -SENDBUFFSIZE and -RECVBUFFSIZE at exactly their internal default values"
set tnum = T5
echo "## Source server"
setenv gtm_test_replic_prefix "strace -ttt -s 256 -f -o ${tnum}-SOURCEstart.logx -e trace=setsockopt,write,writev"
echo "# Set gtm_test_sendbuffsize to the internal default SO_SNDBUF value ($source_def_SNDBUF)"
setenv gtm_test_sendbuffsize "`setbufsize.sh $tnum SOURCE SNDBUF $source_def_SNDBUF $source_def_SNDBUF`"
echo "# Set gtm_test_recvbuffsize to the internal default SO_RCVBUF value ($source_def_RCVBUF)"
setenv gtm_test_recvbuffsize "`setbufsize.sh $tnum SOURCE RCVBUF $source_def_RCVBUF $source_def_RCVBUF`"
echo "# Start the source server"
$MSR STARTSRC INST1 INST2

echo "## Receiver server"
setenv gtm_test_replic_prefix "strace -ttt -s 256 -f -o ${tnum}-RECEIVERstart.logx -e trace=setsockopt,write,writev"
echo "# Set gtm_test_sendbuffsize to the internal default SO_SNDBUF value ($source_def_SNDBUF)"
setenv gtm_test_sendbuffsize "`setbufsize.sh $tnum RECEIVER SNDBUF $receiver_def_SNDBUF $receiver_def_SNDBUF`"
echo "# Set gtm_test_recvbuffsize to the internal default SO_RCVBUF value ($source_def_RCVBUF)"
setenv gtm_test_recvbuffsize "`setbufsize.sh $tnum RECEIVER RCVBUF $receiver_def_RCVBUF $receiver_def_RCVBUF`"
echo "# Start the receiver server"
$MSR STARTRCV INST1 INST2
echo "## Check output for correct SO_SNDBUF and SO_RCVBUF values"
./logcheck.csh $tnum
echo "# Stop the source and receiver servers"
$MSR STOP INST1 INST2
echo

echo "### Test 6: MUPIP REPLICATE with -SENDBUFFSIZE and -RECVBUFFSIZE between the larger of the system default and the internal default, and INT_MAX (to avoid NUMERR from MUPIP CLI)"
set tnum = T6
echo "## Source server"
setenv gtm_test_replic_prefix "strace -ttt -s 256 -f -o ${tnum}-SOURCEstart.logx -e trace=setsockopt,write,writev"
set min = $source_def_SNDBUF
if ($min < $default_SNDBUF) then
	set min = $default_SNDBUF
endif
echo "#  1. -SENDBUFFSIZE between the larger of the system default and the internal default ($min) and INT_MAX ($INT_MAX), expect the specified value"
setenv gtm_test_sendbuffsize "`setbufsize.sh $tnum SOURCE SNDBUF $min $INT_MAX`"
set min = $source_def_RCVBUF
if ($min < $default_RCVBUF) then
	set min = $default_RCVBUF
endif
echo "#  2. -RECVBUFFSIZE between the larger of the system default and the internal default ($min) and INT_MAX ($INT_MAX), expect the specified value"
setenv gtm_test_recvbuffsize "`setbufsize.sh $tnum SOURCE RCVBUF $min $INT_MAX`"
echo "# Start the source server"
$MSR STARTSRC INST1 INST2

echo "## Receiver server"
setenv gtm_test_replic_prefix "strace -ttt -s 256 -f -o ${tnum}-RECEIVERstart.logx -e trace=setsockopt,write,writev"
set min = $receiver_def_SNDBUF
if ($min < $default_SNDBUF) then
	set min = $default_SNDBUF
endif
echo "#  1. -SENDBUFFSIZE between the larger of the system default and the internal default ($min) and INT_MAX ($INT_MAX), expect the specified value"
setenv gtm_test_sendbuffsize "`setbufsize.sh $tnum RECEIVER SNDBUF $min $INT_MAX`"
set min = $receiver_def_RCVBUF
if ($min < $default_RCVBUF) then
	set min = $default_RCVBUF
endif
echo "#  2. -RECVBUFFSIZE between the larger of the system default and the internal default ($min) and INT_MAX ($INT_MAX), expect the specified value"
setenv gtm_test_recvbuffsize "`setbufsize.sh $tnum RECEIVER RCVBUF $min $INT_MAX`"

echo "# Start the receiver server"
$MSR STARTRCV INST1 INST2
echo "## Check output for correct SO_SNDBUF and SO_RCVBUF values"
./logcheck.csh $tnum
echo "# Stop the source and receiver servers"
$MSR STOP INST1 INST2
echo

echo "### Test 7: MUPIP REPLICATE with -NOSENDBUFFSIZE and -NORECVBUFFSIZE"
set tnum = T7
echo "## Source server"
setenv gtm_test_replic_prefix "strace -ttt -s 256 -f -o ${tnum}-SOURCEstart.logx -e trace=setsockopt,write,writev"
set exp = $source_def_SNDBUF
if ($exp < $default_SNDBUF) then
	set exp = $default_SNDBUF
endif
echo "#  1. -NOSENDBUFFSIZE, expect the greater of system default SO_SNDBUF ($default_SNDBUF) and internal default ($source_def_SNDBUF)"
setenv gtm_test_sendbuffsize "`setbufsize.sh $tnum SOURCE SNDBUF $exp $exp`"
set exp = $source_def_RCVBUF
if ($exp < $default_RCVBUF) then
	set exp = $default_RCVBUF
endif
echo "#  2. -NORECVBUFFSIZE, expect the greater of system default SO_RCVBUF ($default_RCVBUF) and internal default ($source_def_RCVBUF)"
setenv gtm_test_recvbuffsize "`setbufsize.sh $tnum SOURCE RCVBUF $exp $exp`"
echo "# Start the source server"
$MSR STARTSRC INST1 INST2

echo "## Receiver server"
setenv gtm_test_replic_prefix "strace -ttt -s 256 -f -o ${tnum}-RECEIVERstart.logx -e trace=setsockopt,write,writev"
set exp = $receiver_def_SNDBUF
if ($exp < $default_SNDBUF) then
	set exp = $default_SNDBUF
endif
echo "#  1. -NOSENDBUFFSIZE, expect the greater of system default SO_SNDBUF ($default_SNDBUF) and internal default ($receiver_def_SNDBUF)"
setenv gtm_test_sendbuffsize "`setbufsize.sh $tnum RECEIVER SNDBUF $exp $exp`"
set exp = $receiver_def_RCVBUF
if ($exp < $default_RCVBUF) then
	set exp = $default_RCVBUF
endif
echo "#  2. -NORECVBUFFSIZE, expect the greater of system default SO_RCVBUF ($default_RCVBUF) and internal default ($receiver_def_RCVBUF)"
setenv gtm_test_recvbuffsize "`setbufsize.sh $tnum RECEIVER RCVBUF $exp $exp`"

echo "# Start the receiver server"
$MSR STARTRCV INST1 INST2
echo "## Check output for correct SO_SNDBUF and SO_RCVBUF values"
./logcheck.csh $tnum
echo "# Stop the source and receiver servers"
$MSR STOP INST1 INST2
echo

# It is possible that the strace-prefixed server processes run in the background by 'SRC.csh' and 'RCVR.csh' will attempt"
# to access the journal or receiver pool before it is set up. So, those loops wait for the pool to be set up before continuing"
# script execution. During that wait, it is possible for NOJNLPOOL or NORECVPOOL errors to occur. This happens most of the time,"
# so 'knownerror.csh' is called below for each case."
# For details see: https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2474#note_2948920218"
foreach file ( START_*.out )
	$gtm_tst/com/knownerror.csh $file "YDB-E-NOJNLPOOL"
end
foreach file ( $SEC_SIDE/START_*.out )
	$gtm_tst/com/knownerror.csh $file "YDB-E-NORECVPOOL"
end
$gtm_tst/com/portno_release.csh
$gtm_tst/com/dbcheck.csh -noshut >& dbcheck.out
