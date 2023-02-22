#! /usr/local/bin/tcsh -f
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
source $gtm_tst/com/cre_coll_sl.csh com/col_polish.c 1
unsetenv gtm_local_collate # Unset value set by com/cre_coll_sl.csh

# create a db and fill in some local variables to test local collation
$gtm_tst/com/dbcreate.csh mumps 2 125 500
$GTM << \aaa  >& local_polm.out
w "Current local collation=",$$get^%LCLCOL,!
if '$$set^%LCLCOL(1) W "Local collation cannot be changed",!
set ^prefix=""
d in2^mixfill("set",15)
d in2^mixfill("ver",15)
d in2^numfill("set",1,2)
d in2^numfill("ver",1,2)
zwr AGLOBALVAR1
zwr BGLOBALVAR1
ZWR morefill
h
\aaa
$gtm_tst/com/dbcheck.csh -extr
$gtm_tst/$tst/u_inref/check_local_polm.csh
