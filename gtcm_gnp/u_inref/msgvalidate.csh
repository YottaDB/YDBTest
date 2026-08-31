#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Drive malformed GT.CM GNP messages at a gtcm_gnp_server and check it refuses each one and keeps
# serving. Every message here is one a real client cannot produce, so the client side of GT.CM
# cannot be used to send them; inref/gnpfuzz.m speaks the wire protocol over a plain TCP socket
# instead. Server and client are both local, so this subtest needs no GT.CM buddy hosts.
#
echo "# Acquire a port and start a GT.CM GNP server against a local database"
source $gtm_tst/com/portno_acquire.csh >>& portno.out
setenv gtmgbldir mumps.gld
echo '$GDE exit'
$GDE exit >&! gde.out
if ($status) echo "TEST-E-GDE GDE failed, see gde.out"
echo '$MUPIP create'
$MUPIP create >&! create.out
if ($status) echo "TEST-E-CREATE MUPIP CREATE failed, see create.out"
# A second database, with room for a subscript long enough that the server's answer to a $ORDER or
# a $ZPREVIOUS does not fit in its CM_MSG_BUF_SIZE + CM_BUFFER_OVERHEAD (532) byte message buffer.
# The default region's 64 byte key size cannot produce a reply anywhere near that large.
echo "# A second database whose keys are long enough to overflow the server's message buffer"
setenv gtmgbldir big.gld
echo '$GDE change -region/-segment, exit'
$GDE >&! big_gde.out << gde_eof
change -region DEFAULT -key_size=1019 -record_size=1024
change -segment DEFAULT -file_name=big.dat
exit
gde_eof
if ($status) echo "TEST-E-GDE GDE failed on big.gld, see big_gde.out"
$MUPIP create >&! big_create.out
if ($status) echo "TEST-E-CREATE MUPIP CREATE failed on big.gld, see big_create.out"
echo '$gtm_exe/mumps -run %XCMD set of ^big(<900 byte subscript>) and two 31 byte global names'
# One subscript and no others, so the $ORDER and $ZPREVIOUS below have exactly this one to return
$gtm_exe/mumps -run %XCMD 'set ^big($translate($justify("",900)," ","a"))="v"' >&! bigsub.out
# Two globals whose names are exactly MAX_MIDENT_LEN, for the name level $ORDER check in gnpbig.m
$gtm_exe/mumps -run %XCMD 'set ^abcdefghijklmnopqrstuvwxyz01234=1,^abcdefghijklmnopqrstuvwxyz01235=2' >>&! bigsub.out
if ($status) echo "TEST-E-BIGSUB could not populate ^big, see bigsub.out"
setenv gtmgbldir mumps.gld
echo '$gtm_tst/com/GTCM_SERVER.csh $portno 0'
$gtm_tst/com/GTCM_SERVER.csh $portno 0 >&! gtcm_server_start.log
if ($status) then
	echo "TEST-E-GTCMSERVER could not start the GT.CM server, see gtcm_server_start.log"
	# give the port back before giving up, the way the normal path does at the end of this script.
	# This is the only early exit here; every other failure carries on so the later cases still run.
	source $gtm_tst/com/portno_release.csh
	exit 1
endif
set srvpid = `cat gtcm_server.pid`
echo "# GT.CM server started"
echo ""

# Each case sends one message and prints one verdict line. All cases share one server, so a case
# that kills the server leaves the ones after it reporting TEST SETUP FAILED rather than testing
# anything. That is loud enough to diagnose from, and the first WRONG verdict names the message that
# did it. A verdict containing WRONG is a failure; the reference file holds the expected verdicts, so
# a changed verdict shows up as a diff. "sanity" runs first: if the harness itself cannot complete a
# valid exchange the rest means nothing.
#
# Each case prints three lines: a "#" line naming what it sends and what it should produce, then the
# command, then what the case actually reported. Expectation and outcome therefore sit next to each
# other and can be read against one another without scrolling.
cat >! cases.list << case_eof
sanity mumps.dat a valid handshake, INITREG and GET. Expect all three answered, server serving
bigframe mumps.dat a message larger than the server buffer, announced in one write. Expect the link closed, no error logged
splitframe mumps.dat the same, with the 2 byte prefix split across two writes. Expect the link closed, no error logged
longdbname mumps.dat an INITREG naming a file longer than MAX_FN_LEN. Expect BADGTMNETMSG, server serving
shortjpv mumps.dat a handshake carrying 40 of the 88 jnl_process_vector bytes. Expect it accepted and zero filled
keylenbig mumps.dat a GET whose declared key length exceeds the bytes sent. Expect BADGTMNETMSG, server serving
keylenzero mumps.dat a declared length of 0, which the former len-- made 65535. Expect BADGTMNETMSG, server serving
keylentiny mumps.dat a key too short to hold its own top/end/prev header. Expect BADGTMNETMSG, server serving
keynoname mumps.dat a key whose global variable name is empty. Expect BADGTMNETMSG, server serving
keylongname mumps.dat a global variable name longer than MAX_MIDENT_LEN. Expect BADGTMNETMSG, server serving
keyshape mumps.dat a key that fits but whose end points outside it. Expect BADGTMNETMSG, server serving
keybadname mumps.dat a legal length name whose bytes are not an M name, a-b. Expect BADGTMNETMSG, server serving
keydigitname mumps.dat a name whose first byte is a digit, 1ab. Expect BADGTMNETMSG, server serving
lenzerodata mumps.dat a declared length of 0 sent to the data handler. Expect BADGTMNETMSG, server serving
lenzerokill mumps.dat a declared length of 0 sent to the kill handler. Expect BADGTMNETMSG, server serving
lenzeroorder mumps.dat a declared length of 0 sent to the order handler. Expect BADGTMNETMSG, server serving
lenzerozprev mumps.dat a declared length of 0 sent to the zprev handler. Expect BADGTMNETMSG, server serving
lenzeroput mumps.dat a declared length of 0 sent to the put handler. Expect BADGTMNETMSG, server serving
lenzeroquery mumps.dat a declared length of 0 sent to the query handler. Expect BADGTMNETMSG, server serving
lenzerozwith mumps.dat a declared length of 0 sent to the zwith handler. Expect BADGTMNETMSG, server serving
lenzeroincr mumps.dat a declared length of 0 sent to the incr handler. Expect BADGTMNETMSG, server serving
lenzerorevqry mumps.dat a declared length of 0 sent to the revqry handler. Expect BADGTMNETMSG, server serving
bufflush mumps.dat a buffered SET writing 255 key bytes at offset 255. Expect BADGTMNETMSG, server serving
bufflushlenzero mumps.dat a buffered SET with a key length of 0. Expect BADGTMNETMSG, server serving
bufflushend mumps.dat a buffered SET whose end is at a NUL not preceded by one. Expect BADGTMNETMSG, server serving
bufflushprev mumps.dat a buffered SET whose prev points past its own end. Expect BADGTMNETMSG, server serving
bufflushnoname mumps.dat a buffered SET whose global variable name is empty. Expect BADGTMNETMSG, server serving
bufflushnodata mumps.dat a buffered SET with the value length missing. Expect BADGTMNETMSG, server serving
bufflushbigdata mumps.dat a buffered SET whose value length exceeds the bytes sent. Expect BADGTMNETMSG, server serving
locklen mumps.dat a lock entry of declared length 0, formerly 65533. Expect BADGTMNETMSG, server serving
locksubcnt mumps.dat a subscript count larger than the subscripts sent. Expect BADGTMNETMSG, server serving
locktrail mumps.dat subscripts that parse but stop short of the declared length. Expect BADGTMNETMSG, server serving
locknolistlen mumps.dat a lock request ending before the entry count byte. Expect BADGTMNETMSG, server serving
lockshortentry mumps.dat one lock entry announced, its 5 byte header not all there. Expect BADGTMNETMSG, server serving
lockshortnref mumps.dat a lock entry whose length runs past the bytes received. Expect BADGTMNETMSG, server serving
bufflushnotrans mumps.dat a buffered SET ending before its transaction count. Expect BADGTMNETMSG, server serving
bufflushnohdr mumps.dat one transaction announced, none of its four header bytes. Expect BADGTMNETMSG, server serving
bufflushshortkey mumps.dat a key length longer than the key bytes that follow. Expect BADGTMNETMSG, server serving
shortproto mumps.dat a handshake that ends inside the protocol string. Expect BADGTMNETMSG, server serving
initregnolen mumps.dat an INITREG ending before its file name length. Expect BADGTMNETMSG, server serving
initregshort mumps.dat a file name length longer than the name bytes sent. Expect BADGTMNETMSG, server serving
orderbigreply big.dat an ORDER whose 917 byte answer exceeds the 532 byte buffer. Expect it returned intact
zprevbigreply big.dat a ZPREVIOUS whose answer exceeds the 532 byte buffer. Expect it returned intact
case_eof
foreach spec ("`cat cases.list`")
	set case = `echo "$spec" | $tst_awk '{print $1}'`
	set dbf  = `echo "$spec" | $tst_awk '{print $2}'`
	set want = `echo "$spec" | sed 's/^[^ ]* [^ ]* //'`
	# echo the command with $portno and $PWD unexpanded: both change from run to run and the
	# reference file has to stay stable. The case name is what identifies the line.
	echo "# $case : $want"
	echo '$gtm_exe/mumps -run gnpfuzz $portno $PWD/'"$dbf $case"
	$gtm_exe/mumps -run gnpfuzz "$portno $PWD/$dbf $case" < /dev/null
end
echo ""

# The one thing above that a raw socket cannot easily produce is a well formed request whose answer
# is too large, because the client appends bytes of its own to an $ORDER key. Use a real GT.CM
# client for that, against the long key database, with the same server still running.
echo "# A reply larger than the server's message buffer has to come back intact"
set node = `echo $HOST | sed 's/\..*//'`
set bigdat = $cwd/big.dat
mkdir bigcli
cd bigcli
setenv gtmgbldir $PWD/mumps.gld
setenv ydb_cm_$node $portno
echo '$GDE change -region/-segment for @<node>:<path>/big.dat, exit'
$GDE >&! bigcli_gde.out << gde_eof
change -region DEFAULT -key_size=1019 -record_size=1024
change -segment DEFAULT -file_name=@${node}:$bigdat
exit
gde_eof
if ($status) echo "TEST-E-GDE GDE failed in bigcli, see bigcli_gde.out"
echo '$gtm_exe/mumps -run gnpbig 900'
$gtm_exe/mumps -run gnpbig 900 < /dev/null
cd ..
setenv gtmgbldir mumps.gld
echo ""

echo "# The server process must have survived every one of them"
echo '$gtm_tst/com/is_proc_alive.csh $srvpid'
$gtm_tst/com/is_proc_alive.csh $srvpid >&! isprocalive.out
if (0 == $status) then
	echo "GT.CM server process is still alive : as expected"
else
	echo "GT.CM server process is GONE : WRONG, expected it to survive every malformed message"
endif
echo ""

echo "# Stop the GT.CM server"
set time_stamp = `date +%H_%M_%S`
echo '$gtm_tst/com/GTCM_SERVER_STOP.csh $time_stamp'
$gtm_tst/com/GTCM_SERVER_STOP.csh $time_stamp >&! gtcm_stop.log
if ($status) echo "TEST-E-GTCMSTOP GTCM_SERVER_STOP.csh failed, see gtcm_stop.log"
echo ""

echo "# The server logged one BADGTMNETMSG for each message it refused, and nothing else beyond the"
echo "# FORCEDHALT from its own shutdown. Count both."
set cmerrlog = cmerr_0.log	# GTCM_SERVER.csh was passed a time stamp of 0
set badmsgcnt = `$grep -c "BADGTMNETMSG" $cmerrlog`
set wantbadmsg = 37	# one per case that expects a rejection; the rest expect an answer or a closed link
if ("$wantbadmsg" == "$badmsgcnt") then
	echo "BADGTMNETMSG count in the server log is $wantbadmsg : as expected"
else
	echo "BADGTMNETMSG count in the server log is $badmsgcnt : WRONG, expected $wantbadmsg"
endif
# The cases that expect a closed link rather than a rejection, bigframe and splitframe, are refused
# at the framing layer, before there is a message to name in an error. The server drops the link and
# logs nothing at all for them. Assert that by counting every message in the log, not just the
# BADGTMNETMSG ones: the total has to be the rejections plus the one FORCEDHALT from the shutdown,
# so any case that starts logging something new shows up here.
set allmsgcnt = `$grep -c "%YDB-" $cmerrlog`
@ wantallmsg = $wantbadmsg + 1
if ("$wantallmsg" == "$allmsgcnt") then
	echo "total message count in the server log is $wantallmsg : as expected"
else
	echo "total message count in the server log is $allmsgcnt : WRONG, expected $wantallmsg"
endif
# These errors are expected, so hide the log from errors.csh rather than leaving it to be flagged.
# Its output quotes the matching log lines, which carry timestamps, so send it to a file and assert
# on the exit status instead of letting it into the reference file. The file has to be named ".logx"
# rather than ".out": those quoted lines contain the very "%YDB-E-" and "%YDB-F-" text this subtest
# expects, and errors.csh scans "*.out" while skipping "*.*x". That is the same reason
# check_error_exist.csh renames the log it clears to ".logx".
echo '$gtm_tst/com/check_error_exist.csh $cmerrlog BADGTMNETMSG FORCEDHALT'
$gtm_tst/com/check_error_exist.csh $cmerrlog BADGTMNETMSG FORCEDHALT >&! check_error_exist.logx
if (0 == $status) then
	echo "BADGTMNETMSG and FORCEDHALT both found in the server log : as expected"
else
	echo "expected errors missing from the server log : WRONG, see check_error_exist.logx"
endif
echo ""

# ---------------------------------------------------------------------------------------------
# The other direction. Above, the server was under test and the client was a program sending it
# messages a real client cannot produce. Here the client is under test: inref/gnpsrv.m stands in
# for a gtcm_gnp_server and answers a real GT.CM client with replies it cannot parse. GT.CM GNP
# clients and their servers are designed to run within the same security zone, so this is not about
# a hostile server: it is about the client not walking off the end of its own buffers when a reply
# does not have the shape it expects.
#
# The first case, srvstaleprev, is the important one and is not malformed at all. It is what a real
# server sends: gvcst_query() and gvcst_queryget() never assign gv_altkey->prev, so for a
# CMMS_R_QUERY reply the server passes on whatever the previous operation in that process left
# there, and it can exceed "end". The client has to accept that.
echo ""
echo "# A fake server sends a real GT.CM client replies it cannot parse. Each case below names what"
echo "# it sends and what it should produce, then the command, then what the client reported."
set node = `echo $HOST | sed 's/\..*//'`
mkdir client
cd client
setenv gtmgbldir $PWD/mumps.gld
setenv ydb_cm_$node $portno
echo '$GDE change -segment DEFAULT -file_name=@<node>:$PWD/nosuch.dat'
$GDE >&! cli_gde.out << gde_eof
change -segment DEFAULT -file_name=@${node}:$PWD/nosuch.dat
exit
gde_eof
cat >! srvcases.list << srv_eof
srvstaleprev a well formed reply whose prev exceeds end, which is what a real server sends. Expect it accepted
srvbadlen a reply whose declared length is below the key header. Expect BADSRVRNETMSG
srvshortkey a reply that declares more key bytes than it carries. Expect BADSRVRNETMSG
srvbadshape a reply whose end does not point at a NUL terminator. Expect BADSRVRNETMSG
srvbigkey a reply whose key is larger than the client gv_altkey. Expect BADSRVRNETMSG
srvneglen a reply whose value length has its high bit set. Expect BADSRVRNETMSG
srvnolen a reply that stops after its message type. Expect BADSRVRNETMSG
srvnovallen a reply that ends after the key with no value length. Expect BADSRVRNETMSG
srvshortval a reply declaring a 50 byte value and carrying 2. Expect BADSRVRNETMSG
srvbigframe a reply announced and never sent, the client waiting for it. Expect GVQUERYFAIL rather than a hang
srvidleframe the same announcement queued while the client is idle. Expect GVQUERYFAIL rather than a hang
srv_eof
foreach spec ("`cat srvcases.list`")
	set case = `echo "$spec" | $tst_awk '{print $1}'`
	set want = `echo "$spec" | sed 's/^[^ ]* //'`
	\rm -f ready done queued
	# started inside a subshell so the shell does not report the job, whose pid would otherwise
	# land in the output and differ from run to run
	( $gtm_exe/mumps -run gnpsrv "$portno $case" >>&! gnpsrv.log & )
	# wait for the fake server's listen socket rather than guessing a sleep
	set waited = 0
	while ((! -e ready) && ($waited < 30))
		sleep 1
		@ waited = $waited + 1
	end
	if (! -e ready) echo "fake server did not start for $case : WRONG"
	echo "# $case : $want"
	echo '$gtm_exe/mumps -run gnpcli '"$case"
	$gtm_exe/mumps -run gnpcli "$case" < /dev/null
	# wait for the fake server to release the port before the next case claims it
	set waited = 0
	while ((! -e done) && ($waited < 30))
		sleep 1
		@ waited = $waited + 1
	end
	if (! -e done) echo "fake server did not exit for $case : WRONG"
end
cd ..
setenv gtmgbldir $PWD/mumps.gld
echo ""

echo "# Check the database the server was serving is intact"
# dbcheck_base.csh rather than dbcheck.csh: this subtest runs its own local server rather than the
# GT.CM buddy hosts the rest of this test uses, so there are no remote servers for dbcheck.csh to
# stop. socket/u_inref/gtcm_ipv6.csh does the same for the same reason.
echo '$gtm_tst/com/dbcheck_base.csh'
$gtm_tst/com/dbcheck_base.csh
source $gtm_tst/com/portno_release.csh
