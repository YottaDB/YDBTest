#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#######################################################################################################
# mu_bkup_stop.csh
# The test is for MUPIP BACKUP with multiple regions with enough data in the files so that we have time
# to "mess with them" a bit and cause errors.
# We will do an online MUPIP backup when the updates are going on and those processes tries to copy the
# dirty blocks into a temporary file when the shared memory segments are already FULL.
# At this point we will do a MUPIP stop of the backup which should remove the temp files and
# shut off the backup flag. We will then restart the backup to be sucessfull.
########################################################################################################
#
echo "MUPIP ONLINE BACKUP TEST FOR LARGE DATABASES AND A MUPIP STOP AT HALF WAY STAGE"
echo "TRY THREE TIMES TO CATCH AND STOP THE BACKUP PROCESS"

# Turn off statshare related env var as it sometimes causes a test failure and is not pertinent to the
# purpose of this test (see https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1982#note_1905363725).
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

#
alias stopsubtest '$gtm_exe/mumps -run stop^largeupdates ; $gtm_exe/mumps -run wait^largeupdates ; unsetenv GTM_BAKTMPDIR ; setenv skip_permission_check 0; setenv save_io 0'
source $gtm_tst/$tst/u_inref/retry_driver.csh "mu_bkup_stop"
