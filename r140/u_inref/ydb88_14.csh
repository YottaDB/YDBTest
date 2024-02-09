#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

($gtm_tst/com/dbcreate.csh mumps 1 >! dbcreate.outx)

set noext = `basename $0 | sed 's/\.[^.]*$//'`
(ydb88_exec_test.csh $noext grep '^\#\|result\|CTRL_C' >! expect.outx) >&! expect.dbg
cat expect.outx

($gtm_tst/com/dbcheck.csh >! dbcheck.outx)
