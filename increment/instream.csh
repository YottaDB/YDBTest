#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2004, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#####################################################
# [Mohammad] C9D03-002249 - $increment(glvn[,expr])
#####################################################
echo "increment test starts ..."
if ($LFE == "L") then
	setenv subtest_list "incrbas incrgv1 incrgv2"
else
	if ($test_gtm_gtcm ==  "GT.CM") then
		setenv subtest_list "incrbas incrgv5"
	else
		setenv subtest_list "incrbas incrgv1 incrgv2 incrgv4"
	endif
endif

$gtm_tst/com/submit_subtest.csh
#
echo "increment test DONE."
