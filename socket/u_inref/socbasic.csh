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
#	A database (in .zwr format) contains the set of interactions to be tested (what/how to read/write and what the
#	expected results of the read should be). Each interaction between the client and the server is synchronized by a
#	driver routine (socbasic()). The driver uses locks on each of the database items that contain the interactions to ensure
#	that the client and server hookup and exchange data as expected. The driver uses waitforstart() to verify that the
#	the client and the server have acquired their locks before trying to lock it again. The client and the server
#	use locks on leaf nodes (read/write) of the data items to indicate when they are ready to begin an interaction
#	and when they are done with that interaction.
echo ENTERING SOCKET SOCKETBASIC
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
\cp $gtm_tst/$tst/inref/socbasic.zwr .
if ($?gtm_chset) then
	if ($gtm_chset == "UTF-8") then
		# Make extract file compatible with UTF-8 load
		mv socbasic.zwr socbasic.zwr1
		sed 's/GT.M MUPIP EXTRACT/& UTF-8/g' socbasic.zwr1 > socbasic.zwr
	endif
endif
$gtm_exe/mupip load socbasic.zwr
$GTM << EOF
d ^socbasic
h
EOF
sleep 10
$gtm_tst/com/dbcheck.csh -extract mumps
$gtm_tst/com/portno_release.csh
echo LEAVING SOCKET SOCKETBASIC
