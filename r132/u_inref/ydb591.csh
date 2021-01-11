#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# NB on sed:
# This sed is necessary to strip unwanted syscalls from the log, as strace
# will print them out (like syscall_409) if it doesn't know about it.
# This issue was seen in an ARM7 box. !d means delete lines that don't match.
# ! needed to be escaped as C Shell tries to interpret it as an event.
echo "# Checking that removal of #ifdef TCP_NODELAY leaves ZDELAY/ZNODELAY operational"
source $gtm_tst/com/portno_acquire.csh >>& portno.out

echo "# ZDELAY (default if not specified in open) -> znodelay, zdelay (use) "
echo "# Should see TCP_NODELAY set to 0, 1, 0"
strace -o yottadb_socket_trace1.txt -e setsockopt $ydb_dist/yottadb -direct<<END >/dev/null
set portno=$portno
open "dev1":(LISTEN=portno_":TCP":attach="server"):10:"SOCKET" ; zdelay (default)
use "dev1":(znodelay)
use "dev1":(zdelay)
close "dev1":(destroy)
END
sed '/setsockopt/\!d' yottadb_socket_trace1.txt > yottadb_socket_trace1_clean.txt
cat yottadb_socket_trace1_clean.txt

echo "# ZDELAY (explicitly specified in open) -> znodelay, zdelay (use) "
echo "# Should see TCP_NODELAY set to 0, 1, 0"
strace -o yottadb_socket_trace2.txt -e setsockopt $ydb_dist/yottadb -direct<<END >/dev/null
set portno=$portno
open "dev2":(LISTEN=portno_":TCP":attach="server":zdelay):10:"SOCKET"
use "dev2":(znodelay)
use "dev2":(zdelay)
close "dev2":(destroy)
END
sed '/setsockopt/\!d' yottadb_socket_trace2.txt > yottadb_socket_trace2_clean.txt
cat yottadb_socket_trace2_clean.txt

echo "# ZNODELAY (open) -> zdelay, znodelay (use) "
echo "# Should see TCP_NODELAY set to 1, 0, 1"
strace -o yottadb_socket_trace3.txt -e setsockopt $ydb_dist/yottadb -direct<<END >/dev/null
set portno=$portno
open "dev3":(LISTEN=portno_":TCP":attach="server":znodelay):10:"SOCKET"
use "dev3":(zdelay)
use "dev3":(znodelay)
close "dev3":(destroy)
END
sed '/setsockopt/\!d' yottadb_socket_trace3.txt > yottadb_socket_trace3_clean.txt
cat yottadb_socket_trace3_clean.txt

$gtm_tst/com/portno_release.csh
