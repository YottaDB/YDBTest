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
echo "-------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "# Test that MUPIP FTOK -JNLPOOL and MUPIP FTOK -RECVPOOL operate on the specified instance file and ignore ydb_repl_instance/gtm_repl_instance env var."
echo "-------------------------------------------------------------------------------------------------------------------------------------------------------"

echo ""

# Set up multisite replication
$MULTISITE_REPLIC_PREPARE 2

echo "# Create the DB"
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate.txt
endif

# Start Source and Receiver
$MSR STARTSRC INST1 INST2
$MSR STARTRCV INST1 INST2

echo ""
echo "# Perform some operations in mumps"
$ydb_dist/mumps -direct << EOF
	set ^X=5
	set ^Y=1
	set ^Z=4
	kill ^Z
EOF

echo "# Create a non .repl file and a .repl file to be used in subtest"
$MSR RUN INST2 'echo "This is not the replication file you are looking for" > droids.txt'
$MSR RUN SRC=INST1 RCV=INST2 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/mumps.repl _REMOTEINFO___RCV_DIR__/droids.repl'

# copy the env variables to be reset at the end of the test
set gtm=`echo $gtm_repl_instance`

echo "--------------------------------------------------------------------------------------------------------------------------"

echo "# Test that the commands work fine when ydb_repl_instance/gtm_repl_instance are undefined"

echo "# MUPIP FTOK -JNLPOOL"
$MSR RUN INST2 'unsetenv gtm_repl_instance; unsetenv ydb_repl_instance; $MUPIP ftok -JNLPOOL mumps.repl' | grep "mumps.repl  ::" >> jnlpool.txt

echo "# MUPIP FTOK -RECVPOOL"
$MSR RUN INST2 'unsetenv gtm_repl_instance; unsetenv ydb_repl_instance; $MUPIP ftok -RECVPOOL mumps.repl' | grep "mumps.repl  ::" > recvpool.txt

echo '# $$^%PEEKBYNAME("repl_inst_hdr.jnlpool_semid") and $$^%PEEKBYNAME("repl_inst_hdr.jnlpool_shmid")'
$MSR RUN INST2 '$ydb_dist/mumps -run jnlpool^ydb313' | grep "," > jnlpeek.txt

echo '# $$^%PEEKBYNAME("repl_inst_hdr.recvpool_semid") and $$^%PEEKBYNAME("repl_inst_hdr.recvpool_shmid")'
$MSR RUN INST2 '$ydb_dist/mumps -run recvpool^ydb313' | grep "," > recvpeek.txt

echo ""
# Run ydb313_ipcs_check.csh
$gtm_tst/$tst/u_inref/ydb313_ipcs_check.csh jnlpool.txt recvpool.txt jnlpeek.txt recvpeek.txt

if ( recvSem == -1 || recvMem == -1) then
	echo "Error on the receving end."
endif

echo "--------------------------------------------------------------------------------------------------------------------------"

echo "# Test that the commands work fine when ydb_repl_instance/gtm_repl_instance are set to non .repl files"

echo "# MUPIP FTOK -JNLPOOL"
$MSR RUN INST2 'setenv gtm_repl_instance droids.txt; setenv ydb_repl_instance droids.txt; $MUPIP ftok -JNLPOOL mumps.repl' | grep "mumps.repl  ::" > jnlpool1.txt

echo "# MUPIP FTOK -RECVPOOL"
$MSR RUN INST2 'setenv gtm_repl_instance droids.txt; setenv ydb_repl_instance droids.txt; $MUPIP ftok -RECVPOOL mumps.repl' | grep "mumps.repl  ::" > recvpool1.txt

echo '# $$^%PEEKBYNAME("repl_inst_hdr.jnlpool_semid") and $$^%PEEKBYNAME("repl_inst_hdr.jnlpool_shmid")'
$MSR RUN INST2 '$ydb_dist/mumps -run jnlpool^ydb313' | grep "," > jnlpeek1.txt

echo '# $$^%PEEKBYNAME("repl_inst_hdr.recvpool_semid") and $$^%PEEKBYNAME("repl_inst_hdr.recvpool_shmid")'
$MSR RUN INST2 '$ydb_dist/mumps -run recvpool^ydb313' | grep "," > recvpeek1.txt

echo ""
# Run ydb313_ipcs_check.csh
$gtm_tst/$tst/u_inref/ydb313_ipcs_check.csh jnlpool1.txt recvpool1.txt jnlpeek.txt recvpeek.txt

echo "--------------------------------------------------------------------------------------------------------------------------"

echo "# Test that the commands work fine when ydb_repl_instance/gtm_repl_instance are set to some other .repl files"

echo "# MUPIP FTOK -JNLPOOL"
$MSR RUN INST2 'setenv gtm_repl_instance droids.repl; setenv ydb_repl_instance droids.repl; $MUPIP ftok -JNLPOOL mumps.repl' | grep "mumps.repl  ::" > jnlpool2.txt

echo "# MUPIP FTOK -RECVPOOL"
$MSR RUN INST2 'setenv gtm_repl_instance droids.repl; setenv ydb_repl_instance droids.repl; $MUPIP ftok -RECVPOOL mumps.repl' | grep "mumps.repl  ::" > recvpool2.txt

echo '# $$^%PEEKBYNAME("repl_inst_hdr.jnlpool_semid") and $$^%PEEKBYNAME("repl_inst_hdr.jnlpool_shmid")'
$MSR RUN INST2 '$ydb_dist/mumps -run jnlpool^ydb313' | grep "," > jnlpeek2.txt

echo '# $$^%PEEKBYNAME("repl_inst_hdr.recvpool_semid") and $$^%PEEKBYNAME("repl_inst_hdr.recvpool_shmid")'
$MSR RUN INST2 '$ydb_dist/mumps -run recvpool^ydb313' | grep "," > recvpeek2.txt

echo ""
# Run ydb313_ipcs_check.csh
$gtm_tst/$tst/u_inref/ydb313_ipcs_check.csh jnlpool2.txt recvpool2.txt jnlpeek.txt recvpeek.txt

echo "--------------------------------------------------------------------------------------------------------------------------"

# Set the env vars to pass dbcheck
setenv gtm_repl_instance $gtm

echo ""
echo "# Check and shutdown the DB"
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
