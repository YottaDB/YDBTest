#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Helper Script for subtest ydb313
# Checks the IPC keys for semaphore and memory ids of the replicating instances

# Get the Semaphore and Memory IDs from the input files
set jnlSem = `cat $1 | cut -d ':' -f 3 | cut -d '[' -f 1`
set jnlMem = `cat $1 | cut -d ':' -f 5 | cut -d '[' -f 1`

set recvSem = `cat $2 | cut -d ':' -f 3 | cut -d '[' -f 1`
set recvMem = `cat $2 | cut -d ':' -f 5 | cut -d '[' -f 1`

set jnlSemYdb = `cat $3 | cut -d ',' -f 1`
set jnlMemYdb = `cat $3 | cut -d ',' -f 2`

set recvSemYdb = `cat $4 | cut -d ',' -f 1`
set recvMemYdb = `cat $4 | cut -d ',' -f 2`

echo "# Check IPC keys to make sure Semaphore IDs are found"
ipcs -s | grep -w -q $jnlSem
if ( $? == 0 ) then
	echo "jnlpool Semaphore ID found"
endif

ipcs -s | grep -w -q $recvSem
if ( $? == 0 ) then
	echo "recvpool Semaphore ID found"
endif

if ( "$jnlSemYdb" == "$jnlSem" ) then
	echo "jnlpool Semaphore ID from PEEKBYNAME matches jnlpool Semaphore ID from MUPIP FTOK -JNLPOOL"
endif

if ( "$recvSemYdb" == "$recvSem" ) then
	echo "recvpool Semaphore ID from PEEKBYNAME matches recvpool Semaphore ID from MUPIP FTOK -RECVPOOL"
endif
echo ""
echo "# Check IPC keys to make sure Memory IDs are found"
ipcs -m | grep -w -q $jnlMem
if ( $? == 0 ) then
	echo "jnlpool Memory ID found"
endif

ipcs -m | grep -w -q $recvMem
if ( $? == 0 ) then
	echo "recvpool Memory ID found"
endif

if ( "$jnlMemYdb" == "$jnlMem" ) then
	echo "jnlpool Memory ID from PEEKBYNAME matches jnlpool Memory ID from MUPIP FTOK -JNLPOOL"
endif

if ( "$recvMemYdb" == "$recvMem" ) then
	echo "recvpool Memory ID from PEEKBYNAME matches recvpool Memory ID from MUPIP FTOK -RECVPOOL"
endif
