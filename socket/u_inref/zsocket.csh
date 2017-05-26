#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
echo ENTERING SOCKET ZSOCKET
#
echo With TCP socket
source $gtm_tst/com/portno_acquire.csh  >>& portno.out
$GTM << EOF
do ^zsocket("$tst_org_host",$portno)
h
EOF
#
$gtm_tst/com/portno_release.csh
echo With LOCAL socket
$GTM << EOF
do ^zsocket("local.sock","LOCAL")
h
EOF
echo LEAVING SOCKET ZSOCKET
