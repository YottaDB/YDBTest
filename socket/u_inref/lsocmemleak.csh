#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo ENTERING LOCAL SOCKET SOCKETMEMLEAK
setenv gtmgbldir mumps.gld
$gtm_tst/com/dbcreate.csh mumps
$GTM << EOF
s ^config("path")="local.sock"
h
EOF
$GTM << EOF
d ^lsocmemleak
h
EOF
$gtm_tst/com/dbcheck.csh -extract mumps
echo LEAVING LOCAL SOCKET SOCKETMEMLEAK
