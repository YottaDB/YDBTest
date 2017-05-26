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
$gtm_tst/com/dbcreate.csh mumps 1	>& dbcreate1.log

$switch_chset "M"			>& chsetm.out
$gtm_dist/mumps -run triginvchset

$switch_chset "UTF-8"			>& chsetutf8.out
$gtm_dist/mumps -run runInUtf^triginvchset

$gtm_tst/com/dbcheck.csh		>& dbcheck1.log
