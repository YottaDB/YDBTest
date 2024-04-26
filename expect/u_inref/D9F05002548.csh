#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# The test currently fails in UTF-8 mode. UNDO once GTM-7758 is fixed
$switch_chset "M" >&! switch_chset
$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run echoline

# Test system does not start off with TERM set to anything
if !($?TERM) setenv TERM xterm

if ( "linux" == "$gtm_test_osname" && "xterm" != "${TERM}" ) then
	setenv TERM xterm
endif
if ( "sunos" == "$gtm_test_osname" ) then
	setenv TERM vt320
	if ( -d /usr/local/lib/terminfo ) setenv TERMINFO /usr/local/lib/terminfo
endif


(expect -d -f $gtm_tst/$tst/inref/d002548.exp $gtm_verno $tst_image $gtm_tst > d002548.logx) >& expect.dbg
cat d002548.logx | $gtm_exe/mumps -run LOOP^%XCMD --xec='/set FAIL=$get(FAIL)+$length(%l,"FAIL")-1,PASS=$get(PASS)+$length(%l,"REGION")-1+$length(%l,"PASS")-1/' --after='/zwrite PASS,FAIL/'
$grep -vE 'KEYWRDBAD|ILLCHAR' d002548.logx >&! d002548.log


$gtm_exe/mumps -run echoline
$gtm_tst/com/dbcheck.csh
