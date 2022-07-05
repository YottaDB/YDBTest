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
#Tests of mupip command "REORG" on a R/O files
echo ""
echo "*** TSTMREORG.CSH ***"
echo ""
# create_multi_jnl_db.csh used instead of dbcreate.csh
$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM<<aaa
d in1^sfill("set",3,4)
aaa
echo "------- Before reorg -------"
$gtm_tst/com/dbcheck_filter.csh
chmod 666 *.dat *.mjl
echo "R/W mumps.dat R/W mumps.mjl"
echo "$MUPIP reorg"
$MUPIP reorg
echo "------- Test last reorg -------"
$gtm_tst/com/dbcheck_filter.csh
mipcmanage
#
#
#
\rm -f *.dat *.mjl
$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM<<aaa
d in1^sfill("set",3,4)
aaa
echo "------- Before reorg -------"
$gtm_tst/com/dbcheck_filter.csh
chmod 666 *.dat *.mjl
chmod 444 mumps.dat
echo "R/O mumps.dat R/W mumps.mjl"
echo "$MUPIP reorg"
$MUPIP reorg
echo "------- Test last reorg -------"
$gtm_tst/com/dbcheck_filter.csh
mipcmanage
#
#
#
\rm -f *.dat *.mjl
$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM<<aaa
d in1^sfill("set",3,4)
aaa
echo "------- Before reorg -------"
$gtm_tst/com/dbcheck_filter.csh
chmod 666 *.dat *.mjl
chmod 444 mumps.mjl
echo "R/W mumps.dat R/O mumps.mjl"
echo "$MUPIP reorg"
$MUPIP reorg
echo "------- Test last reorg -------"
$gtm_tst/com/dbcheck_filter.csh
mipcmanage
#
#
#
\rm -f *.dat *.mjl
$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM<<aaa
d in1^sfill("set",3,4)
aaa
echo "------- Before reorg -------"
$gtm_tst/com/dbcheck_filter.csh
chmod 666 *.dat *.mjl
chmod 444 mumps.dat
chmod 444 mumps.mjl
echo "R/O mumps.dat R/O mumps.mjl"
echo "$MUPIP reorg"
$MUPIP reorg
echo "------- Test last reorg -------"
$gtm_tst/com/dbcheck_filter.csh
mipcmanage
\rm -f *.dat *.mjl
