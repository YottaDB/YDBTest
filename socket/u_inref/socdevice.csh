#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo ENTERING SOCKET SOCDEVICE
setenv gtmgbldir mumps.gld
set randhost=`$gtm_exe/mumps -run %XCMD 'set rand=2+$Random(6) write $$^findhost(rand),!'`
$gtm_tst/com/dbcreate.csh mumps 1 125 500
source $gtm_tst/com/portno_acquire.csh >>& portno.out
$GTM << EOF
s ^configasalongvariablename78901("hostname")="$randhost"
s ^configasalongvariablename78901("delim")=\$C(65)
s ^configasalongvariablename78901("portno")=$portno
h
EOF
\cp $gtm_tst/$tst/inref/socdev.zwr .
if ($?gtm_chset) then
	if ($gtm_chset == "UTF-8") then
		# Make extract file compatible with UTF-8 load
		mv socdev.zwr socdev.zwr1
		sed 's/GT.M MUPIP EXTRACT/& UTF-8/g' socdev.zwr1 > socdev.zwr
	endif
endif
$gtm_exe/mupip load socdev.zwr
$GTM << EOF
d ^socdev
h
EOF
$gtm_tst/com/dbcheck.csh -extract mumps
mkdir test1
cp -p *.* test1
$gtm_tst/com/portno_release.csh

if ($LFE == "E") then
	# test long strings
	$gtm_tst/com/dbcreate.csh mumps 1 125 500
	source $gtm_tst/com/portno_acquire.csh >>& portno.out
	$GTM << EOF
s ^configasalongvariablename78901("hostname")="$randhost"
s ^configasalongvariablename78901("delim")=\$CHAR(58)
s ^configasalongvariablename78901("portno")=$portno
d ^socset
h
EOF
	$gtm_dist/mumps -run socdev >&! socdev_longstr.out
	cat socdev_longstr.out
	$grep "E-FAILED" socdev_longstr.out >! /dev/null
	if (! $status) then
		echo "TEST-E-FAILED"
		cp $gtm_tst/$tst/inref/prntlogs.m .
		cp $gtm_tst/com/{shrnkfil.m,longstr.m} .
		echo "Analyze logs by running: $gtm_dist/mumps -run prntlogs"
	endif

	$gtm_tst/com/dbcheck.csh -extract mumps
	$gtm_tst/com/portno_release.csh
endif
echo LEAVING SOCKET SOCDEVICE
