#!/usr/local/bin/tcsh -vf
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
if (! -d bak) mkdir bak
if (! -d baktmp) mkdir baktmp
$MUPIP backup -nonew -o "*" ./bak -dbg |& sort -f
$MUPIP integ -reg -noonline "*" >>& integ.log
ls ./bak/*
rm ./bak/*
$gtm_exe/mumps -run wait
if ($status) then
	exit -1
endif
ls -l core*
$MUPIP backup -nonew -o "*" ./bak -dbg -i |& sort -f
$MUPIP integ -reg -noonline "*" >>& integ.log
ls ./bak/*
rm ./bak/*
setenv gtm_baktmpdir `pwd`/baktmp
echo "gtm_baktmpdir: $gtm_baktmpdir"
$MUPIP backup -nonew -o "*" ./bak -dbg |& sort -f
$MUPIP integ -reg -noonline "*" >>& integ.log
ls ./bak/*
rm ./bak/*
$gtm_exe/mumps -run wait
if ($status) then
	exit -1
endif
ls -l core*
#sleep 30 # give some time for further updates to the database.
$MUPIP backup -nonew -o "*" ./bak -dbg -i |& sort -f
$MUPIP integ -reg -noonline "*" >>& integ.log
ls ./bak/*
rm ./bak/*
echo "==================================================================="
chmod 000 $gtm_baktmpdir
echo "No read permissions for $gtm_baktmpdir."
$MUPIP backup -nonew -o "AREG" ./bak -dbg
$MUPIP integ -reg -noonline "*" >>& integ.log
ls ./bak/*
rm ./bak/*
$gtm_exe/mumps -run wait
if ($status) then
	exit -1
endif
ls -l core*
$MUPIP backup -nonew -o "AREG" ./bak -dbg -i
$MUPIP integ -reg -noonline "*" >>& integ.log
chmod 755 $gtm_baktmpdir
