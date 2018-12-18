#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test of ydb_node_previous_s() function for local and global variables in the simpleAPI.
# See nodeprevious.m for a description of how this test works.
#
unsetenv gtmdbglvl   # Disable storage debugging as that can turn this 1 minute job into an hour
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/nodepreviouscb.c
$gt_ld_shl_linker ${gt_ld_option_output}nodepreviouscb${gt_ld_shl_suffix} $gt_ld_shl_options nodepreviouscb.o $gt_ld_syslibs
#
$gtm_tst/com/dbcreate.csh mumps 1 -block_size=4096 -record_size=4000 -key_size=1019 -glob=8192
#
setenv GTMXC nodepreviouscb.tab
echo "`pwd`/nodepreviouscb${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
nodepreviouscb: void nodepreviouscb(I:ydb_string_t *)
xx
#
# First drive routine for local variables
#
$gtm_exe/mumps -dir << EOF
do ^nodeprevious("AVar")
EOF
#
# Compare the two output files
#
diff nodeprevioussublist_M.txt nodeprevioussublist_SAPI.txt
if (0 != $status) then
    echo "Test failed - The nodeprevioussublist_M.txt and nodeprevioussublist_SAPI.txt files differ for local variables"
    exit 1
endif
rm -f nodeprevioussublist_M.txt nodeprevioussublist_SAPI.txt
#
# Now drive the global variable version
#
$gtm_exe/mumps -dir << EOF
do ^nodeprevious("^AVar")
EOF
#
# Compare the two output files
#
diff nodeprevioussublist_M.txt nodeprevioussublist_SAPI.txt
if (0 != $status) then
    echo "Test failed - The nodeprevioussublist_M.txt and nodeprevioussublist_SAPI.txt files differ for global variables"
    exit 1
endif
#
$gtm_tst/com/dbcheck.csh
