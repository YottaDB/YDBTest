#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.	#
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
GTM-DE325871 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-000_Release_Notes.html#GTM-DE325871)

GT.M processes can use sockets created when over 1021 files, pipes, fifos, sockets, and/or regions are already open. GT.M issues an FDSIZELMT error message when there are too many descriptors needed by GT.CM servers. Previously, sockets created when there were too many open descriptors caused an GTMASSERT2 error. (GTM-DE325871)
CAT_EOF
echo

setenv ydb_msgprefix "GTM"
setenv ydb_prompt "GTM>"

echo "### Test 1: Test FDSIZELMT error when connecting to a GT.CM server when 1021 file descriptors are open"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate.out
endif
echo "# Use mumps to obtain the fullpath to the database"
set filepath=`$ydb_dist/mumps -run %XCMD 'write $view("GVFILE","DEFAULT")'`
echo "# Set file path to the database using the fullpath"
setenv gtmgbldir mumps.gld
$gtm_dist/mumps -run GDE change -segment DEFAULT -file=$filepath >& gnpserver_gde.txt
echo

echo "# Start the GT.CM GNP server"
set shorthost = $HOST
source $gtm_tst/com/portno_acquire.csh >& portno.out
set portno = `cat portno.out`
$gtm_dist/gtcm_gnp_server -service=$portno -log=gnpserver.log -trace

# Wait for server to write the pid in the log file before proceeding to record the pid.
$gtm_tst/com/wait_for_log.csh -log gnpserver.log -message "pid :" -waitcreation

sed 's/.*pid : \([0-9]*\)\]/\1/' gnpserver.log | head -n 1 >& gnpserver.pid
echo

echo "# Change the DEFAULT segment in the database using the syntax: @<hostname>:<filepath>."
echo "# This should use the GNP server even though <hostname> is local due to the @ syntax."
setenv gtmgbldir client.gld
$ydb_dist/mumps -run GDE change -segment DEFAULT -file="@$shorthost":$filepath >& client_gde.txt

echo "# Bump the process file descriptor limit to 2048 to allow the routine to hit the FDSIZELMT"
limit descriptors 2048
echo "# Run the routine and expect an FDSIZELMT error, since the limit is 1021 file descriptors."
setenv GTCM_$shorthost $portno
$gtm_dist/mumps -run gtcmfdlimit^gtmde325871 >&! gtcmfdlimit.txt
cat gtcmfdlimit.txt | sed 's/\(%GTM-E-FDSIZELMT, Too many (\)\([0-9]*\)\() descriptors needed by GT.CM server\)/\1FDS\3/g'
echo

set server_pid = `cat gnpserver.pid`
if ("" == "$server_pid") then
	echo "TEST-E-FAIL : Could not find gtcm_gnp_server pid from log file [gnpserver.pid]"
else
	$gtm_dist/mupip stop $server_pid >&! mupip.out
	$gtm_tst/com/wait_for_proc_to_die.csh $server_pid 30
endif

echo "### Test 2: Test no GTMASSERT2 error when opening a socket with over 1021 file descriptors already open"
setenv gtmgbldir mumps.gld
echo "# Run a simple M server process to provide TCP socket for client connection"
($gtm_dist/mumps -run server^gtmde325871 $portno & ; echo $! >&! server.pid) >&! server.log
echo "# Run an M client process to open > 1021 file descriptors then connect to the M server process"
echo "# Expect the client to output 'CONNECTED' string received from server."
echo "# Previously, this socket connection would have produced a GTMASSERT2 error."
$gtm_dist/mumps -run client^gtmde325871 $portno
set server_pid = `cat server.pid`
$gtm_tst/com/wait_for_proc_to_die.csh $server_pid 30
rm file*
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck.out
endif
$gtm_tst/com/portno_release.csh
