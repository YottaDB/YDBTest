#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 Finxact, LLC. and/or its subsidiaries.     #
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test for fix to indirect code cache stats 4-byte overflow error
#
setenv gtmdbglvl 0x00001000
$gtm_dist/mumps -run zindcacheoverflow
