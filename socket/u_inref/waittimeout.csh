#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo ENTERING SOCKET WAITTIMEOUT
setenv gtmgbldir mumps.gld
set randhost=`$gtm_exe/mumps -run %XCMD 'set rand=2+$Random(6) write $$^findhost(rand),!'`
$gtm_tst/com/dbcreate.csh mumps 1 125 500 >& dbcreate_detail.out
source $gtm_tst/com/portno_acquire.csh >>& portno.out
$GTM << EOF >& config.out
s ^configasalongvariablename78901("hostname")="$randhost"
s ^configasalongvariablename78901("delim")=\$C(65)
s ^configasalongvariablename78901("portno")=$portno
h
EOF
$gtm_exe/mumps -r waittimeout
$gtm_tst/com/check_error_exist.csh server_cwt.out "TEST-E-TIMEOUT on server connection wait"
$gtm_tst/com/check_error_exist.csh client_rt.out "TEST-E-TIMEOUT on read"
$gtm_tst/com/check_error_exist.csh client_rwt.out "TEST-E-TIMEOUT on wait"
$gtm_tst/com/check_error_exist.csh server_ot_2.out "TEST-E-TIMEOUT on server open"
$gtm_tst/com/portno_release.csh
echo LEAVING SOCKET WAITTIMEOUT
$gtm_tst/com/dbcheck.csh
