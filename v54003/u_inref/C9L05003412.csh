#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2011, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# C9L05-003412 Test that the GVIS secondary error (as part of GVSUBOFLOW error) does not print garbage
#
$gtm_tst/com/dbcreate.csh mumps 1 1019 2000 2048 # keysize=1019, recsize=2000, blksize=2048

#
echo "# Test : Try with GDE and DSE changes to keysize"
#
# Change keysize of .gld and .dat file (try out all possible value) and see how the GVSUBOFLOW error report changes.
# Changing just the .dat would cause a potentially higher valued .gld keysize to be used and would affect the output.
# Try out keysizes from 3 to 1019 as GDE errors out otherwise.
# Keysizes 3,4 and 5 just print the global name in the error message without any subscripts.
# All the other keysizes print the entire subscripts, so do not randomize 3,4 and 5 keysizes
# Randomly try only with DSE changes to keysize (keeping GDE keysize at 64)
#
set nums = `$gtm_exe/mumps -run rand 1013 64 6` # 64 random numbers between 6 and 1019
foreach num (3 4 5 $nums)
	set gde_key = "64"
	set do_gde = `$gtm_exe/mumps -run rand 2`
	if ($do_gde) set gde_key = "$num"
	echo "##### -key=$gde_key #####" >>&! gde_change_key.out
	$GDE ch -reg DEFAULT -key=$gde_key >>&! gde_change_key.out
	if (0 != $status) then
		echo "Exiting Test at gde stage when num = $num and trying to set gde key to $gde_key"
		break
	endif
	echo "##### -key=$num #####" >>&! dse_change_key.out
	$DSE change -file -key=$num >>&! dse_change_key.out
	if (0 != $status) then
		echo "Exiting Test at dse stage when num = $num"
		break
	endif
	echo "Keysize : GTM_TEST_DEBUGINFO $num"
	$gtm_dist/mumps -run c003412
end
#
$gtm_tst/com/dbcheck.csh
