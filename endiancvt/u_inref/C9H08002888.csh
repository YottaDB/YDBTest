#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2007, 2013 Fidelity Information Services, Inc	#
#								#
#                                                               #
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test tries to do a database upgrade from V4 to V5.
# Since a V4 version will not be supporting encryption, unconditionally turn off encryption.
setenv test_encryption NON_ENCRYPT

# Basic preparation for the test
source $gtm_tst/$tst/u_inref/endiancvt_prepare.csh

# Randomly choose a prior V5 version.
set prior_ver = `$gtm_tst/com/random_ver.csh -type V5`
if ("$prior_ver" =~ "*-E-*") then
	echo "No prior versions available: $prior_ver"
	exit -1
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver

echo "Randomly chosen prior V5 version is GTM_TEST_DEBUGINFO: [$prior_ver]"
# priorver.txt is to filter the old version names in the reference file
echo $prior_ver >& priorver.txt

echo "# Switch to prior version"
source $gtm_tst/com/switch_gtm_version.csh $prior_ver pro

echo "# Create Database using prior V5 version"
source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_tst/com/dbcreate.csh mumps 1 255 1000 $coll_arg
source $gtm_tst/com/bakrestore_test_replic.csh

echo "# Switch to current version"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image

# Execute GDE exit to upgrade the gld file to the current version
$GDE exit >&! gde_create_label.out

echo "# Do a reorg upgrade"
$MUPIP reorg -upgrade -reg "*" >&! reorg_upgrade.out
set upgrade_stat = $status
if ($upgrade_stat) then
	echo "TEST-E-UPGRADE mupip reorg upgrade failed. Check the database and reorg_upgrade.out"
	echo "The test will exit now."
	exit 1
endif
source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_tst/com/dbcheck.csh
source $gtm_tst/com/bakrestore_test_replic.csh
echo "# Proceed to do endian conversion. It should pass"
$MUPIP endiancvt mumps.dat < yes.txt

echo "# Now copy the database to the remote machine and do an integ check"
$rcp mumps.dat "$tst_remote_host":$SEC_SIDE/
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; source coll_env.csh 1 ;$gtm_tst/$tst/u_inref/integ_check.csh mumps.dat"
