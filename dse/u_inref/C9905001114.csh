#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# C9905-001114 check DSE find -sibling
#
$gtm_tst/com/dbcreate.csh mumps 1 200 400 1024 600
$gtm_exe/mumps -run C9905001114p
$gtm_exe/mumps -run gendsefindsib^C9905001114 >& dse_find_sib.txt
$DSE < dse_find_sib.txt >&! dse_sib.out
$gtm_exe/mumps -run C9905001114
$gtm_tst/com/dbcheck.csh
