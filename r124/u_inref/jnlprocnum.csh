#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
cd $path_INST1

# Get Shared Memory ID of the INST1 JNLPOOL
$ydb_dist/mupip ftok -jnlpool mumps.repl |& $grep mumps.repl | $tst_awk '{print $6}' >& shm1.out

# Get Shared Memory ID of the INST3 JNLPOOL
cd $path_INST3
$ydb_dist/mupip ftok -jnlpool mumps.repl |& $grep mumps.repl | $tst_awk '{print $6}' >& $path_INST1/shm2.out
cd $path_INST1

# Use the JNLPOOL Shared MEMORY IDs to get the # of processes attached ot each JNLPOOL
echo -n "    number of processes attached to JNLPOOL of INST1: "
ipcs -a | $grep -w `cat ./shm1.out` | $tst_awk '{print $NF}'

echo -n "    number of processes attached to JNLPOOL of INST3: "
ipcs -a | $grep -w `cat ./shm2.out` | $tst_awk '{print $NF}'

echo ""
