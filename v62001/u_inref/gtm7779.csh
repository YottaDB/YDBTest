#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
$gtm_tst/com/dbcreate.csh mumps 1 -key=255 -rec=2048 -block=4096 -glob=65536 -allocation=8192 -extension_count=8192
$MUPIP set -noepochtaper -region '*'
$gtm_tst/com/jnl_on.csh
$gtm_dist/mumps -run gtm7779
$gtm_tst/com/dbcheck.csh
