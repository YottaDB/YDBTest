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
setenv test_reorg "NON_REORG"
source $gtm_tst/com/cre_coll_sl.csh com/col_polish.c 1
setenv gtm_test_parms "1,7"
setenv gtm_test_maxdim 3
source $gtm_tst/com/dbcreate.csh mumps 7 255 1010 4096 4096 4096 -col=1
$gtm_exe/mumps -dir << aaa
d ^MRGITP
zwr ^a
halt
aaa
$gtm_tst/com/dbcheck.csh  -extr
cat *.mje*
