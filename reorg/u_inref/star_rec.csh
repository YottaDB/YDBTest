#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
setenv test_reorg "NON_REORG"
echo "Create some star-record-only blocks:"
$gtm_tst/com/dbcreate.csh mumps 1 255 1001 -block_size=1024
$GTM << EOF
S limit=200
f i=limit:-1:1 s ^a(i)=\$j(i,990)
f i=1:1:16 k ^a(i)
f i=18:1:108 k ^a(i)
f i=110:1:199 k ^a(i)
h
EOF
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 63  # WBTEST_REORG_DEBUG
setenv gtm_white_box_test_case_count 1
$MUPIP reorg >& reorg.out
sed 's/\(GTMPOOLLIMIT used for mupip reorg :\) '$gtm_poollimit_value'/\1 ##FILTERED##/' reorg.out
$MUPIP integ -R "*"
unsetenv gtm_white_box_test_case_enable
echo "Now print Which block have globals:"
$DSE << EOF
find -key=^a(17)
find -key=^a(109)
find -key=^a(200)
q
EOF
echo "star_rec test ends"
$gtm_tst/com/dbcheck.csh
