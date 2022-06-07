#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# some tests of ^%GI
#
$gtm_tst/com/dbcreate.csh mumps 1
cp $gtm_tst/$tst/inref/gtm8223a.go ./
(expect -d $gtm_tst/$tst/u_inref/gtm8223.exp > gtm8223.out) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
perl $gtm_tst/com/expectsanitize.pl gtm8223.out > gtm8223_sanitized.out

cat gtm8223_sanitized.out
$gtm_tst/com/dbcheck.csh
