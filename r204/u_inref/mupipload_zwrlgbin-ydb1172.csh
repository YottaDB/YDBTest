#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
YDB#1172 - Test the following release note
********************************************************************************************

Release note (from https://gitlab.com/YottaDB/DB/YDB/-/issues/1172):

MUPIP LOAD of ZWR format extract files works even if the extracted nodes contain huge binary data (e.g. closer to the maximum of 1MiB). Previously, this issued an EXTRFMT error due to the zwrite format representation of those huge node values taking up more than 1MiB of space in the extract file.

CAT_EOF
echo

$gtm_tst/com/dbcreate.csh mumps -block_size=1024 -record_size=1048576 -global_buffer_count=32768 >&! dbcreate.out

echo "# Set large binary data in the database:"
set exponent = 20
set char = "z"	# Use $zchar when not in UTF-8 mode
if ($?gtm_chset) then
	if ($gtm_chset == "UTF-8") then
		set exponent = 19 # Decrease the exponent when in UTF-8 mode to account for code points larger than 1 byte
		set char = ""	# Use $char when in UTF-8 mode
	endif
endif
echo '# Run [$gtm_dist/mumps -run %XCMD '"'zhalt ^x'="'$translate($justify(" ",2**'"$exponent"')," ",$'"$char"'char(255))'"']"
$gtm_dist/mumps -run %XCMD 'set ^x=$translate($justify(" ",2**'"$exponent"')," ",$'"$char"'char(255))'

echo "# Extract the large binary data from the database:"
rm -f zwr.out
$gtm_dist/mupip extract -format=zwr zwr.out >& load_extract.out
$gtm_dist/mumps -run %XCMD 'kill ^x'

echo "# Reload the large binary data into the database from the EXTRACTed ZWR file"
$gtm_dist/mupip load -format=zwr zwr.out >& load_load.out
if ($status) then
	echo "TEST-E-MUPIP_LOAD : Error from mupip load. Exiting.... [load_load.out] output follows"
	echo
	cat load_load.out
	exit -1
endif

echo "# Verify the large binary data was successfully loaded into the database"
echo "# Previously, the MUPIP LOAD failed with a %YDB-E-EXTRFMT error."
set exponent = 20
set char = "z"	# Use $zchar when not in UTF-8 mode
if ($?gtm_chset) then
	if ($gtm_chset == "UTF-8") then
		set exponent = 19 # Decrease the exponent when in UTF-8 mode to account for code points larger than 1 byte
		set char = ""	# Use $char when in UTF-8 mode
	endif
endif
echo '# Run [$gtm_dist/mumps -run %XCMD '"'zhalt ^x'="'$translate($justify(" ",2**'"$exponent"')," ",$'"$char"'char(255))'"']"
$gtm_dist/mumps -run %XCMD 'zhalt ^x'"'"'=$translate($justify(" ",2**'"$exponent"')," ",$'"$char"'char(255))'

if ($status) then
	echo "TEST-E-VERIFY_FAIL : Verification after mupip load FAILED"
	exit -1
else
	echo "TEST-S-VERIFY_PASS : Verification after mupip load PASSED",!
endif

$gtm_tst/com/dbcheck.csh mumps >&! dbcheck.out
