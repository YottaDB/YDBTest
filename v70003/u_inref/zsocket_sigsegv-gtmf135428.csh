#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

cat << CAT_EOF | sed 's/^/# /;' | sed 's/ $//;'
*****************************************************************
GTMF-135428 - Test the following release note
*****************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-003_Release_Notes.html#GTM-F135428)

> If the index for the \$ZSOCKET() function is outside the range
> of attached sockets for the specified SOCKET device, \$ZSOCKET()
> returns an empty string. Previously, if prior actions on the
> SOCKET device removed one or more sockets, \$ZSOCKET() could
> return stale or invalid information, or cause a segmentation
> violation (SIG-11).

The test is a server-client pair. The steps seems crazy, but
all of them are needed to trigger a SIGSEGV on previous
versions.

The client connects to the server, and sends a character 'c'.
When the server receives the character, it closes the client
connection.

Then, the server closes the connection again, and catches the
SOCKNOTFND error.

After the server tried to close the already closed connection,
the client attempts to sending an 'x' character.

The server waits (with LOCK mechanism) the client to send the
message, then lists the socket connections, retrieving
information with \$ZSOCKET command. It should report empty
string for the closed client connection.

This test is not 100% stable, when it fails, it randomly
produces two type of errors: ASSERT/SIGSEGV and output
difference. The release notes mentions SIGSEGV, but because
both kind of errors are good indicators of the mailfunction,
this is OK.

Version v70001 server side program produces assert/SIGSEGV
in ca. 90% of cases, dbg mode:
>     20 %GTM-F-ASSERT, Assert failed in /Distrib/YottaDB/V70001/sr_port/op_fnzsocket.c line 444 for expression (socket_connect_inprogress >= socketptr->state)
Pro mode:
>     20	%GTM-F-KILLBYSIGSINFO1, GT.M process 36471 has been killed by a signal 11 at address 0x00007F320459FD71 (vaddr 0x00007F38F9DFC538)
>     21	%GTM-F-SIGMAPERR, Signal was caused by an address not mapped to an object

The remaining 10% produces unexpected output on server side:
the status of the index-1 socket should be empty string,
(as release notes mentions), not "CONNECTED". The failing test
will look like (both dbg and pro mode):
<     24	    index-1: []
---
>     24	    index-1: [CONNECTED]

The version v70002 should produce no errors.
CAT_EOF
echo ""

source $gtm_tst/com/portno_acquire.csh >& portno.out
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.log

($gtm_dist/mumps -run server^gtmf135428 $portno >& server.out &)
$gtm_dist/mumps -run client^gtmf135428 $portno >& client.out

echo ---- server ----
cat -n server.out
echo ---- client ----
cat -n client.out

sed -i '/\(SOCKNOTFND\)/d' server.out

$gtm_tst/com/dbcheck.csh >& dbcheck.log
$gtm_tst/com/portno_release.csh
