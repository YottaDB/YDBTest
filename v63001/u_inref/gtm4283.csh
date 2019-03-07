#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo '# Test that GT.M compiler accepts <CR><LF> line termination. Previously the compiler would return a GTM-E-SPOREOL error.'
echo ''
echo '# First see if UNIX mumps file runs correctly.'
$ydb_dist/mumps -run gtm4283
echo '# Next convert UNIX to DOS.'
set backslash_quote
perl -p -e 's/\n/\r\n/' < $gtm_tst/$tst/inref/gtm4283.m > gtm4283dos.m
unset backslash_quote
echo '# Now see if DOS mumps file runs correctly.'
$ydb_dist/mumps -run gtm4283dos
