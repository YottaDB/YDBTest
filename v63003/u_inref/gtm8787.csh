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

source $gtm_tst/com/gtm_test_setbgaccess.csh
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps 1>>& create.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat create.out
endif
#exec 1>&-
#exec 2>&-
$MUPIP Set -Region Default -Journal=enable,on,before,file=mumps.mjl >>& jnlcreate.out
if ($status) then
	echo "Journal Create Failed, Output Below"
	cat jnlcreate.out
endif

fclose 'stdout'
$MUPIP Journal -Extract='-stdout' -Backward mumps.mjl

$gtm_tst/com/dbcheck.csh >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
endif
