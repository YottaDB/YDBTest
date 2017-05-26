#!/usr/local/bin/tcsh -f
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
#
# the script does a MUPIP backup & restore over TCP connection for the caller
# specified GT.M version
# script accepts two arguments.
# first argument specifes the version for MUPIP backup(sending system)
# second argument specifes the version for MUPIP restore(receiving system)
#
# switch to the sending system version
source $gtm_tst/com/switch_gtm_version.csh $1 $tst_image
echo "sending system in now in $1"
$gtm_tst/com/dbcreate.csh mumps
# do some sample tests
$GTM << EOF
set ^a=1,^b=1
halt
EOF
echo "Iam here"
set randhost=`$gtm_exe/mumps -run %XCMD 'set rand=2+$Random(6) write $$^findhost(rand),!'`
# take a TCP incremental backup
$MUPIP backup -o -i -t=1 -nettimeout=420 DEFAULT "tcp://${randhost}:6200"
echo "backup done"
# switch to the receiving system version
source $gtm_tst/com/switch_gtm_version.csh $2 $tst_image
echo "receiving system is now in $2"
# do a TCP 2 mupip restore
$MUPIP restore -nettimeout=420 mumps.dat "tcp://${randhost}:6200" >&! tcprestore.log
if ($status == 0 && $1 != $2) then
	echo "TEST-E-ERROR. error restoring $1 from $2 version expected but got none"
else if($status && $1 == $2) then
	echo "TEST-E-ERROR. mupip restore expected to pass but failed"
else
	echo "PASS"
endif
$gtm_tst/com/dbcheck.csh
