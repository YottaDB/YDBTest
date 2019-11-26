#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2019-2020 YottaDB LLC and/or its subsidiaries. 	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#dbcreate
$GDE @$gtm_tst/$tst/u_inref/setexklo.gde
$gtm_exe/mupip create
# AREG will issue "already in region: AREG". That's expected.
foreach reg (AREG BREG CREG DREG EREG FREG DEFAULT)
        $gtm_exe/dse << DSE_EOF
        find -reg=$reg
        change -fi -null=TRUE
        change -fi -std=TRUE
DSE_EOF
end
$gtm_exe/mumps -run set^setexklo
$gtm_exe/mupip extract set.ext
wc -l set.ext | $tst_awk '{print $1}'
$gtm_exe/mumps -run kill^setexklo
$gtm_exe/mupip extract kill.ext		# Expect NOSELECT error
$gtm_exe/mupip load set.ext
$gtm_exe/mumps -run verify^setexklo	# expect PASS
$gtm_exe/mupip extract load.ext
$gtm_tst/com/extractdiff.csh set.ext load.ext		# expect NO diff
$gtm_tst/com/dbcheck.csh
