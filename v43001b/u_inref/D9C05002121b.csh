#!/usr/local/bin/tcsh -vf
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
if (! -d bak) mkdir bak
if (! -d baktmp) mkdir baktmp
# Note that "mupip backup -dbg" output can vary across systems. On systems without "copy_file_range()" support
# (e.g. RHEL 7 or RHEL 8) one can see extra lines of the form "cp --sparse=always" and a following empty line.
# Filter these out in order to have a deterministic reference file hence the "$grep" usages below.
$MUPIP backup -nonew -o "*" ./bak -dbg >& backup1.logx
$grep -vE '^$|cp --sparse=always' backup1.logx | sort -f
$MUPIP integ -noonline -reg "*" >>& integ.log
ls ./bak/*
rm ./bak/*
$gtm_exe/mumps -run wait
if ($status) then
	exit -1
endif
ls -l core*
$MUPIP backup -nonew -o "*" ./bak -dbg -i >& backup2.logx
$grep -vE '^$|cp --sparse=always' backup2.logx | sort -f
$MUPIP integ -noonline -reg "*" >>& integ.log
ls ./bak/*
rm ./bak/*
setenv gtm_baktmpdir `pwd`/baktmp
echo "gtm_baktmpdir: $gtm_baktmpdir"
$MUPIP backup -nonew -o "*" ./bak -dbg >& backup3.logx
$grep -vE '^$|cp --sparse=always' backup3.logx | sort -f
$MUPIP integ -noonline -reg "*" >>& integ.log
ls ./bak/*
rm ./bak/*
$gtm_exe/mumps -run wait
if ($status) then
	exit -1
endif
ls -l core*
#sleep 30 # give some time for further updates to the database.
$MUPIP backup -nonew -o "*" ./bak -dbg -i >& backup4.logx
$grep -vE '^$|cp --sparse=always' backup4.logx | sort -f
$MUPIP integ -noonline -reg "*" >>& integ.log
ls ./bak/*
rm ./bak/*
echo "==================================================================="
chmod 000 $gtm_baktmpdir
echo "No read permissions for $gtm_baktmpdir."
$MUPIP backup -nonew -o "AREG" ./bak -dbg
$MUPIP integ -noonline -reg "*" >>& integ.log
ls ./bak/*
rm ./bak/*
$gtm_exe/mumps -run wait
if ($status) then
	exit -1
endif
ls -l core*
$MUPIP backup -nonew -o "AREG" ./bak -dbg -i
$MUPIP integ -noonline -reg "*" >>& integ.log
chmod 755 $gtm_baktmpdir
