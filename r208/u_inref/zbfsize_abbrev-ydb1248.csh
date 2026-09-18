#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#-----------------------------------------------------------------------------------------------#"
echo "# [#1248] Every spelling of the ZBFSIZE deviceparameter down to ZB is accepted                   #"
echo "#-----------------------------------------------------------------------------------------------#"
echo
echo "# sr_port/deviceparameters.c records ZBFSIZE with a minimum abbreviation of two characters, so"
echo "# ZB, ZBF, ZBFS, ZBFSI and ZBFSIZ all mean ZBFSIZE. Each of them was rejected at compile time"
echo "# with a DEVPARUNK error instead: the Z entry of dev_param_index[] pointed one entry past the"
echo "# start of the Z section of dev_param_names[], so int_namelook never reached the ZB* entry that"
echo "# holds the abbreviation. The only assert on that table checks its total size, which an index"
echo "# left behind does not change, so nothing caught it."
echo

$gtm_tst/com/dbcreate.csh mumps

cp $gtm_tst/$tst/inref/ydb1248.m .

echo '# Command : $ydb_dist/yottadb -run abbrev^ydb1248'
echo "#   expect all six spellings, ZB through ZBFSIZE, to be accepted by an OPEN of a SOCKET device"
$ydb_dist/yottadb -run abbrev^ydb1248
echo

echo '# Command : $ydb_dist/yottadb -run value^ydb1248'
echo "#   expect the two character spelling to set the deviceparameter the full name sets. The device"
echo "#   is OPENed with a listening socket, since ZBFSIZE is reported for each socket rather than for"
echo '#   the device, and with 2048 rather than the default 1024 so that a reading of the default'
echo "#   cannot pass for a reading of what was asked for"
$ydb_dist/yottadb -run value^ydb1248
echo

echo "# Done"
$gtm_tst/com/dbcheck.csh
