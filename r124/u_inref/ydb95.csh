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
echo "# Test that MUPIP LOAD on an empty ZWR file reports 0 loaded records and no errors"
echo ""

echo "# Create database file"
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif

echo "# Set a single node in database : ^x=123"
$ydb_dist/mumps -run ^%XCMD 'set ^x=1'

set extract_format_list = ( GO ZWR )
if ($?gtm_chset) then
	# UTF-8 mode does not support GO extracts
	if ("UTF-8" == "$gtm_chset") then
		set extract_format_list = ( ZWR )
	endif
endif
foreach fmt ($extract_format_list)
	echo "# Create an empty $fmt format extract file x.$fmt by using just the first 2 lines of the output of MUPIP EXTRACT -FORMAT=$fmt"
	$MUPIP extract -format=$fmt -stdout |& head -2 > x.$fmt

	echo "# Load empty $fmt format extract file x.$fmt using MUPIP LOAD -FORMAT=$fmt x.$fmt"
	$MUPIP load -format=$fmt x.$fmt

	echo "# Load empty $fmt format extract file x.$fmt using MUPIP LOAD x.$fmt"
	$MUPIP load x.$fmt
end

echo "# Do dbcheck.csh"
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
