#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################


#
# C9E11002657 - GTM gives sig 11 when zbreak action has a do and earlier relink removed zbreaks
# This is the same as C9H11-002926 and is fixed in that TR
#
echo "C9E11002657 subtest begins..."
echo "# Run zbtest.m. Should only see YDB-E-LOADRUNNING and not sig-11 or ASSERT failures"
$gtm_exe/mumps -run zbtest
echo "End of subtest C9E11002657"
