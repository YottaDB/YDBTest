#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013 Fidelity Information Services, Inc		#
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

$gtm_tst/com/dbcreate.csh mumps 1
$MUPIP load -format=zwr abc.txt  >& load.op1
$gtm_tst/com/grepfile.csh 'YDB-E-FILEOPENFAIL' load.op1 1
$gtm_tst/com/dbcheck.csh
# Verify that MUPIP LOAD issues FILEOPENFAIL error if input file is absent.

