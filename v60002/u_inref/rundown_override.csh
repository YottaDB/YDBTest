#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#######################################################################################
# This subtest verifies changes to MUPIP RUNDOWN that prevent running down the        #
# database if either journaling or replication is enabled, unless a specific override #
# qualifier is provided. The testing involves running two journaling- and two         #
# replication-enabled scenarios, one simulating a process and one simulating a server #
# crash, for each type.                                                               #
#######################################################################################

# Disable random journaling.
setenv gtm_test_jnl NON_SETJNL

# Unset this to get consistent errors with replication.
unsetenv gtm_custom_errors

# Disable replication until it is time to run cases 3 and 4.
set save_test_replic = "$test_replic"
set save_gtm_repl_instance = "$gtm_repl_instance"
unsetenv test_replic
unsetenv gtm_repl_instance

# Run two cases with journaling, the first simulating a process crash (shared memory is kept),
# and the second one simulating a server crash (shared memory is removed).
$gtm_tst/$tst/u_inref/rundown_override_jnl_job.csh 1
$gtm_tst/$tst/u_inref/rundown_override_jnl_job.csh 2

# Reenable replication prior to using MSR framework
setenv test_replic "$save_test_replic"
setenv gtm_repl_instance "$save_gtm_repl_instance"

# Run two cases with replication, the first simulating a process crash (shared memory is kept
# and primary instance left alone), and the second one simulating a server crash (shared memory
# is removed and all processed killed).
$gtm_tst/$tst/u_inref/rundown_override_repl_job.csh 3
$gtm_tst/$tst/u_inref/rundown_override_repl_job.csh 4
