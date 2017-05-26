#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#! /usr/local/bin/tcsh
# Read PID from all *.mjo* files
# Wait for all of them to die
set test = 1
if ($gtm_test_jobid != 0) then
	set pidall=`$tst_awk '$1 ~ /PID/ {printf("%s ",$2);}' *{$gtm_test_jobid.mjo}*`
else
	set pidall=`$tst_awk '$1 ~ /PID/ {printf("%s ",$2);}' *.mjo*`
endif
foreach pid ($pidall)
	$gtm_tst/com/wait_for_proc_to_die.csh $pid 3600
end
