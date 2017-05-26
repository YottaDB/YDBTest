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

# Verify that the deviceparameter EMPTERM is properly shown in zshow output.

# Test system does not start off with TERM set to anything
if !($?TERM) setenv TERM xterm

if ( "linux" == "$gtm_test_osname" && "xterm" != "${TERM}" ) then
	setenv TERM xterm
endif
if ( "sunos" == "$gtm_test_osname" ) then
	setenv TERM vt320
	if ( -d /usr/local/lib/terminfo ) setenv TERMINFO /usr/local/lib/terminfo
endif

cp $gtm_tst/$tst/inref/gtm7675.csh .
expect -f $gtm_tst/$tst/inref/zshow.exp >&! zshow.exp.output
cat zshow.op
