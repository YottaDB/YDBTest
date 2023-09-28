#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode due to differences in LKE LOCKSPACEINFO/LOCKSPACEUSE messages
#=================================
if (!($?test_replic)) then
#
#	locks2 is not for replication: It uses mulitple gld files.
#
	$gtm_tst/com/dbcreate.csh mumps1
	# The next dbcreate invocation will rename the db/gld files. Since is required for this test, move them away temporarily
	mkdir bak ; mv mumps1.* bak/
	$gtm_tst/com/dbcreate.csh mumps
	mv bak/* .
	$GTM << xxyz
	w "do ^locks1",!     do ^locks1
	w "do ^locks2",!     do ^locks2
	h
xxyz
	$gtm_tst/com/dbcheck.csh mumps1
else
#
	$gtm_tst/com/dbcreate.csh mumps
	$GTM << xxyz
	w "do ^locks1",!     do ^locks1
	h
xxyz
endif

if ($LFE == "L") then
	$gtm_tst/com/dbcheck.csh -extract
	exit
endif
#=================================

$GTM << xxyz
w "do ^locksub1",!   do ^locksub1
w "do ^locktst4",!   do ^locktst4
h
xxyz
#
#

$GTM << xxyz
w "do ^per3086",!   do ^per3086
h
xxyz
#

if ($LFE == "F") then
	$gtm_tst/com/dbcheck.csh -extract
	exit
endif
#=================================

$GTM << xxyz
w "do ^lockwake",!   do ^lockwake
h
xxyz
#
$LKE show -all
cat lockwake.mjo*
cat lockwake.mje*
$GTM << xxyz
w "do ^clocks",!     do ^clocks
h
xxyz
#
$gtm_tst/com/dbcheck.csh -extract
