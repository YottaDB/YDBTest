#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#gtm7060.csh tests cases in M mode where $X exceeds width.  Without these changes
#GT.M generates SYSTEM-E-ENO14, Bad address

$switch_chset M
$echoline
echo "**************************** gtm7060 in M mode ****************************"
$echoline
set tests="test1 test2 test3 test4 test5 test6"
foreach testn ($tests)
	$gtm_dist/mumps -run gtm7060 $testn
	cat $testn.out
	echo "End of $testn output"
end

#tests cases in Unicode mode where $X exceeds width.  No change from current version
#the primary difference between gtm7060.m and utfgtm7060.m is that the latter uses a width and recordsize
#to support testing of multi-byte UTF-8 characters
if ("TRUE" == $gtm_test_unicode_support) then
    	$echoline
	echo "**************************** gtm7060 in UTF-8 mode ****************************"
	$echoline
	$switch_chset UTF-8
	set utests="utest1 utest2 utest3 utest4 utest5 utest6"
	foreach utestn ($utests)
		$gtm_dist/mumps -run utfgtm7060 $utestn
		cat $utestn.out
		echo "End of $utestn output"
	end
endif
