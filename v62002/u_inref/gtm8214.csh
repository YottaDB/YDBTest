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
$gtm_tst/com/dbcreate.csh .
setenv gtmdbglvl 0x40	# needed to more frequently induce GTM-8214 bug
$gtm_exe/mumps -run gtm8214
# Check if garbage trigger name was printed as part of trigger deleting (or even addition)
$tst_awk '/Added|Deleted/{if($0 !~ /myname[0-9]+/){print}}' child_gtm8214.mjo1
$gtm_tst/com/dbcheck.csh
