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
#
#
$gtm_tst/com/dbcreate.csh mumps 1>&create.out
if ($status) then
	echo "create failed"
endif
$MUPIP SET -region DEFAULT -journal=enable,on,nobefore
$MUPIP FREEZE -ON -ONLINE DEFAULT

$MUPIP FREEZE -OFF DEFAULT

$gtm_tst/com/dbcheck.csh mumps 1>&check.out
if ($status) then
	echo "close failed"
endif

