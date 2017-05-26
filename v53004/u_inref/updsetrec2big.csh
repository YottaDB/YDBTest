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
#

echo "CHECKING REC2BIG"
source $gtm_tst/$tst/u_inref/db_chang_keynrec.csh
setenv start_time1 `date +%H_%M_%S`
echo "Starting receiver server ..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh ""on"" $portno $start_time1 < /dev/null "">>&!"" $SEC_SIDE/START_${start_time1}.out"

$gtm_dist/mumps -run %XCMD 'set ^a=$justify("LARGErecLENcheckHere",1000)'

# Check REC2BIG error exists in the log file
source $gtm_tst/$tst/u_inref/check_for_errors.csh "REC2BIG"
cat dbcheck.out
