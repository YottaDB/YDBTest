#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2002, 2013 Fidelity Information Services, Inc	#
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
setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode due to differences in LKE LOCKSPACEINFO/LOCKSPACEUSE messages
cp $gtm_tst/$tst/inref/lke2.gde .
setenv test_specific_gde $PWD/lke2.gde

if ($gtm_test_spanreg) then
	cat >> lke2.gde << cat_eof
	add -name A3(1:10) -region=REG1
	add -name A3(10:20) -region=REG2
	change -region REG1 -stdnullcoll
	change -region REG2 -stdnullcoll
	change -region DEFAULT -stdnullcoll
cat_eof

endif

$gtm_tst/com/dbcreate.csh mumps
if( "ENCRYPT" == $test_encryption ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
$GTM << xxyz
w "do ^lkereg",!   do ^lkereg
h
xxyz

$GTM << xxyz
w "do ^lkespace",!   do ^lkespace
h
xxyz
$LKE show -"invalid qualif"
$gtm_tst/com/dbcheck.csh -extract
