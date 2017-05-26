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
$switch_chset UTF-8
echo ENTERING SOCKET SOCCHSET
#
source $gtm_tst/com/portno_acquire.csh  >>& portno.out
$GTM << EOF
do ^socchset("$tst_org_host",$portno)
h
EOF
#
$gtm_tst/com/portno_release.csh
echo LEAVING SOCKET SOCCHSET
