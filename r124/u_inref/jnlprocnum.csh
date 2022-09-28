#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	#
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
$ydb_dist/mupip ftok -jnlpool mumps.repl |& $grep "jnlpool" | $tst_awk '{print $6}' >& shm1.out

# Get Shared Memory ID of the INST3 JNLPOOL
cd $path_INST3
$ydb_dist/mupip ftok -jnlpool mumps.repl |& $grep "jnlpool" | $tst_awk '{print $6}' >& $path_INST1/shm2.out
cd $path_INST1

# Use the JNLPOOL Shared MEMORY IDs to get the # of processes attached ot each JNLPOOL
$gtm_tst/com/ipcs -m >& ipcs_m.out
echo -n "    number of processes attached to JNLPOOL of INST1: "
set shm=`cat ./shm1.out`
$tst_awk '$2 == '$shm' {print $NF}' ipcs_m.out

echo -n "    number of processes attached to JNLPOOL of INST3: "
set shm=`cat ./shm2.out`
$tst_awk '$2 == '$shm' {print $NF}' ipcs_m.out

echo ""
