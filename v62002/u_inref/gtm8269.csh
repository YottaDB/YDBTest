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
# GTM-8269 [nars] KILL of global with NOISOLATION removes extra global nodes
#
$gtm_tst/com/dbcreate.csh mumps
$gtm_dist/mumps -run gtm8269
$gtm_tst/com/dbcheck.csh
