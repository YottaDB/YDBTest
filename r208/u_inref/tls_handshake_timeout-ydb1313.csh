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

echo "#----------------------------------------------------------------------------------------------------#"
echo '# [YDB#1313] WRITE /TLS("client",timeout) and WRITE /TLS("server",timeout) time out when the peer    #'
echo "# sends no TLS handshake messages                                                                    #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo "# On a socket that is not nonblocking (the default), the TLS handshake waits in read() for the peer."
echo '# Without the fix, WRITE /TLS("client",1) to a peer that accepts the TCP connection but never answers'
echo '# the handshake, and WRITE /TLS("server",1) with a TCP client that never starts the handshake, wait'
echo '# until the peer does something, instead of returning after 1 second with $TEST set to 0. With the fix,'
echo "# the socket is nonblocking during a handshake with a timeout, and blocking again afterwards."
echo "#"
echo "# The silent peer of stages 1 and 2 gives up after 15 seconds, so that without the fix the handshake"
echo "# returns after about 15 seconds instead of waiting forever."
echo

echo "# This subtest needs TLS, so set it up if the test system did not"
if ("TRUE" != "$gtm_test_tls") then
	setenv gtm_test_tls TRUE
	source $gtm_tst/com/set_tls_env.csh
endif
echo "# Create a database, which also creates the TLS configuration file gtmcrypt.cfg"
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif
if (! -e gtmcrypt.cfg) then
	echo "WRONG : gtmcrypt.cfg was not created"
endif

source $gtm_tst/com/portno_acquire.csh >>& portno.out	# sets the portno environment variable used by ydb1313.m
echo

echo '# Stage 1 : WRITE /TLS("client",1) to a peer that accepts the TCP connection and never answers the handshake'
echo '# Command : $gtm_dist/mumps -run clienttimeout^ydb1313'
echo '# Before the fix, WRITE /TLS returned only when the peer gave up, after about 15 seconds, and the second'
echo '# line below was a WRONG line that reported the time the client handshake took'
$gtm_dist/mumps -run clienttimeout^ydb1313
echo

echo '# Stage 2 : WRITE /TLS("server",1) with a TCP client that never starts the handshake'
echo '# Command : $gtm_dist/mumps -run servertimeout^ydb1313'
echo '# Before the fix, WRITE /TLS returned only when the peer gave up, after about 15 seconds, and the second'
echo '# line below was a WRONG line that reported the time the server handshake took'
$gtm_dist/mumps -run servertimeout^ydb1313
echo

echo '# Stage 3 : a TLS server and client with WRITE /TLS("server",10) and WRITE /TLS("client",10), then a line each way'
echo '# Command : $gtm_dist/mumps -run %XCMD '\''do handshake^ydb1313(10)'\'
echo '# Before the fix, this stage passed, with the output below'
$gtm_dist/mumps -run %XCMD 'do handshake^ydb1313(10)'
echo

echo '# Stage 4 : a TLS server and client with WRITE /TLS("server") and WRITE /TLS("client") without a timeout'
echo '# Command : $gtm_dist/mumps -run %XCMD '\''do handshake^ydb1313("")'\'
echo '# Before the fix, this stage passed, with the output below'
$gtm_dist/mumps -run %XCMD 'do handshake^ydb1313("")'
echo

echo "# Check that no JOBbed peer reported an error"
foreach file (*.mje)
	if (! -z $file) then
		echo "WRONG : $file is not empty. Its contents follow."
		cat $file
	endif
end

$gtm_tst/com/portno_release.csh
$gtm_tst/com/dbcheck.csh >&! dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
