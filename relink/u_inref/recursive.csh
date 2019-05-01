#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# Test miscellaneous recursive relink scenarios.
# * recurlink.m is the main script
# * mutils.m provides generic file reading/writing utilities and is used by recurlink.m
# * inref files ending in ".editX.m" are new routine versions, which are then linked recursively
# * unpack_subtest_files.csh strips the ".m" from ".editX.m"
#

#####
# Copy all files associated with this subtest into working directory, and strip the "subtestname-" prefix.
source $gtm_tst/$tst/u_inref/unpack_subtest_files.csh "recursive" `pwd`
#####

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_link gtm_link "RECURSIVE"

$gtm_exe/mumps -run recurlink

echo ""
echo "# Checksum value matches MUPIP HASH"
$MUPIP hash viewrecurlink.m
$gtm_exe/mumps -run %XCMD 'zlink "viewrecurlink" write $view("RTNCHECKSUM","viewrecurlink"),!'

echo ""
echo "# Test VIEW and ZSHOW R"
$gtm_exe/mumps -run viewrecurlink

echo ""
echo "# Another ZSHOW R test"
$gtm_exe/mumps -run a

echo ""
echo "# Test UNDEF error handles symb_line safely"
$gtm_exe/mumps -run undefindr

echo ""
echo "# More than 2 versions on the stack at once"
# compile multiver.edit1
cp multiver.edit1.m multiveredit1.m
$ydb_dist/mumps -nameofrtn=multiver multiveredit1.m
$gtm_exe/mumps -run multiver

echo ""
echo "# Test recursive relink + shared libraries"
# compile c.m
$gtm_exe/mumps c.m
$gt_ld_m_shl_linker ${gt_ld_option_output} shlib$gt_ld_shl_suffix c.o ${gt_ld_m_shl_options} >& link1_ld.outx
# compile c.edit
cp c.edit.m cedit.m
$ydb_dist/mumps -nameofrtn=c cedit.m
$gt_ld_m_shl_linker ${gt_ld_option_output} editshlib$gt_ld_shl_suffix c.o ${gt_ld_m_shl_options} >& link2_ld.outx
# run test
$gtm_exe/mumps -run crun
