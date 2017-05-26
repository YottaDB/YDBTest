#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#  clntsrvr.csh
#  	-- client server test
echo ENTERING SOCKET CLNTSRVR
setenv gtmgbldir mumps.gld
set randhost=`$gtm_exe/mumps -run %XCMD 'set rand=2+$Random(6) write $$^findhost(rand),!'`
$gtm_tst/com/dbcreate.csh mumps
source $gtm_tst/com/portno_acquire.csh >>& portno.out
$GTM << EOF
s ^configasalongvariablename78901("hostname")="$randhost"
s ^configasalongvariablename78901("delim")=\$C(13)
s ^configasalongvariablename78901("portno")=$portno
h
EOF
$GTM << EOF
d ^socclntsrvr(0)
h
EOF
$gtm_tst/com/dbcheck.csh -extract mumps
$gtm_tst/com/portno_release.csh
echo LEAVING SOCKET CLNTSRVR
