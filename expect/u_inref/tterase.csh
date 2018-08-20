#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013 Fidelity Information Services, Inc		#
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

echo "# Verify the effect ERASE, BACKSAPCE and DELETE key on empty and noempty terminal with various combinations of"
echo "#         [NO]EMPTERM [NO]ESCAP and [NO]EDIT deviceparameters."
echo ""

# Test system does not start off with TERM set to anything
if !($?TERM) setenv TERM xterm

if ( "linux" == "$gtm_test_osname" && "xterm" != "${TERM}" ) then
	setenv TERM xterm
endif
if ( "sunos" == "$gtm_test_osname" ) then
	if ( -d /usr/local/lib/terminfo ) setenv TERMINFO /usr/local/lib/terminfo
	setenv TERM vt320
endif

# Turn on expect debugging using "-d". The debug output would be in expect.dbg in case needed to analyze stray timing failures.
(expect -d $gtm_tst/$tst/inref/tterase.exp > expect.out) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
perl $gtm_tst/com/expectsanitize.pl expect.out > expect_sanitized.out
cat expect_sanitized.out

