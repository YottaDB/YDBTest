#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
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

# If this test chose r120 as the prior version, that won't work if ydb_msgprefix is not set to "GTM".
# (https://github.com/YottaDB/YottaDB/issues/193). Therefore, set ydb_msgprefix to "GTM" in that case.
if ($prior_ver == "V63003A_R120") then
	setenv ydb_msgprefix "GTM"
endif

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

