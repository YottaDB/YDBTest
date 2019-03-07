#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Null subscripts allowed in DEFAULT,CREG
# Null subscripts NOT allowed in AREG,BREG
setenv gtm_test_spanreg 0	# The test is dependant on null-subs property of individual regions.
setenv test_reorg "NON_REORG"
setenv gtmgbldir null.gld
setenv test_specific_gde $gtm_tst/$tst/inref/null.gde
source $gtm_tst/com/dbcreate.csh null 4
setenv ydb_lct_stdnull 0	# set local null collation to a non-default value as this subtest reference file relies on that
#
$gtm_exe/mumps -dir << GTM_EOF
view "gdscert":1
w "d ^nullfill(""set"")",!  d ^nullfill("set")
w "d ^nullntp",!  d ^nullntp
h
GTM_EOF
$gtm_exe/mumps -dir << GTM_EOF
view "gdscert":1
w "d ^nullfill(""set"")",!  d ^nullfill("set")
w "d ^nulltp",!  d ^nulltp
h
GTM_EOF
##
$gtm_exe/mumps -dir << GTM_EOF
view "gdscert":1
w "d ^nullfill(""set"")",!  d ^nullfill("set")
w "d ^nulllc",!  d ^nulllc
h
GTM_EOF
##
echo "$gtm_exe/mupip extract extr.glo"
$gtm_exe/mupip extract extr.glo
echo "tail -n +3 extr.glo"	# BYPASSOK tail
$tail -n +3 extr.glo
$gtm_tst/com/dbcheck.csh -extr
