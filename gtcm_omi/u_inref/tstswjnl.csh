#!/usr/local/bin/tcsh  -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv gtmgbldir "mumps.gld"

$gtm_tst/$tst/u_inref/gtcm_start.csh >& gtcm_start.log
$gtm_tst/com/dbcreate.csh mumps 3

$gtm_exe/mupip set -file -journal=on,nobe,enable mumps.dat
$gtm_exe/mupip set -file -journal=on,nobe,enable a.dat
$gtm_exe/mupip set -file -journal=on,nobe,enable b.dat

$gtm_exe/mupip journal -extract=extd1.out -forward mumps.mjl
$gtm_exe/mupip journal -extract=exta1.out -forward a.mjl
$gtm_exe/mupip journal -extract=extb1.out -forward b.mjl

$GTM << endt
w !,"Starting tests via viagtcm^tstswjnl",! do viagtcm^tstswjnl
w "h",! h
endt

#Since we are doing connections across OMI the regions will be open the issue is similar to switching journal files on the fly.

$gtm_exe/mupip set -file -journal=off mumps.dat
$gtm_exe/mupip journal -extract=extd2.out -forward mumps.mjl
$gtm_exe/mupip journal -extract=exta2.out -forward a.mjl
$gtm_exe/mupip journal -extract=extb2.out -forward b.mjl
$gtm_exe/mupip set -file -journal=on,nobe mumps.dat

$GTM << wxyz
w !,"Starting tests via viagtcm^tstswjnl",! do viagtcm^tstswjnl
w "h",! h
wxyz

$GTM << wxyz
;w !,"Starting normal set andi verify test ",! do normal^tstswjnl
w "h",! h
wxyz

$gtm_exe/mupip journal -extract=extd3.out -forward mumps.mjl
$gtm_exe/mupip journal -extract=exta3.out -forward a.mjl
$gtm_exe/mupip journal -extract=extb3.out -forward b.mjl

$gtm_tst/$tst/u_inref/gtcm_stop.csh >& gtcm_stop.log
$gtm_tst/com/dbcheck.csh
