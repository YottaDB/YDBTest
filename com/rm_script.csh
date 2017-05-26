#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2011, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
$gtm_tst/com/chkPWDnoHome.csh
if ($status == 6) then
	echo "TEST-E-RM Not removing files. $PWD is a home directory"
	exit 6
endif
\rm $argv:q
