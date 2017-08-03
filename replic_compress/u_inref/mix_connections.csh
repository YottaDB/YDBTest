#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that the same source server which was started with compression enabled uses compression if the receiver
# supports compression and does not if it is running an older version that does not support it.
#
# If a dual-site scenario is used and the secondary is upgraded and downgraded alternatively, we will have issues with  changes in
# database format, journal format, gld format and replication instance file format. To make it simple, we go the MSR way.
# INST1 always is up and connected to "INSTANCE2". 2 more secondary instances INST2 and INST3 are created and tweaked such that
# both of them has the same instance name and uses the same port, but one will support compression and one will not.
# From INST1's point, it just talks to INSTANCE2, which keeps switching versions.

# Disabled settings that do not work with MSR and prior versions
source $gtm_tst/com/disable_settings_msr_priorver.csh encryption

$MULTISITE_REPLIC_PREPARE 3
# Pick a prior multisite version that doesn't support replication compression
# V51000 is the first version that supported multisite replic and V53003 is the first version that supported replic compression
setenv prior_ver `$gtm_tst/com/random_ver.csh -gte V51000 -lt V53003`
if ("$prior_ver" =~ "*-E-*") then
	echo "No prior versions available: $prior_ver"
	exit -1
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
# Disable IPv6 on versions prior to its introduction
if ( `expr "$prior_ver" \<= "V60002"` ) setenv test_no_ipv6_ver 1
echo "$prior_ver" > priorver.txt
echo "Randomly chosen pre-V53003 version is GTM_TEST_DEBUGINFO: [$prior_ver]"
set linestr = "----------------------------------------------------------------------"
set newline = ""
echo $linestr

# Choose a valid compression level from 1 to 9
@ validcmplvl  = 1 + `$gtm_exe/mumps -run rand 9`

# Set gtm_zlib_cmp_level to a <valid-value> before starting both source and receiver servers.
setenv gtm_zlib_cmp_level $validcmplvl

# Record the above overrides into settings.csh as well in case dbcreate sources settings.csh
echo "# gtm_zlib_cmp_level set by the subtest (mix_connections.csh)"	>> settings.csh
echo "setenv gtm_zlib_cmp_level $gtm_zlib_cmp_level"			>> settings.csh

# Make sure CMPLVL qualifier is not used.
unsetenv gtm_test_repl_src_cmplvl
unsetenv gtm_test_repl_rcvr_cmplvl

# Tweak configuration file
# Change the instance name of instance3 to be INSTANCE2
# Change the version of instance3 to be the randomly picked multi-site version
cp msr_instance_config.txt msr_instance_config.bak
$tst_awk '{if (("INSTNAME:" == $2) && ("INSTANCE3" == $3)) {sub("INSTANCE3","INSTANCE2")} print }' msr_instance_config.txt  >&! msr_instance_config.txt1
$tst_awk '{if (("INST3" == $1) && ("VERSION:" == $2)) {sub("'$tst_ver'","'$prior_ver'")} print }' msr_instance_config.txt1 >&! msr_instance_config.txt2
cp msr_instance_config.txt2 msr_instance_config.txt
\rm msr_instance_config.txt1 msr_instance_config.txt2
$MULTISITE_REPLIC_ENV

echo "# Create databases, enable replication and start current version source server and receiver server"
$gtm_tst/com/dbcreate.csh mumps
$MSR START INST1 INST2
get_msrtime
# The above command has the timstamp of the SRC log file in the env.variable $time_msr
# Get the port number of INST2 and update it to be the port number of INST3 too
set inst2_port = `$MSR RUN INST2 'set msr_dont_trace ; cat portno'`
$tst_awk '{if (("INST3" == $1) && ("PORTNO:" == $2)) {sub("UNINITIALIZED","'$inst2_port'")} print }' msr_instance_config.txt >&! msr_instance_config.txt1
mv msr_instance_config.txt1 msr_instance_config.txt

# With the all the above tweaks, both INST2 and INST3 have the same name (INSTANCE2) and uses the same port (reserved by INST2)
# The SRC will keep running talking to "INSTANCE2" and a given port.
# The receiver switches between INST2 and INST3 having new and prior versions respectively
echo "# Do Round I of updates"
$GTM << GTM_EOF
	set ^test(1)=\$j(1,200)
GTM_EOF

echo "# Sync Round I updates to the secondary"
$MSR SYNC INST1 INST2

set yescmpexactlvlstr = "Using zlib compression level $validcmplvl for replication"
set nocmpstr          = "Defaulting to NO compression"

set srclog = SRC_${time_msr}.log
echo "# Check that source server logs show compression happened in Round-I"
$grep -E "$yescmpexactlvlstr|$nocmpstr" $srclog

echo "# Shut down receiver server"
$MSR STOPRCV INST1 INST2 RESERVEPORT

# V53003 Source server (with compression enabled) should connect to pre-V53003 receiver.
echo "# Start pre-V53003 receiver server"
$MSR STARTRCV INST1 INST3

echo "# Do Round II of updates"
$GTM << GTM_EOF
	set ^test(2)=\$j(1,200)
GTM_EOF

echo "# Sync Round II updates to the secondary"
$MSR SYNC INST1 INST3

# Verify source server logs show NO compression.
echo "# Check that source server logs show compression happened in Round-I but NOT in Round-II"
$grep -E "$yescmpexactlvlstr|$nocmpstr" $srclog

# Shut down pre-V53003 receiver and start V53003 receiver.
echo "# Shut down pre-V53003 receiver server"
$MSR STOPRCV INST1 INST3 RESERVEPORT
$MSR STARTRCV INST1 INST2

echo "# Do Round III of updates"
$GTM << GTM_EOF
	set ^test(3)=\$j(1,200)
GTM_EOF

echo "# Sync Round III updates to the secondary"
$MSR SYNC INST1 INST2

# Sync the Round III updates with the pre-V53003 receiver too (for dbcheck -extract to work)
$MSR STOPRCV INST1 INST2 RESERVEPORT
$MSR STARTRCV INST1 INST3
$MSR SYNC INST1 INST3
$MSR STOP INST1 INST3

# Verify source server logs show compression is ENABLED.
echo "# Check that source server logs show compression happened in Round-I, NOT in Round-II and back to YES in Round-III"
$grep -E "$yescmpexactlvlstr|$nocmpstr" $srclog

#-----------------------------------------------------------------------------------------------------------------
echo "# Check that ALL updates until now have been replicated across irrespective of whether compression was used."
#
$gtm_tst/com/dbcheck.csh -extract
