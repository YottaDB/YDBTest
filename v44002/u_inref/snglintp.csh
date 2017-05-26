#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
source $gtm_tst/com/dbcreate.csh mumps
setenv gtm_poollimit 0 # Setting gtm_poollimit will cause some transactions to restart. Not desirable in this test.

$GTM<<EOF
w !,"Do cmmit^snglintp",! d cmmit^snglintp
h
EOF
#
$GTM<<EOF
w !,"Do cmmitd^snglintp",! d cmmitd^snglintp
h
EOF
#
$GTM<<EOF
w !,"Do rollbck^snglintp",! d rollbck^snglintp
h
EOF
#
$GTM<<EOF
w !,"Do rollbckd^snglintp",! d rollbckd^snglintp
h
EOF
$gtm_tst/com/dbcheck.csh -extract
