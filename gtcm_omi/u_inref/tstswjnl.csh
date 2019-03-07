#!/usr/local/bin/tcsh  -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
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

alias jnlext '$gtm_exe/mupip journal -extract=\!:1 -forward \!:2 |& $grep -v "Backward processing"'

jnlext extd1.out mumps.mjl
jnlext exta1.out a.mjl
jnlext extb1.out b.mjl

$GTM << endt
w !,"Starting tests via viagtcm^tstswjnl",! do viagtcm^tstswjnl
w "h",! h
endt

#Since we are doing connections across OMI the regions will be open the issue is similar to switching journal files on the fly.

$gtm_exe/mupip set -file -journal=off mumps.dat
jnlext extd2.out mumps.mjl
jnlext exta2.out a.mjl
jnlext extb2.out b.mjl
$gtm_exe/mupip set -file -journal=on,nobe mumps.dat

$GTM << wxyz
w !,"Starting tests via viagtcm^tstswjnl",! do viagtcm^tstswjnl
w "h",! h
wxyz

$GTM << wxyz
;w !,"Starting normal set andi verify test ",! do normal^tstswjnl
w "h",! h
wxyz

jnlext extd3.out mumps.mjl
jnlext exta3.out a.mjl
jnlext extb3.out b.mjl

$gtm_tst/$tst/u_inref/gtcm_stop.csh >& gtcm_stop.log
$gtm_tst/com/dbcheck.csh
