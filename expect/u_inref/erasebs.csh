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
# Verify that special terminal input character ERASE and BACKSPACE key behave correctly, when they have different values, in
# presence of EMPTERM device.

# Test system does not start off with TERM set to anything
if !($?TERM) setenv TERM xterm

if ( "linux" == "$gtm_test_osname") then
	setenv TERM vt220
endif
if ( "sunos" == "$gtm_test_osname" ) then
	if ( -d /usr/local/lib/terminfo ) setenv TERMINFO /usr/local/lib/terminfo
	setenv TERM vt320
endif

expect -f $gtm_tst/$tst/inref/erasebs.exp >&! erasebs.exp.output
@ interactions = `$grep PASS erasebs.exp.output | wc -l`
echo "$interactions terminal interactions involving ERASE special input character and BACKSPACE key are successsful."

