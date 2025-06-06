#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-DE533918 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-002_Release_Notes.html#GTM-DE533918)

GT.M issues an NOSOCKETINDEV error the first time a process in direct mode attempts to read from or write to a socket principal device with no socket descriptors, and issues a fatal NOPRINCIO error upon a subsequent attempt. Previously a process that entered direct mode with an empty socket principal device would loop indefinitely and consume CPU resources. (GTM-DE533918)

CAT_EOF
echo

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.log
cp $gtm_tst/$tst/inref/gtmde533918.m .

echo "### Test various scenarios of READ/WRITE commands on a SOCKET device with no active sockets"
echo "### See the following discussions for more details:"
echo "###   1. https://gitlab.com/YottaDB/DB/YDBTest/-/issues/681#note_3102029773"
echo "###   2. https://gitlab.com/YottaDB/DB/YDBTest/-/issues/681#note_3102111987"
echo

set tnum = 1
echo "## Test ${tnum}: test READ command on a SOCKET device with no active sockets"
echo "# Run [T$tnum.m]"
echo "# Expect the routine to complete without errors."
echo "# Previously, the routine never returned because it waited for the jobbed off child, which looped indefinitely."
sed "s/OUTREPLACE/SOCKET:handle1/;s/ERRREPLACE/T$tnum.mje/" gtmde533918.m >&! T$tnum.m
$gtm_dist/mumps -run T$tnum
echo

set tnum = 2
echo "## Test ${tnum}: test READ command on a SOCKET device with no active sockets, and child job output redirected to a file"
echo "# Run [T$tnum.m]"
echo "# Expect parent routine to complete and the child job to issue a NOSOCKETINDEV error. Previously, no error was issued."
sed "s/OUTREPLACE/T$tnum.out/;s/ERRREPLACE/T$tnum.mje/" gtmde533918.m >&! T$tnum.m
$gtm_dist/mumps -run T$tnum
$gtm_tst/com/check_error_exist.csh T$tnum.out "YDB-E-NOSOCKETINDEV"
echo

set tnum = 3
echo "## Test ${tnum}: test WRITE command on a SOCKET device with no active sockets"
echo "# Run [T$tnum.m]"
echo "# Expect the routine to complete without errors."
echo "# Previously, the routine never returned because it waited for the jobbed off child, which looped indefinitely."
sed "s/OUTREPLACE/SOCKET:handle1/;s/ERRREPLACE/T$tnum.mje/" gtmde533918.m >&! T$tnum.m
sed -i 's/read x/write $h/' T$tnum.m  # Use single-quotes to prevent attempted tcsh expansion of `$h`
$gtm_dist/mumps -run T$tnum
echo

set tnum = 4
echo "## Test ${tnum}: test WRITE command on a SOCKET device with no active sockets, and child job output redirected to a file"
echo "# Run [T$tnum.m]"
echo "# Expect parent routine to complete and the child job to issue a NOSOCKETINDEV error. Previously, no error was issued."
sed "s/OUTREPLACE/T$tnum.out/;s/ERRREPLACE/T$tnum.mje/" gtmde533918.m >&! T$tnum.m
sed -i 's/read x/write $h/' T$tnum.m  # Use single-quotes to prevent attempted tcsh expansion of `$h`
$gtm_dist/mumps -run T$tnum
$gtm_tst/com/check_error_exist.csh T$tnum.out "YDB-E-NOSOCKETINDEV"

$gtm_tst/com/dbcheck.csh mumps >& dbcheck.log
