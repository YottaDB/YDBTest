#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This test relies on the default region configuration, disable spanning regions
setenv gtm_test_spanreg 0
unsetenv gtm_gvdupsetnoop
$gtm_tst/com/dbcreate.csh mumps 5
# enable journaling
$MUPIP set -journal=enable,nobefore -reg "*" >&! jnl_on.log

# Begin trigger related updates
$gtm_exe/mumps -run replictrigger

# kill off any remaining ^fired GVNs
$gtm_exe/mumps -run cleanup^replictrigger

$gtm_tst/$tst/u_inref/jnl_extract.csh > extracted_jnl_data.log
cat extracted_jnl_data.log

$MUPIP extract -format=zwr -nolog jnltrig.zwr
cat jnltrig.zwr

$gtm_tst/com/dbcheck.csh -extract

