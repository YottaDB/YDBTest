#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
########################################
# mu_create.csh  test for mupip create #
########################################
#
# testing mupip create so don't use dbcreate.csh
echo "MUPIP CREATE"
#
# this test does NOT apply to replication, nor reorg
# so turn them off for dbcheck.csh
unsetenv test_replic
unsetenv gtm_repl_instance
setenv test_reorg NON_REORG
#
@ corecnt = 1
setenv gtmgbldir "./create.gld"
#
if (-f tempcr.com) then
	\rm tempcr.com
endif
#
echo "change -segment DEFAULT -file=create" >!  tempcr.com
echo "add -name a* -region=reg1"            >>! tempcr.com
echo "add -name b* -region=reg2"            >>! tempcr.com
echo "add -region reg1 -d=seg1"             >>! tempcr.com
echo "add -region reg2 -d=seg2"             >>! tempcr.com
echo "add -segment seg1 -file=create1"      >>! tempcr.com
echo "add -segment seg2 -file=create2"      >>! tempcr.com
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	echo "change -segment DEFAULT -allocation=400"	>>! tempcr.com
	echo "change -segment seg1 -allocation=200"	>>! tempcr.com
	echo "change -segment seg2 -allocation=200"	>>! tempcr.com
endif
#
$convert_to_gtm_chset tempcr.com
#
$GDE @tempcr.com
#
if("ENCRYPT" == $test_encryption) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
echo "#"
echo "# Create with a bad region"
echo "#"
$MUPIP create -region=FREELUNCH
#
$MUPIP create -region=REG1
if ($status > 0) then
	echo "ERROR from mupip create with region qualifier."
	exit 1
endif
if (!(-f create1.dat)) then
	echo "create1.dat was not created."
	exit 2
endif
#
# Region Name in Mixed cases should be accepted
$MUPIP create -region=Reg2
if ($status > 0) then
	echo "ERROR from mupip create with region qualifier."
	exit 3
endif
if (!(-f create2.dat)) then
	echo "create2.dat was not created."
	exit 4
endif
#
$MUPIP create
if ($status == 0) then
	echo "ERROR from mupip create with region qualifier."
	exit 5
endif
if (!(-f create.dat)) then
	echo "create.dat was not created."
	exit 6
endif
#
$gtm_exe/mumps -run %XCMD 'do fill1^myfill("set")'
$gtm_exe/mumps -run %XCMD 'do fill1^myfill("ver")'
source $gtm_tst/$tst/u_inref/check_core_file.csh "cr" "$corecnt"
$gtm_tst/com/dbcheck.csh
#
########################
# END of mu_create.csh #
########################
