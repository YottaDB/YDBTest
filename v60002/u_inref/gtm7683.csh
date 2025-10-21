#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# GTM-7683: Making mutex queue slots user-configurable
#

$gtm_tst/com/dbcreate.csh mumps 1

echo "# Test that shared memory gets set up correctly after changing mutex space"
$gtm_exe/mumps -run %XCMD "set ^x=1"
$MUPIP set -file mumps.dat -mutex_slots=32768
$gtm_exe/mumps -run %XCMD "set ^x=2"
$MUPIP set -file mumps.dat -mutex_slots=1024
$gtm_exe/mumps -run %XCMD "set ^x=3"
$MUPIP set -file mumps.dat -mutex_slots=16384
$gtm_exe/mumps -run %XCMD "set ^x=4"
$MUPIP set -file mumps.dat -mutex_slots=2048
$gtm_exe/mumps -run %XCMD "set ^x=5"
echo "# Verify mutex settings in file header by doing a [grep -i Mutex] of [dse dump -file] output"
$DSE dump -fileheader |& $grep -i "Mutex"

echo "# Expect MUPIP SET errors"
$MUPIP set -file mumps.dat -mutex_slots=63
$MUPIP set -file mumps.dat -mutex_slots=32769

$gtm_tst/com/dbcheck.csh
