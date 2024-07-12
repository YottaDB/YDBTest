#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#########################################################################################"
echo "Test that -trigupdate replicates updates inside trigger logic but not trigger definitions"
echo "#########################################################################################"
echo ""

echo "# Set up a 2 instance MSR environment to be used for various test stages below"
$MULTISITE_REPLIC_PREPARE 2

echo "# Randomly choose an older version receiver server (e.g. r1.36 etc.) to verify that"
echo "# those continue to work with the current version source server using -trigupdate."
echo "# This tests that the replication filter functions (jnl_v44TOv44() and jnl_v44TOv22()"
echo "# in the case of r1.38) correctly handle -trigupdate processing on the source server side."
set choose_olderver_rcvr = `shuf -i 0-1 -n 1`
if ($?ydb_test_inside_docker) then
	# Inside the docker container, we don't have prior versions so disable random choice of older version in that case.
	if ( "0" != $ydb_test_inside_docker ) then
		set choose_olderver_rcvr = 0
	endif
endif
if ($choose_olderver_rcvr) then
	# We are going to choose an older version receiver server.
	set rand_ver=`$gtm_tst/com/random_ver.csh -gte V62000 -lt $tst_ver`
	echo $rand_ver > priorver.txt
	source $gtm_tst/com/ydb_prior_ver_check.csh $rand_ver
	source $gtm_tst/com/disable_settings_msr_priorver.csh # Disable settings that do not work with MSR and prior versions
	# Alter the msr_instance_config file to update the receiver side version with the older version
	sed -i '/INST2.*VERSION:/s/'"$tst_ver"'/'"$rand_ver"'/' msr_instance_config.txt
	sed -i '/INST2.*IMAGE:/s/'"$tst_image"'/pro/' msr_instance_config.txt
endif

echo "# Set [gtm_test_trigupdate] env var to 1 so [-trigupdate] is used in source server startup for various tests below"
setenv gtm_test_trigupdate 1
echo ""

echo "-------------------------------------------------------------------------------"
echo "# Test 1 : Test that timestamp usages inside trigger logic get replicated as is with -trigupdate"
echo "-------------------------------------------------------------------------------"
echo '# Create databases and start up replication from INST1 -> INST2'
$gtm_tst/com/dbcreate.csh mumps >& test1_dbcreate.out	# create the database
$MSR START INST1 INST2 RP				# start both instances
echo "# Invoke [mumps -run test1^ydb722]"
$gtm_exe/mumps -run test1^ydb722
echo '# Invoke [$MSR SYNC INST1 INST2]'
$MSR SYNC INST1 INST2
echo "# Verify ^x1 (updated outside trigger) and ^x2 (updated inside trigger) have same values on source and receiver side"
echo '# Before YDB#722, the ^x2 value used to be 1 second higher on the receiver side as it was computed as the $H inside'
echo '# a trigger whereas after YDB#722 with -trigupdate, the ^x2 value gets replicated across as is on the receiver side.'
foreach instance (INST1 INST2)
	echo "# Run [zwrite ^x1,^x2] on $instance and redirect output to $instance.zwr"
	$MSR RUN $instance 'set msr_dont_trace; $ydb_dist/mumps -run zwrtest1^ydb722' > $instance.zwr
end
echo '# Running [diff INST1.zwr INST2.zwr]. Expect NO differences.'
diff INST1.zwr INST2.zwr
echo "# Verify a lot of things by looking at the journal file on source (INST1) and receiver (INST2) side"
echo "# 1) On INST1, we expect to see a TLGTRIG record. But on INST2, we do not. This is because LGTRIG journal records"
echo "#    are not replicated with -trigupdate. We expect to see a NULL record on INST2 instead."
echo "# 2) On INST1, we expect to see a TSET ^x1(1)=1 record with nodeflags=2 (JS_HAS_TRIGGER_MASK) indicating ^x1 had a"
echo "#    trigger defined but on INST2 we expect to see this record with nodeflags=0 indicating ^x1 does not have any"
echo "#    trigger defined there".
echo "# 3) On INST1, we expect to see a USET ^x2(1) record with nodeflags=1 (JS_NOT_REPLICATED_MASK) to indicate this update"
echo "#    that happened inside a trigger invocation should not be replicated. But on INST2 we expect to see this with"
echo "#    nodeflags=0 indicating ^x2(1) was updated outside of a trigger and does not have any trigger definitions."
echo "# 4) On INST1, we expect to see a TZTRIG ^x1(2) record with nodeflags=2 (JS_HAS_TRIGGER_MASK) indicating ^x1 had a"
echo "#    trigger defined and a ZTRIGGER command was invoked but on INST2 we expect to NOT see this record since ZTRIG"
echo "#    journal records are not replicated with -trigupdate."
echo "# 5) On INST1, we expect to see a USET ^x2(2) record with nodeflags=1 (JS_NOT_REPLICATED_MASK) to indicate this update"
echo "#    that happened inside a trigger invocation should not be replicated. But on INST2 we expect to see this as a"
echo "#    TSET ^x2(2) (because this is the first update in this transaction since the ZTRIGGER command did not get replicated)"
echo "#    with nodeflags=0 indicating ^x2(2) was updated outside of a trigger and does not have any trigger definitions."
echo "#    On INST1, this record would have an updnum value of 2 since this happened AFTER the ZTRIGGER command whereas on"
echo "#    INST2, this record would have an updnum value of 1 since the ZTRIGGER journal record did not get replicated at all."
echo "# The salvaged field of NULL record and seqno field of all records is also displayed as these are useful to capture"
echo "# in the reference file."
$gtm_tst/$tst/u_inref/ydb722_jnlextall.csh "test1"
echo '# Shut down replication servers by invoking [dbcheck.csh]'
$gtm_tst/com/dbcheck.csh >& test1_dbcheck.out

echo "-------------------------------------------------------------------------------"
echo "# Test 2 : Test multiple source server startup without and with -trigupdate"
echo "-------------------------------------------------------------------------------"
echo "# Run [unsetenv gtm_test_trigupdate] so [-trigupdate] is NOT used in first source server startup"
unsetenv gtm_test_trigupdate
echo '# Create databases and start up replication from INST1 -> INST2'
echo "# Start source server without -trigupdate"
$gtm_tst/com/dbcreate.csh mumps >& test2_dbcreate.out	# create the database
$MSR START INST1 INST2 RP				# start both instances
echo "# Invoke [mumps -run test2a^ydb722]. This will install triggers"
$gtm_exe/mumps -run test2a^ydb722
echo "# Wait for trigger definitions to be replicated across to receiver side"
echo '# Invoke [$MSR SYNC INST1 INST2]'
$MSR SYNC INST1 INST2
echo "# - Restart source server with -trigupdate"
$MSR STOPSRC INST1 INST2
echo "# Run [setenv gtm_test_trigupdate 1] so [-trigupdate] is used in second source server startup"
setenv gtm_test_trigupdate 1
$MSR STARTSRC INST1 INST2 RP	# Restart source server
echo "# Run updates on source side that invoke triggers"
echo "# Invoke [mumps -run test2b^ydb722]"
$gtm_exe/mumps -run test2b^ydb722
$MSR SYNC INST1 INST2
echo "# Verify that the trigger updates on the source side do get replicated across"
echo "# Also verify that the originating update invoked triggers on the receiver side (using trigger definitions"
echo "#   that were replicated by the previous source server started without -trigupdate) resulting in"
echo "#   duplicate updates inside the trigger"
echo "# Do both the above verification steps by looking at the journal file on the source and receiver side"
echo "# On the source side, SET ^x2(1) should be seen only ONCE whereas on the receiver side it should be seen TWICE"
echo "# Additionally verify nodeflags for each SET record in journal file"
echo "#   On source side, we expect"
echo "#     1) TSET ^x1(1)=1 to have nodeflags=2 (JS_HAS_TRIGGER_MASK) to indicate ^x1 had a trigger defined"
echo "#     2) USET ^x2(1)=1 to have nodeflags=1 (JS_NOT_REPLICATED_MASK) to indicate this update should not be replicated"
echo "#        since this happened inside a trigger"
echo "#   On receiver side, we expect"
echo "#     1) TSET ^x1(1)=1 to have nodeflags=2 (JS_HAS_TRIGGER_MASK) to indicate ^x1 had a trigger defined"
echo "#        If the receiver side is older than r1.32 (which fixed YDB#727), it is possible to have nodeflags=6 to"
echo "#        indicate JS_HAS_TRIGGER_MASK=2 and JS_NULL_ZTWORM_MASK=4 bits defined. So allow for this possibility too"
echo "#        in the reference file"
echo "#     2) USET ^x2(1)=1 to have nodeflags=1 (JS_NOT_REPLICATED_MASK) to indicate this update that happened inside the"
echo "#        trigger invocation on the receiver side should not be replicated"
echo "#     3) USET ^x2(1)=1 to have nodeflags=16 (JS_IS_DUPLICATE) to indicate this update that happened outside the"
echo "#        trigger invocation on the receiver side (due to this record being replicated across by the -trigupdate source"
echo "#        server) was a duplicate set whose value coincided with the value set by the update to ^x2(1) as part of the"
echo "#        trigger invocation on the receiver side"
$gtm_tst/$tst/u_inref/ydb722_jnlextall.csh "test2"
echo '# Shut down replication servers by invoking [dbcheck.csh]'
$gtm_tst/com/dbcheck.csh >& test2_dbcheck.out

echo "-------------------------------------------------------------------------------"
echo "# Test 3 : Test that -trigupdate can be specified as part of [mupip replic -source -activate] too"
echo "-------------------------------------------------------------------------------"
echo '# Create databases and start up passive replication from INST1 -> INST2'
$gtm_tst/com/dbcreate.csh mumps >& test3_dbcreate.out	# create the database
$MSR START INST1 INST2 RP	# needed to create replication instance file (mumps.repl)
$MSR STOPSRC INST1 INST2	# stop source server since we are going to start a passive source server and activate it

# Since this is a passive source server that is not started by a RCVR.csh invocation (due to passive source server being
# started on INST1 in this test), we need to set the "tls" related parameters appropriately just like RCVR.csh does.
source $gtm_tst/com/set_var_tlsparm.csh $gtm_test_cur_sec_name >& test3_tlsparm.out # sets "tlsparm" and "tls_reneg_parm" variables

$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -source -start -passive -log=passive_test3.log -instsecondary=__RCV_INSTNAME__ -updok '$tlsparm' '$tls_reneg_parm >& test3_srcstart1.log
echo "# Invoke [mumps -run test3^ydb722] to do some updates"
$gtm_exe/mumps -run test3^ydb722
echo '# Invoke [$MSR ACTIVATE INST1 INST2 RP]. This will run [mupip replic -source -activate -trigupdate].'
$MSR ACTIVATE INST1 INST2 RP
# The $MSR ACTIVATE command above only signals the passive source server to activate.
# It is possible the activation did not complete when the above command returns.
# Therefore wait for the activation to complete and the active source server to connect to the receiver
# before proceeding to the next step (as $MSR SYNC relies on an active connection).
get_msrtime
$gtm_tst/com/wait_for_log.csh -log SRC_activated_${time_msr}.log -message "New History Content"
$MSR REFRESHLINK INST1 INST2
echo '# Invoke [$MSR SYNC INST1 INST2]'
$MSR SYNC INST1 INST2
echo "# Verify key aspects of journal records on both INST1 and INST2"
echo "# We expect all of the output below to be exactly the same as in [Test 1]"
echo '# with the one exception being the node value of SET records would be 1 (in Test 3) instead of $H (in Test 1)'
$gtm_tst/$tst/u_inref/ydb722_jnlextall.csh "test3"
echo '# Shut down replication servers by invoking [dbcheck.csh]'
$gtm_tst/com/dbcheck.csh >& test3_dbcheck.out

echo "-------------------------------------------------------------------------------"
echo '# Test 4 : Test ZTRIGGER command, $ZTRIGGER function and $ZTWORMHOLE records are not replicated with -trigupdate'
echo "-------------------------------------------------------------------------------"
echo '# Create databases and start up replication from INST1 -> INST2'
$gtm_tst/com/dbcreate.csh mumps >& test1_dbcreate.out	# create the database
$MSR START INST1 INST2 RP				# start both instances
echo "# Invoke [mumps -run test4^ydb722]"
$gtm_exe/mumps -run test4^ydb722
echo '# Invoke [$MSR SYNC INST1 INST2]'
$MSR SYNC INST1 INST2
echo "# Verify key aspects of journal records on both INST1 and INST2"
$gtm_tst/$tst/u_inref/ydb722_jnlextall.csh "test4"
echo '# Shut down replication servers by invoking [dbcheck.csh]'
$gtm_tst/com/dbcheck.csh >& test1_dbcheck.out

