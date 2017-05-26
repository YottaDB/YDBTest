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
#
source $gtm_tst/com/dbcreate.csh mumps
setenv gtm_poollimit 0 # Setting gtm_poollimit will cause some transactions to restart. Not desirable in this test.
#setenv gtm_zinterrupt "do usrint^multiple"
$GTM<<EOF
w !,"Do multdef^multiple",! d multdef^multiple
s a=""
f  s a=\$o(^done(a))  q:a=""  w !,a
h
EOF
#
$GTM<<EOF
w "Do muldefrb^multiple",! d muldefrb^multiple
s a=""
f  s a=\$o(^done(a))  q:a=""  w !,a
h
EOF
#
$GTM<<EOF
w "Do mundefrb^multiple",! d mundefrb^multiple
s a=""
f  s a=\$o(^done(a))  q:a=""  w !,a
h
EOF
#
$GTM<<EOF
w "Do multndef^multiple",! d multndef^multiple
s a=""
f  s a=\$o(^done(a))  q:a=""  w !,a
h
EOF
#unsetenv gtm_zinterrupt
$gtm_tst/com/dbcheck.csh -extract


