#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2010, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# zsystem is not good for trigger transactions
#
# zsystem is incompatible with transaction processing. From the documentation,
#    Issuing a ZSYSTEM command inside a transaction destroys the Isolation of that
#    transaction. Because of the way that GT.M implements transaction processing, a
#    ZSYSTEM within a transaction may suffer an indefinite number of restarts
#    ("live lock").
#
# Getting this thing to fail
# zsystem will always release crit, even in the final retry.  Use a local var to
# count the number of times we restart the transaction. The following M program
# accomplishes this part of the task.
setenv gtm_trigger_etrap 'w $c(9),"$zlevel=",$zlevel," : $ztlevel=",$ztle," : $ZSTATUS=",$zstatus,! s $ecode=""'
setenv gtm_tpnotacidtime 0
$gtm_tst/com/dbcreate.csh mumps 1
unsetenv gtm_trigger_etrap
unsetenv gtm_gvdupsetnoop
$gtm_exe/mumps -run trigzsyxplode
setenv test_trigzsyxplode_implicit 1
$gtm_exe/mumps -run implicit^trigzsyxplode
$gtm_tst/com/dbcheck.csh -extract
