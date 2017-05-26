#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$MULTISITE_REPLIC_PREPARE 2

$gtm_tst/com/dbcreate.csh mumps 3 125 1000 4096 2000 4096 2000

$MSR START INST1 INST2

$gtm_exe/mumps -run gtm8296

$gtm_tst/com/dbcheck.csh -extract
