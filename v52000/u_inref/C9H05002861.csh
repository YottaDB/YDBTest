#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2007-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
# C9H05-002861 BADCHAR in expression causes GTMASSERT in emit_code.c during compile in V52000
#

#
# Do test in M mode and UTF8 mode (randomly chosen by the framework)
# Due to the presence of YDB-W-LITNOGRAPH AND YDB-W-BADCHAR in UTF-8 mode for a lot of cases in the run below,
# it is much simpler (to maintain) to have the entire output in two sections
# one for M mode, surrounded by SUSPEND/ALLOW UNICODE_MODE
# another for UTF-8 mode, surrounded by SUSPEND/ALLOW NONUNICODE_MODE
#
cp $gtm_tst/$tst/inref/c002861_*.m .
$gtm_exe/mumps -run c002861
