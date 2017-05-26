#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
$gtm_exe/mumps -run setup^D9K05002773 > sourceme.csh
source sourceme.csh
$gtm_tst/com/dbcreate.csh mumps 1 -allocation=2048 -extension_count=2048
$gtm_exe/mumps -run D9K05002773
$gtm_tst/com/dbcheck.csh -extract
