#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2006, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test Plan
#	This script follows the pattern from col_nct.csh except that it uses the "chn"
#	section of the mixfill.m. This is to test that things collate properly with
#	or without nct set.
#	Additional section should be added to test scenarios:
#	- Global A is set to nct true, Chinese collation and Global B and mixfill set
#	  to nct false and default collation
#	- Global A is set to nct false with default collation and Global B and mixfill
#	  set to nct true with Chinese collation.

setenv gtm_test_spanreg 0	# setting nct with spanning regions is not supported as of now
$switch_chset "UTF-8"
source $gtm_tst/com/cre_coll_sl.csh com/col_chinese.c 1

# ========= debug section ===========
echo "DEBUG INFORMATION"
echo $gtm_local_collate
env | $grep gtm_collate_1
echo "DEBUG INFORMATION"
# ======== end of debug section =====

# create a db, then set to chinese collation and nct false
$gtm_tst/com/dbcreate_base.csh mumps 2 255 2048 4096
$gtm_tst/$tst/u_inref/configure_nct_and_col.csh 0 1
if ($?test_replic) then
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/dbcreate_base.csh mumps 2 255 2048 4096"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/configure_nct_and_col.csh 0 1"
	$gtm_tst/com/RF_START.csh
endif

$GTM << aaa
d s^mixfill
d filln^mixfill("set","^a")
h
aaa

$gtm_tst/com/dbcheck.csh -extr
$gtm_tst/$tst/u_inref/check_col_nct_chn.csh 0 1

# create the extract that will be used repeatedly in this test
echo "$MUPIP extract -format=bin col_nct_chn_data.bin"
$MUPIP extract -format=bin col_nct_chn_data.bin
if ($status) then
	echo "Extract failed"
	exit 1
endif

# create a db, then set to chinese collation and nct true
rm -f *.dat
rm -f *.gld
$gtm_tst/com/dbcreate_base.csh mumps 2 255 2048 4096
$gtm_tst/$tst/u_inref/configure_nct_and_col.csh 1 1
if ($?test_replic) then
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/dbcreate_base.csh mumps 2 255 2048 4096"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/configure_nct_and_col.csh 1 1"
	$gtm_tst/com/RF_START.csh
endif

echo "$MUPIP load -format=bin col_nct_chn_data.bin"
$MUPIP load -format=bin col_nct_chn_data.bin >&! tmp.log
if ($status) then
	echo "Load failed"
	exit 1
endif
$grep -v "Label" tmp.log

$gtm_tst/com/dbcheck.csh -extr
$gtm_tst/$tst/u_inref/check_col_nct_chn.csh 1 1

# create a db, then set to default collation and nct true
rm -f *.dat
rm -f *.gld
$gtm_tst/com/dbcreate_base.csh mumps 2 255 2048 4096
$gtm_tst/$tst/u_inref/configure_nct_and_col.csh 1 0
if ($?test_replic) then
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/dbcreate_base.csh mumps 2 255 2048 4096"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/configure_nct_and_col.csh 1 0"
	$gtm_tst/com/RF_START.csh
endif

echo "$MUPIP load -format=bin col_nct_chn_data.bin"
$MUPIP load -format=bin col_nct_chn_data.bin >&! tmp.log
if ($status) then
	echo "Load failed"
	exit 1
endif
$grep -v "Label" tmp.log

$gtm_tst/com/dbcheck.csh -extr
$gtm_tst/$tst/u_inref/check_col_nct_chn.csh 1 0

# create a db, then set to default collation and nct false
rm -f *.dat
rm -f *.gld
$gtm_tst/com/dbcreate_base.csh mumps 2 255 2048 4096
$gtm_tst/$tst/u_inref/configure_nct_and_col.csh 0 0
if ($?test_replic) then
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/dbcreate_base.csh mumps 2 255 2048 4096"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/configure_nct_and_col.csh 0 0"
	$gtm_tst/com/RF_START.csh
endif

echo "$MUPIP load -format=bin col_nct_chn_data.bin"
$MUPIP load -format=bin col_nct_chn_data.bin >&! tmp.log
if ($status) then
	echo "Load failed"
	exit 1
endif
$grep -v "Label" tmp.log

$gtm_tst/com/dbcheck.csh -extr
$gtm_tst/$tst/u_inref/check_col_nct_chn.csh 0 0
