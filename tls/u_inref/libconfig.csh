#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test that both encryption and TLS information can reside in the same configuration file.

if ("$test_encryption" == "NON_ENCRYPT") then
	echo "This subtest requires encryption. Exiting.."
	exit 1
endif

# Set plaintext fallback option so that the source/receiver server doesn't die and it makes the testing easy.
setenv gtm_test_plaintext_fallback

$MULTISITE_REPLIC_PREPARE 2

$MULTISITE_REPLIC_ENV

$gtm_tst/com/dbcreate.csh mumps 3
$MSR START INST1 INST2 RP
get_msrtime
set logfile = SRC_${time_msr}.log
# Wait for the source and receiver to have reached a restartable position.
$MSR RUN INST1 "set msr_dont_trace; $gtm_tst/com/wait_for_log.csh -log $logfile -message 'Received REPL_TLS_INFO message'"

# Now stop replication.
$MSR STOP INST1 INST2

# Now, unset gtm_dbkeys so that we know for sure that it is not being used by the plugin.
unsetenv gtm_dbkeys
echo "unsetenv gtm_dbkeys"	>&! env_supplementary.csh

# Now, start replication.
$MSR START INST1 INST2 RP

$gtm_exe/mumps -run %XCMD 'set (^a,^b,^x)=1'

$gtm_tst/com/dbcheck.csh -extract
