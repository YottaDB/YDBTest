#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
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

# Verify that mu_rndwn_replpool_ch is not called outside of the mu_rndwn_replpool function

# This test switches DIST directories. Do not rely on the default encryption
# key setup as it depends on $gtm_dist, which will be different between
# dbcreate and the following tests. Instead use gtm_obfuscation_key to have it
# the same across all DISTs.
if ("ENCRYPT" == "$test_encryption") then
        echo "randomstring" >&! gtm_obfuscation_key.txt
        setenv gtm_obfuscation_key $PWD/gtm_obfuscation_key.txt
        setenv encrypt_env_rerun
        source $gtm_tst/com/set_encrypt_env.csh $tst_general_dir $gtm_dist $tst_src >>! $tst_general_dir/set_encrypt_env.log
        if ("TRUE" == "$gtm_test_tls" ) source $gtm_tst/com/set_tls_env.csh
        unsetenv encrypt_env_rerun
endif

set prior_ver = `$gtm_tst/com/random_ver.csh -gte V61000 -lte V61000`
if ("$prior_ver" =~ "*-E-*") then
	echo "No such prior version : $prior_ver"
	exit -1
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
echo "# Launching a source and a receiver with $prior_ver"

# Do not use DBG version below as it can create a core in MUPIP RUNDOWN
source $gtm_tst/com/switch_gtm_version.csh $prior_ver pro

$MULTISITE_REPLIC_PREPARE 2

$tst_awk '{if ("VERSION:" == $2) {sub("'$tst_ver'","'$prior_ver'")} ; print }' msr_instance_config.txt >&! msr_instance_config.tmp

mv msr_instance_config.{tmp,txt}

$MULTISITE_REPLIC_ENV

$gtm_tst/com/dbcreate.csh mumps >& prior_ver_dbcreate.out

# Make sure the correct version was used during database configuration
$grep -q "^Using: .*$prior_ver.*/mumps" prior_ver_dbcreate.out
if (0 != $status) then
    echo "The database is not created with $prior_ver. Please check prior_ver_dbcreate.out."
    exit -1
endif

$MSR START INST1 INST2

$gtm_tst/com/primary_crash.csh "NO_IPCRM"

echo "# Switch to the current version now"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image

echo "# Taking away write permissions from mumps.repl so that we get an additional error after the version mismatch error"
chmod 444 mumps.repl

echo "# MUPIP RUNDOWN will generate two errors: A version mismatch error followed by a file permission error (when trying to write to mumps.repl)"
echo "# This should not crash with SIGSEGV"
$MUPIP rundown >&! user_rundown.outx

echo "# The test is over. Give the write permissions back"
chmod 644 mumps.repl

echo "# Switch to the older version so that we can shutdown receiver"
source $gtm_tst/com/switch_gtm_version.csh $prior_ver pro

$MSR STOPRCV INST1 INST2

echo "# Do a MUPIP RUNDOWN to cleanup the shared resources created by crashed source server"
$MUPIP rundown >& mupip_clean_shared.outx

#dbcheck is not needed as we know the database is in a broken state at this moment
$pri_shell "$pri_getenv ; cd $PRI_SIDE; source $gtm_tst/com/portno_release.csh"
