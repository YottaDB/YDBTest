#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "Unicode SOCKET test Starts..."
if ( "TRUE" == $gtm_test_unicode_support ) then
	setenv subtest_list "socbasic dic clntsrvr zffu16 delimjob socchset"
	if ($LFE == "E") then
	   setenv subtest_list "$subtest_list socdevice socdevice_long"
	endif
else
	setenv subtest_list ""
endif
$gtm_tst/com/submit_subtest.csh
echo "Unicode SOCKET test DONE."
