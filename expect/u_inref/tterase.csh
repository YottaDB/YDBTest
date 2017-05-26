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
# Verify the effect ERASE, BACKSAPCE and DELETE key on empty and noempty terminal with various combinations of [NO]EMPTERM,
# [NO]ESCAP and [NO]EDIT deviceparameters.

# Test system does not start off with TERM set to anything
if !($?TERM) setenv TERM xterm

if ( "linux" == "$gtm_test_osname" && "xterm" != "${TERM}" ) then
	setenv TERM xterm
endif
if ( "sunos" == "$gtm_test_osname" ) then
	if ( -d /usr/local/lib/terminfo ) setenv TERMINFO /usr/local/lib/terminfo
	setenv TERM vt320
endif

expect -f $gtm_tst/$tst/inref/tterase.exp >&! tterase.exp.output
@ interactions = `$grep PASS tterase.exp.output | wc -l`
echo "$interactions terminal interactions involving ERASE special input character, BACKSPACE and DELETE keys are successsful."
