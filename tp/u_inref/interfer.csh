#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
setenv sub_test interfer1
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 125 1000 1024 500 4096
# We have seen sporadic TRANS2BIG errors due to PROBLKSPLIT changes in GT.M V7.0-002. So disable PROBLKSPLIT
# optimization temporarily. It is possible this can be reverted once GT.M V7.1-001 is merged.
$MUPIP set -problksplit=0 -reg "*" >& mupip_set_problksplit1.out
$GTM << GTM_EOF
w "do ^interfer(1)",! do ^interfer(1)
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test interfer2
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 125 1000 1024 500 4096
# We have seen sporadic TRANS2BIG errors due to PROBLKSPLIT changes in GT.M V7.0-002. So disable PROBLKSPLIT
# optimization temporarily. It is possible this can be reverted once GT.M V7.1-001 is merged.
$MUPIP set -problksplit=0 -reg "*" >& mupip_set_problksplit2.out
$GTM << GTM_EOF
w "do ^interfer(2)",! do ^interfer(2)
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test interfer3
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 125 1000 1024 500 4096
# We have seen sporadic TRANS2BIG errors due to PROBLKSPLIT changes in GT.M V7.0-002. So disable PROBLKSPLIT
# optimization temporarily. It is possible this can be reverted once GT.M V7.1-001 is merged.
$MUPIP set -problksplit=0 -reg "*" >& mupip_set_problksplit3.out
$GTM << GTM_EOF
w "do ^interfer(3)",! do ^interfer(3)
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

