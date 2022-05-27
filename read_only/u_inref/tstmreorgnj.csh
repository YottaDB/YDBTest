#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
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
#Tests of mupip command "REORG" on a read_only database file in the absence or journal file
echo ""
echo "*** TSTMREORGNJ.CSH ***"
echo ""
#
#
#
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps $1
$GTM<<aaa
d in1^sfill("set",3,3)
aaa
echo " ------- Before reorg --------"
$gtm_tst/com/dbcheck_filter.csh
# the next dbcheck is not preceded by a dbcreate so disable dbcheck from regenerating the .sprgde file using -nosprgde
echo "$MUPIP reorg"
$MUPIP reorg
echo " ------- After reorg --------"
$gtm_tst/com/dbcheck_filter.csh -nosprgde
mipcmanage
#
#
#
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps $1
$GTM<<eee
d in1^sfill("set",3,3)
eee
echo "----- Before reorg -----"
$gtm_tst/com/dbcheck_filter.csh
# the next dbcheck is not preceded by a dbcreate so disable dbcheck from regenerating the .sprgde file using -nosprgde
echo "****** Changing database to read_only ******"
chmod 444 mumps.dat
lsmumps
echo "$MUPIP reorg"
$MUPIP reorg
echo " ----- After reorg on read_only database -----"
$gtm_tst/com/dbcheck_filter.csh -nosprgde
mipcmanage
\rm -f *.dat
