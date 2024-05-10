#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test case was copied wholesale from test/triggers/u_inref/trig2notrig.csh

# Disabled settings that do not work with MSR and prior versions
source $gtm_tst/com/disable_settings_msr_priorver.csh

# In case com/do_random_settings.csh had set "ydb_ipv4_only" env var, make sure "gtm_ipv4_only" env var is also set
# as we use an older version source server below and it is possible that is a pure GT.M build which does not have any
# clue about "ydb_ipv4_only" whereas the current version receiver server will and so there will be a disconnect in that
# the source server will try to use IPv6 address whereas the receiver server will try to use IPv4 address for the same
# host name resulting in no connection happening. Fix that by setting "gtm_ipv4_only" env var to the same value.
if ($?ydb_ipv4_only) then
	setenv gtm_ipv4_only $ydb_ipv4_only
	echo "# gtm_ipv4_only set to match ydb_ipv4_only in gtm8423.csh"	>>&! settings.csh
	echo "setenv gtm_ipv4_only $gtm_ipv4_only"				>>&! settings.csh
endif

# Prepare local and remote directories
$MULTISITE_REPLIC_PREPARE 2

set prior_ver=`$gtm_tst/com/random_ver.csh -type ms`
if ("$prior_ver" =~ "*-E-*") then
	echo "No prior versions available: $prior_ver"
	exit -1
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
echo $prior_ver >& priorver.txt
echo "Randomly chosen multisite version is GTM_TEST_DEBUGINFO: [$prior_ver]"

# Switch to prior version PRO image for instance 1
cp msr_instance_config.txt msr_instance_config.bak
$tst_awk '/^INST1[^0-9]+(VERSION|IMAGE):/ {sub("'$tst_ver'","'$prior_ver'"); sub(/dbg/,"pro")} {print}' msr_instance_config.bak >&! msr_instance_config.txt

$gtm_tst/com/dbcreate.csh mumps 1 125 1024 4096

# Start source and reciever
$MSR START INST1 INST2

# Replicate the greater than 2MB transaction
$MSR RUN INST1 '$gtm_dist/mumps -run gtm8423'

# need to verify the replicated journals and databases.
$MSR STOP INST1 INST2

$gtm_tst/com/dbcheck.csh -extract

