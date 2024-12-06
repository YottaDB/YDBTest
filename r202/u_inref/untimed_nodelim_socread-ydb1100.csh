#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# --------------------------------------------------------------"
echo "# Test untimed nodelimiter socket READs return sooner than r2.00"
echo "# --------------------------------------------------------------"

source $gtm_tst/com/portno_acquire.csh >>& portno.out	# would set "portno" env var for use inside ydb1100.m
$gtm_dist/mumps -run ydb1100
$gtm_tst/com/portno_release.csh

