#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# GTM-8108 Test various cases where $data(active_lv) = 0 which in turn caused $query to SIG-11

echo "--------------------------------------------"
echo "Test case 1 : ZSHOW C onto a subscripted lvn"
echo "--------------------------------------------"
$gtm_exe/mumps -run test1^gtm8108

echo "--------------------------------------------"
echo "Test case 2 : ZSHOW B onto a subscripted lvn"
echo "--------------------------------------------"
$gtm_exe/mumps -run test2^gtm8108

echo "--------------------------------------------------------------------------------------------------"
echo "Test case 3 : SET @ onto a subscripted lvn where rhs of set is an undefined unsubscripted variable"
echo "--------------------------------------------------------------------------------------------------"
foreach noundef (0 1)
	foreach sideeffect (0 1 2)
		setenv gtm_noundef $noundef
		setenv gtm_side_effects $sideeffect
		echo "--> Running with gtm_noundef=$gtm_noundef, gtm_side_effects=$gtm_side_effects"
		$gtm_exe/mumps -run test3^gtm8108
	end
end

# GTM-8064 : One testcase
echo "-------------------------------------------------------------------------------------"
echo "Test case 4 : SET @ where src and dst are subscripted lvns and src is alias container"
echo "-------------------------------------------------------------------------------------"
foreach sideeffect (0 1 2)
	setenv gtm_side_effects $sideeffect
	echo "--> Running with gtm_side_effects=$gtm_side_effects"
	$gtm_exe/mumps -run test4^gtm8108
end
setenv gtm_side_effects 0

echo "-----------------------------------------------------------------------------------------"
echo "Test case 5 : MERGE lvn(1)=^gvn where ^gvn is concurrently updated (causing TP restarts)"
echo "-----------------------------------------------------------------------------------------"
$gtm_tst/com/dbcreate.csh mumps 2	# 2 regions needed for spanning-regions to induce implicit TP transactions
$gtm_exe/mumps -run test5^gtm8108
$gtm_tst/com/dbcheck.csh

