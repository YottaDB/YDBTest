#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
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

$gtm_tst/com/dbcreate.csh mumps 4 >& dbcreate1.log

# Setup and run the first test case
$gtm_dist/mumps -run setup^ztworestartrlbk
$gtm_dist/mumps -run ztwormrestart^ztworestartrlbk

# Do journal extract
$MUPIP journal -extract -noverify -for -fences=none a.mjl >&! a_extract.out
$MUPIP journal -extract -noverify -for -fences=none b.mjl >&! b_extract.out

# Using awk, print TSTART, USET records in both a.mjf and b.mjf
if (! -f a.mjf || ! -f b.mjf) then
	echo "TEST-E-FAILED : Cannot find a.mjf and b.mjf. Check a_extract.out and b_extract.out"
endif

echo "ZTWORMHOLE/UPDATES in a.mjl"
$tst_awk -F "\\" '$1 ~ /^(05|11)/{if($NF ~ /^[^#]+$/)print $NF;}' a.mjf
echo "ZTWORMHOLE/UPDATES in b.mjl"
$tst_awk -F "\\" '$1 ~ /^(05|11)/{if($NF ~ /^[^#]+$/)print $NF;}' b.mjf

$gtm_dist/mumps -run ztwormrlbk^ztworestartrlbk

# Do journal extract
$MUPIP journal -extract -noverify -for -fences=none c.mjl >&! c_extract.out
# Using awk, print TSTART, USET records in both c.mjf
if (! -f c.mjf) then
	echo "TEST-E-FAILED : Cannot find c.mjf. Check c_extract.out"
endif

echo "ZTWORMHOLE/UPDATES in c.mjl"
$tst_awk -F "\\" '$1 ~ /^(05|11)/{if($NF ~ /^[^#]+$/)print $NF;}' c.mjf

$echoline
$gtm_tst/com/dbcheck.csh -extract >& dbcheck1.log
