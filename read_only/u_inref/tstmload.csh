#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################
#Tests of mupip command "LOAD" on a read_only database file
echo ""
echo "*** TSTMLOAD.CSH ***"
echo ""
# create_multi_jnl_db.csh used instead of dbcreate.csh
set verbose

$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1

chmod.csh rwrw
$MUPIP load load.go
$GTM << bbb
d in0^sfill("ver",1,$1)
d in0^sfill("kill",1,$1)
h
bbb
mipcmanage

chmod.csh rwro
$MUPIP load load.go
mipcmanage
$gtm_tst/com/dbcheck_filter.csh

chmod.csh rorw
$MUPIP load load.go
mipcmanage
$gtm_tst/com/dbcheck_filter.csh

chmod.csh roro
$MUPIP load load.go
mipcmanage
$gtm_tst/com/dbcheck_filter.csh

\rm -f *.dat *.mjl mumps.gld
