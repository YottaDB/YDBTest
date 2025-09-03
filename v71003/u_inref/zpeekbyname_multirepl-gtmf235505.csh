#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
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
GTM-F235505 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-003_Release_Notes.html#GTM-F235505)

When \$ZGBLDIR is set to a global directory specifying a replication instance and replication has started, the Replication Journal Pool for that instance becomes the source of data reported by \$ZPEEK() and thus %PEEKBYNAME(). Those tools report on replication related blocks including GSL (gtmsource_local_struct,) GLF (gtmsrc_lcl,) JPC (jnlpool_ctl_struct,) and RIH (repl_inst_hdr.) If a global directory does not specify a Replication Instance, the gtm_repl_instance environment variable determines the Instance for its replicated regions. Previously, \$ZPEEK() and %PEEKBYNAME() used the most recently accessed Replication Journal Pool which made reliance on its results problematic. (GTM-F235505)

CAT_EOF
echo

# Set up multisite replication
$MULTISITE_REPLIC_PREPARE 4

echo "# Create the DB"
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate.out


# Start Source and Receiver
$MSR START INST1 INST2
$MSR START INST3 INST4
echo

echo '# On the primaries, do 10 updates just to have done *something*'
$gtm_dist/mumps -run ^%XCMD 'for i=1:1:10 set ^a(i)=$justify(i,50)'
$MSR RUN INST3 '$gtm_dist/mumps -run ^%XCMD "for i=1:1:10 set ^b(i)=i"'
echo '# Sync the primaries to the secondaries to ensure replication has occurred'
$MSR SYNC INST1 INST2 >&! sync1.out
$MSR SYNC INST3 INST4 >&! sync2.out
echo

echo "# Record INST3's jnlpool semid and shmid for later comparison"
$MSR RUN INST3 '$gtm_dist/mumps -run jnlpool^gtmf235505 | grep "," >&! INST3-jnlpool-semshm.out'
set path_INST3 = `grep "INST3.*JNLDIR" msr_instance_config.txt | tr -d '\t' | cut -f 2 -d ':'`
echo "# Specify INST3's replication instance in INST3's global directory"
$MSR RUN INST3 "set msr_dont_trace ; $GDE CHANGE -INSTANCE -FILE_NAME=$path_INST3/mumps.repl >>& GDEchangeINST1_3.out"
echo

echo '## Test 1: The replication journal pool for the replication instance specified in the global directory pointed at by $ZGBLDIR is the data source for %PEEKBYNAME()'
echo '# INST1: Run [$$^%PEEKBYNAME("repl_inst_hdr.inst_info.this_instname")] with $ZGBLDIR set to INST3. Expect INSTANCE3 to be reported.'
$gtm_dist/mumps -run instname^gtmf235505 $path_INST3/mumps.gld | sed 's/[^[:print:]\t\n]//g' | grep ":"
echo

echo "## Test 2: gtm_repl_instance determines the replication instance when the global directory doesn't specify one"
echo "# Set the replication instance for INST1 to INST3 via gtm_repl_instance"
setenv gtm_repl_instance $path_INST3/mumps.repl
echo "# Ensure INST1 is using its own global directory"
setenv gtmgbldir mumps.gld
echo '# INST1: Run [$$^%PEEKBYNAME("repl_inst_hdr.inst_info.this_instname")] with $ZGBLDIR set to no instance. Expect INSTANCE3 to be reported.'
$gtm_dist/mumps -run instname^gtmf235505 none | sed 's/[^[:print:]\t\n]//g' | grep ":"
echo

echo "# Confirm the jnlpool shmid and semid of INST1 correspond to those of INST3"
echo '# INST1: Run [$$^%PEEKBYNAME("repl_inst_hdr.jnlpool_semid")] and [$$^%PEEKBYNAME("repl_inst_hdr.jnlpool_shmid")]'
set inst1semshm = `$gtm_dist/mumps -run jnlpool^gtmf235505 | grep "," | sed 's/.*: \([0-9]*,[0-9]*\).*/\1/g'`
set inst3semshm = `$MSR RUN INST3 'set msr_dont_trace ; cat INST3-jnlpool-semshm.out' | sed 's/.*: \([0-9]*,[0-9]*\).*/\1/g'`
if ("$inst1semshm" != "$inst3semshm") then
	echo "FAIL: INST1 jnlpool shmid,semid is $inst1semshm, but INST3 jnlpool shmid,semid is $inst3semshm"
else
	echo "PASS: INST1 and INST3 jnlpool have the same shmid,semid"
endif
echo

setenv gtm_repl_instance mumps.repl
$MSR STOP INST1 INST2
$MSR STOP INST3 INST4

$gtm_tst/com/dbcheck.csh >>& dbcheck.out
