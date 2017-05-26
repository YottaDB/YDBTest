#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2009, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# dbcreate.csh called by db_chang_keynrec.csh and updkillsuboflow.csh.
# Check GVSUBOFLOW error exists in the log file
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log RCVR_${start_time1}.log.updproc -grep -message ""$1"" >>& wait_for_log.logx ; $gtm_tst/com/check_error_exist.csh RCVR_${start_time1}.log.updproc ""$1"" " # BYPASSOK
setenv gtm_test_replic_timestamp `date +%H_%M_%S`
setenv gtm_test_norfsync
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
# Ignore the following errors, as they are a result of update process exiting after the error above
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/check_error_exist.csh SHUT_${gtm_test_replic_timestamp}.out ""TEST-E-RCVR_SHUT""" >>& ignore_err.outx
unsetenv gtm_test_replic_timestamp

# Since the rcvr shutdown above failed, port reservation file would not have been removed. Remove it manually
$sec_shell "$sec_getenv; cd $SEC_SIDE; source $gtm_tst/com/portno_release.csh"
