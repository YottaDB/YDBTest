#!/usr/local/bin/tcsh -f
#################################################################
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

$GTM -dir <<EOF
Write "Test 1: We expect this process to be killed and create a YDB_FATAL_ERROR* file",!
Set x=\$ZSigproc(\$Job,4)   ; Kill ourselves with a kill -4
EOF
set fef = `ls -1 YDB_FATAL_ERROR*`
if (-e $fef) then
    echo "Test 1: YDB_FATAL_ERROR file successfully created"
else
    echo "Test 1: FAIL -- YDB_FATAL_ERROR file was not created"
endif
if ("os390" == "$gtm_test_osname") then
    \rm -f gtmcore*
else
    \rm -fr core*
endif
\rm $fef

$GTM -dir <<EOF
Write "Test 2: We expect this process to die with a KILLBYSIGUINFO message and create a YDB_FATAL_ERROR* file",!
ZMessage 150377796    ; Kill ourselves forcing a fatal error message
EOF
set fef = `ls -1 YDB_FATAL_ERROR*`
if (-e $fef) then
    echo "Test 2: YDB_FATAL_ERROR file successfully created"
else
    echo "Test 2: FAIL -- YDB_FATAL_ERROR file was not created"
endif
if ("os390" == "$gtm_test_osname") then
    \rm -f gtmcore*
else
    \rm -fr core*
endif
\rm $fef
