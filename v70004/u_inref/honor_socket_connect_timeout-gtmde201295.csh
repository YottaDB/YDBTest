#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################

cat << CAT_EOF | sed 's/^/# /;' | sed 's/ $//;'
*****************************************************************
GTM-DE201295 - Test the following release note
*****************************************************************

Release note http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-004_Release_Notes.html#GTM-DE201295 says:

> SOCKET device OPEN better honors timeouts; similarly, USE for
> a SOCKET honors an implicit zero timeout. Note that very short
> timeouts, particularly zero (0), may be unsuitable for dealing
> with the timing of some network events, and thus may need
> adjustment to avoid timing out after this correction.
> Previously, these commands did not start their own timers to
> bound the operation, causing the CONNECT to only check for a
> timeout condition when some other process, or operating system,
> event interrupted the process. (GTM-DE201295)

The first test case entitled "testing connect to 244.0.0.0"
tests the Release note. It fails on v7.0-003 and earlier
versions, and passes from versions v7.0-004.

Further test cases entitled "testing timeout behaviour..." are
not directy related to GTM-DE201295, but they test similar edge
case situations with different timing values, see details in the
.csh file comment. Some of these cases (0-0-0 and 0-0-2)
- pass v7.0-003 and before,
- fail on v7.0-004 and v7.0-005,
- pass newer versions.
Other tests cases do not fail on any version, these have been
left here in order to detect possible future bugs.
CAT_EOF

# Some details on how the second part of the test works:
# - it launches specified number of clients and one server
# - a client connects to the server, with specified timeout
#   (or without timeout specified), then checks 3 things:
#   - value of \$KEY, the first field is "CONNECTED" or empty
#   - number of connections parsed from reult of ZSHOW "D"
#   - time spent with OPEN command
# - as there are many clients (hundreds), client log is turned
#   off by default, clients send summary to the server, and it
#   prints the result in normal case
# - client logs are saved in `.out` files
# - the foreach argument called `parm` contains parameters for
#   test cases, separated by minus sign:
#   - server delay: number of seconds to hang before the server
#     starts listening (used to test clients' timeout feature)
#   - client timeout: in seconds, if "unset", timeout is not
#     specified
#   - client start stretch: client requests will be stretched,
#     so the timeouts will be spread in time, too
# - the test automatically calculates if the cient request should
#   succeed (if server delay is less than timeout)
#
# ---- starting case ----------------------------
#       starting client1   |  server delay
#       starting client2   | -- server start ----
#                   ...    |  server normal
#   -- client stretch ------   operation
#                          |
#        client1 timeout   |
#        client2 timeout   |
#                   ...    |
#    last client timeout   |
#  ----------------------------------------------
#
# Some trivial rules should apply on timing values:
# - client timeout should be greater than client stretch
# - server delay should be before all client start, or
#   after all client start
# - server delay should be before all client timeout or
#   after all client timeout
#
# These rules guarantees the same behaviour for all
# clients.

# ---- parameters ----

# number of clients
set client_count = 20

echo
echo "# ---- startup ----"

# set error prefix
setenv ydb_msgprefix "GTM"

echo "# allocate a port number"
source $gtm_tst/com/portno_acquire.csh >& portno.out

echo '# create database'
$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.out

echo "# setting number of clients: $client_count"
@ procnum = $client_count + 1
$gtm_dist/mumps -run chkset^gtmde201295 $portno $procnum

echo
echo "# ---- testing connect to 244.0.0.0 (non-existent IP address) ----"

# attempt to connect, in background
($gtm_dist/mumps -run connect^gtmde201295 >& conn.txt & echo $! > pid.txt) >& subshell.txt
set pid = `cat pid.txt`

# wait for background process
$gtm_tst/com/wait_for_proc_to_die.csh $pid >& waitforproc.log

# stop stuck background process (normally it's already exited)
if ( 0 != $? ) then
	echo "TEST-E-HANG: process is hung unexpectedly, stopping"
	$gtm_dist/mupip stop $pid
else
	cat conn.txt
endif

# Test case graphs
#
# parameters:
#  server_delay - client_timeout (can be "unset") - client-stretch
#
# 0-0-0: simple zero timeout, clients connect
#  srv:  ------->
#  cli1: 0
#  cli2: 0
#  cli3: 0
#
# 0-0-2: zero timeout stretched, clients connect
#  srv:  ------->
#  cli1: 0  |
#  cli2:  0 |
#  cli3:   0|
#           2 sec
#
# 0-unset-0: simple unspecified timeout, clients connect
#  srv:  ------->
#  cli1: u
#  cli2: u
#  cli3: u
#
# 0-unset-2: stretch clients with unspecified timeut, they connect
#  srv:  ------->
#  cli1: u  |
#  cli2:  u |
#  cli3:   u|
#           2 sec
#
# 5-2-1: clients with timeout=2 and stretch=1 miss the server start=5
#                    | 5 sec
#  srv:              |------->
#  cli1: 2..t|
#  cli2:  2..t|
#  cli3:   2..t|
#            2 sec
#              3 sec
#
# 2-5-0: server start=2, clients started sooner with timeout=5 can connect
#           | 2 sec
#  srv:     |-------------->
#  cli1: 5..|........t
#  cli2: 5..|........t
#  cli3: 5..|........t
#           2 sec
#
foreach parm ( "0-0-0" "0-0-2" "0-unset-0" "0-unset-2" "5-2-1" "2-5-0"  )

	set server_delay=`echo $parm | cut -d- -f1`
	set client_timeout=`echo $parm | cut -d- -f2`
	set client_stretch=`echo $parm | cut -d- -f3`

	echo
	echo "---- testing timeout behaviour with server_delay=${server_delay} client_timeout=${client_timeout} client_stretch=${client_stretch}----"

	# reset checkpoint values
	$gtm_dist/mumps -run chkrst^gtmde201295 $portno

	set i = 1
	while ($i <= $client_count)
		($gtm_dist/mumps -run client^gtmde201295 $portno $server_delay $client_timeout client${i} $client_count $i $client_stretch >>& client${i}-${parm}.out &)
	@ i++
	end

	$gtm_dist/mumps -run server^gtmde201295 $portno $server_delay $client_timeout server $client_count -1 $client_stretch >>& server-${parm}.out

	# Clients are "intentionally" got stuck, when no timeout is specified
	# for a socket OPEN - in this case they must be killed from outside.
	echo "# wait for clients to exit"
	while (1)
		set wpid = `$gtm_dist/mumps -run getw^gtmde201295`
		if ("" == $wpid) then
			break
		endif
		$gtm_dist/mumps -run killw^gtmde201295 $wpid
		kill $wpid
		$gtm_tst/com/wait_for_proc_to_die.csh $wpid >>& waitforproc-${parm}.log
	end

	# print server log
	echo "-- server log --"
	cat server-${parm}.out

	# print client logs (only failed ones)
	set i = 1
	while ($i <= $client_count)
		set cfail = `cat client{$i}-${parm}.out | grep 'client.*score.*fail' | wc -l`
		if ($cfail) then
			echo "-- client${i} log (failed) --"
			cat client{$i}-${parm}.out
		endif
		@ i++
	end

end

echo
echo "# ---- cleanup ----"

echo "# validate db"
$gtm_tst/com/dbcheck.csh >& dbcheck.out

echo "# release port number"
$gtm_tst/com/portno_release.csh >>& portno.out
