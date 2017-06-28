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
# Test for two argument $[Z]LENGTH() and its new support to use/create/update the piece cache also
# used/created/updated by $[Z]PIECE().
#
$gtm_dist/mumps -run zlen2arg
