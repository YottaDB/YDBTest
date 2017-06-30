#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
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
# used/created/updated by $[Z]PIECE(). Run in both UTF8 and M modes
#
$switch_chset "M" >&! switch_m.log
$gtm_dist/mumps -run zlen2arg
#
# Now run in UTF8 mode
#
$switch_chset "UTF-8" >&! switch_utf8.log
