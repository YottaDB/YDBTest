#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# GTM-7443 : Test that idle EPOCHs are not written unnecessarily
#

# Since there is nothing much to test without journaling on, enable it
setenv gtm_test_jnl "SETJNL"
setenv tst_jnl_str "$tst_jnl_str,epoch_interval=300,allocation=10240,extension=10240"
# set epoch_interval to 300 to make sure JRI kicks in for sure before JRE
setenv tst_jnl_str "$tst_jnl_str,epoch_interval=300"

$gtm_tst/com/dbcreate.csh mumps
$gtm_exe/mumps -run gtm7443
set jricount_hex = `$DSE dump -file -gvstats |& $grep JRI |& $tst_awk '{printf "%s\n", $NF}' | sed 's/0x0*//g'`
@ jricount_dec = `echo "obase=10; ibase=16; $jricount_hex" | bc `
if ($jricount_dec != 0) then
	echo "TEST-E-FAIL : Saw non-zero JRI ($jricount_dec) in dse dump -file -gvstats"
else
	echo "PASS : Saw zero JRI count in dse dump -file -gvstats"
endif
$gtm_tst/com/dbcheck.csh
