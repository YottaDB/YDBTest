#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Verify ZBREAK, ZPRINT and $TEXT() with overlength trigger names
$gtm_tst/com/dbcreate.csh mumps 1
$gtm_dist/mumps -run gtm8197
$gtm_tst/com/dbcheck.csh
