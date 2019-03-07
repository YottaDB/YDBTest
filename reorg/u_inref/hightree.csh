#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv test_reorg "NON_REORG"
$gtm_tst/com/dbcreate.csh mumps 1 255 1000 -block_size=1024
$GTM << EOF
f i=1:1:10000 s ^a(i,\$j(i,150),i,i*2)=\$j(i,50)
h
EOF
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 63  # WBTEST_REORG_DEBUG
setenv gtm_white_box_test_case_count 1
$MUPIP reorg -fill=0 >& reorg.outx
sed 's/\(GTMPOOLLIMIT used for mupip reorg :\) '$gtm_poollimit_value'/\1 ##FILTERED##/' reorg.outx
unsetenv gtm_white_box_test_case_enable
$MUPIP integ -r "*"
$gtm_tst/com/dbcheck.csh
