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
echo ENTERING LOCAL C9G04002779 Socket and Mupip interrupt test
setenv gtmgbldir mumps.gld
$gtm_tst/com/dbcreate.csh mumps
$GTM << EOF
s ^config("delim")=\$C(13)
s ^config("path")="local.sock"
h
EOF

$gtm_dist/mumps -run ltsockzintr >&! ltsockzintr.out
$grep -vE '^$' ltsockzintr.out

# look in done.log if any errors
$gtm_dist/mumps -run ^%XCMD 'zwrite ^done' >&! done.log

sleep 5
$gtm_tst/com/dbcheck.csh -extract mumps
echo LEAVING LOCAL C9G04002779 Socket and Mupip interrupt test
