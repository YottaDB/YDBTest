#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# GTM-8245 TPFAIL uuuu in MERGE ^GBL1=^GBL2 where GBL2 contains spanning nodes
#
# setenv test_specific_gde $gtm_tst/$tst/inref/gtm8245.gde
echo "Create TWO database files a.dat and mumps.dat"
$gtm_tst/com/dbcreate.csh mumps 2 -record_size=4000 -block_size=1024:2048	# have 1024 blksize for DEFAULT, 2048 for AREG
$gtm_tst/com/backup_dbjnl.csh bak "*.dat" cp

set nosprgde = ""

foreach test (testa testb testc)
	cp bak/* .
	echo " --> Running : $gtm_dist/mumps -run $test^gtm8245"
	$gtm_dist/mumps -run $test^gtm8245
	echo " --> Running integ after $test^gtm8245"
	$gtm_tst/com/dbcheck.csh $nosprgde
	set nosprgde = "-nosprgde"	# use -nosprgde after first dbcheck to avoid TEST-E-SPRGDEEXISTS error
	$gtm_tst/com/backup_dbjnl.csh $test "*.dat" cp
end
