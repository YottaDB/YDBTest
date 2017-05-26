#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# GTM-7718: HANG can truncate decimals
#

setenv TERM xterm
expect -f $gtm_tst/$tst/u_inref/gtm7718.exp | tr '\r' ' ' >&! gtm7718.expected

$grep "Begin HANG accuracy test" gtm7718.expected
$grep "FAIL" gtm7718.expected
$grep "Test complete" gtm7718.expected
