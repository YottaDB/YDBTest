#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
$switch_chset UTF-8
echo ENTERING SOCKET SOCKETBASIC
setenv gtmgbldir mumps.gld
$gtm_tst/com/dbcreate.csh mumps
\cp $gtm_tst/$tst/inref/socbasic.zwr .
source $gtm_tst/com/portno_acquire.csh  >>& portno.out
$GTM << setupconfiguration
s ^config("hostname")="$tst_org_host"
s ^config("delim")=\$C(8233)
s ^config("portno")=$portno
h
setupconfiguration
#
#   test basic functionality of the socket device
#   it tests:
#	1. without delimiter, r x
#	2. without delimiter, r x#3
#	3. without delimiter, r x:20
#	4. without delimiter, r x#3:20
#	5. with delimiter, r x
#	6. with delimiter, r x#3
#	7. with delimiter, r x:20
#	8. with delimiter, r x#3:20
#	A database (in .zwr format) contains the set of interactions to be tested (what/how to read/write and what the
#	expected results of the read should be). Each interaction between the client and the server is synchronized by a
#	driver routine (socbasic()). The driver uses locks on each of the database items that contain the interactions to ensure
#	that the client and server hookup and exchange data as expected. The driver uses waitforstart() to verify that the
#	the client and the server have acquired their locks before trying to lock it again. The client and the server
#	use locks on leaf nodes (read/write) of the data items to indicate when they are ready to begin an interaction
#	and when they are done with that interaction.
$MUPIP load socbasic.zwr
if $status then
	echo "TEST-E-ERROR $MUPIP load socbasic.zwr failed"
	exit 1
endif
#
$gtm_tst/com/backup_dbjnl.csh save "*.dat" cp nozip
$GTM << GTM_EOF
d ^socbasic("")
h
GTM_EOF
#
$gtm_tst/com/backup_dbjnl.csh save_M "*.dat" cp
cp -f save/* .
$GTM << GTM_EOF
s ^config("portno")=$portno
d ^socbasic("UTF-8")
h
GTM_EOF
#
$gtm_tst/com/backup_dbjnl.csh save_UTF-8 "*.dat" cp
cp -f save/* .
$GTM << GTM_EOF
s ^config("portno")=$portno
d ^socbasic("UTF-16LE")
h
GTM_EOF
#
$gtm_tst/com/backup_dbjnl.csh save_UTF-16LE "*.dat" cp
cp -f save/* .
$GTM << GTM_EOF
s ^config("portno")=$portno
d ^socbasic("UTF-16BE")
h
GTM_EOF
#
$gtm_tst/com/backup_dbjnl.csh save_UTF-16BE "*.dat" cp
cp -f save/* .
$GTM << GTM_EOF
s ^config("portno")=$portno
d ^socbasic("UTF-16")
h
GTM_EOF
#
#
#
$gtm_tst/com/dbcheck.csh -extract mumps
$gtm_tst/com/portno_release.csh
echo LEAVING SOCKET SOCKETBASIC
