#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test an assert in CALLG.C line 96 for expression (fnptr == (callgfnptr)push_parm)
#	This assert used to trip in r1.10 when a caller other than "push_parm" passes > 32 parameters to callg.
#	But "op_fnquery" and "op_fnreversequery" are callers that are in this category.
#	The below is a test for those callers exercising this assert codepath in callg.
#
$gtm_dist/mumps -run callgassert
