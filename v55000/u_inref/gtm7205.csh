#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Create a db with 10 pages. The lockqueue fills up the lock queue. Ensure the error message is in syslog
echo "Begin gtm7205"
$gtm_tst/com/dbcreate.csh mumps 1 -lock_space=10
$gtm_exe/mumps -run randomsubstr
set syslog_before1 = `date +"%b %e %H:%M:%S"`
$gtm_exe/mumps -run lockqueue
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog1.txt "" "GTM-E-LOCKSPACEFULL"
if ($status) then
    echo "TEST-E-FAIL GTM-E-LOCKSPACEFULL not found in operator log. Check syslog1.txt."
else
    echo "TEST-I-PASS GTM-E-LOCKSPACEFULL found in operator log as expected."
endif
echo "End gtm7205"
$gtm_tst/com/dbcheck.csh
