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
w !,"Do ztedef^tpwint",! d ztedef^tpwint
h
EOF

$GTM<<EOF
w "Do ztendef^tpwint",! d ztendef^tpwint
h
EOF
$GTM<<EOF
w "Do discint^tpwint",! d discint^tpwint
h
EOF
$GTM<<EOF
w "Do savzte^tpwint",! d savzte^tpwint
h
EOF
$gtm_tst/com/dbcheck.csh -extract
