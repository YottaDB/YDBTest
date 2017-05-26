#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
echo ENTERING SOCKET DIC
#
#
setenv gtmgbldir mumps.gld
set randhost=`$gtm_exe/mumps -run %XCMD 'set rand=2+$Random(6) write $$^findhost(rand),!'`
# client2.m uses long subscripts while using global var tcpdevasalongvariablename678901
# The subscript is formed using PID value. On zOS since the PID's are longer(8 char length), the default -key_max_size(64)
# cannot accomodate large subscript values, hence we overide the default key_max_size.
$gtm_tst/com/dbcreate.csh mumps -key=70
# --- configures the test ---
source $gtm_tst/com/portno_acquire.csh >>& portno.out
$GTM << EOF
s ^configasalongvariablename78901("hostname")="$randhost"
s ^configasalongvariablename78901("delim")=\$C(13)
s ^configasalongvariablename78901("portno")=$portno
h
EOF
($gtm_tst/$tst/u_inref/client2.csh >&! client2.out &) >&! client_background.log
$gtm_tst/$tst/u_inref/server2.csh >&! server2.out
# give time for the client2 to read last message
$GTM << EOF
d ^waitforread
h
EOF
# --- stops the client2 process ---
$GTM << EOF
s ^stopasalongvariablename45678901="Y",^stopasalongvariable="N"
h
EOF
# give time for the client2 to pick up the signal
$GTM << EOF
d clientdone^waitforread(120)
h
EOF
$gtm_tst/com/dbcheck.csh -extract mumps
cat client2.out
cat server2.out
#
$gtm_tst/com/portno_release.csh
echo LEAVING SOCKET DIC
