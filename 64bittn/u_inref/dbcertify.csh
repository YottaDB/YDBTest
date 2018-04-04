#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2005-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.	     	  	     			#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test to check dbcertify functionality
#
# If gtm_gvdupsetnoop is set randomly, the test for DBCMODBLK2BIG in certify testing will fail.
# So unconditionally disable gtm_gvdupsetnoop
unsetenv gtm_gvdupsetnoop
#
setenv v5cbsupath `echo $gtm_pct`
# check for dbcertify-scan phase (PHASE-I)
echo ""
echo "dbcertify scan phase starts"
source $gtm_tst/$tst/u_inref/dbcertify_scan.csh >&! dbcertify_scan.log
$tst_awk -f $gtm_tst/$tst/inref/filter_64bittn.awk dbcertify_scan.log
echo "dbcertify scan phase ends"
echo ""
###################################################################################################
# v5cbsu testscript should only be randomly chosen to run(50% chance)
# hence output of this testscript is redirected to v5cbsu.out but not to the reference file
# v5cbsu.out will then be searched for error messages
###################################################################################################
# rand.o might already exist and sometime we see %YDB-E-INVOBJ, error.
\rm -f rand.o >&! /dev/null
if (! $?v5cert_randno) then
	set v5cert_randno=`$gtm_exe/mumps -run rand 2`
endif
echo "setenv v5cert_randno $v5cert_randno" >>! settings.csh
if (1 == $v5cert_randno) then
	source $gtm_tst/$tst/u_inref/v5cbsu.csh >&! v5cbsu.out
	if (0 != `$grep "TEST-E-ERROR" v5cbsu.out|wc -l`) then
		echo "TEST-E-ERROR. v5cbsu utility failed. Pls check v5cbsu.out for details"
		echo "The test will exit"
		exit 1
	else
		echo "v5cbsu utility PASSED"
		mv v5cbsu.out v5cbsu.out_renamed
	endif
else
	echo "v5cbsu utility not chosen"
endif
## check for dbcertify-certify phase (PHASE-II)
echo ""
echo "dbcertify certify phase starts"
source $gtm_tst/$tst/u_inref/dbcertify_certify.csh >&! dbcertify_certify.log
$tst_awk -f $gtm_tst/$tst/inref/filter_64bittn.awk dbcertify_certify.log
echo "dbcertify certify phase ends"
echo ""
$tst_gzip dbcertify_certify.log dbcertify_scan.log

echo "-------------------------------------------------------------------------------------"
echo "Test for GTM-7559 : DBCERTIFY CERTIFY does not work well with *-only GVT index blocks"
echo "-------------------------------------------------------------------------------------"
source $gtm_tst/$tst/u_inref/gtm7559.csh >&! gtm7559.log
$tst_awk -f $gtm_tst/$tst/inref/filter_64bittn.awk gtm7559.log
