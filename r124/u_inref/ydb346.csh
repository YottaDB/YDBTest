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
echo "# Test that MUPIP INTEG, DSE DUMP and MUMPS do not infinite loop in case of INVSPECREC error"
echo ""

setenv gtm_test_mupip_set_version "disable"     # Or else DSE DUMP would show V4 or V6 making reference file non-deterministic
setenv gtm_test_disable_randomdbtn		# Or else DSE DUMP would show different transaction numbers in different test runs

# Replace uninitialized 4th byte of record header with 0 to avoid false test failures
set backslash_quote
alias dsedump	'$DSE dump -block=2 |& sed \'s/F  0  0 .. 78/F  0  0  0 78/;s/.  .  .  .  x/.  .  .  .  x/\''
unset backslash_quote

echo "# Create database file"
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif

echo "# Create shared library for alternate collation # 1 (reverse collation)"
source $gtm_tst/com/cre_coll_sl_reverse.csh 1

echo '# Set alternate collation (act) = 1 and numeric collation (nct) = 0 for global name ^x using $$set^%GBLDEF'
$ydb_dist/mumps -run ^%XCMD 'set ^x=0  kill ^x  set x=$$set^%GBLDEF("^x",0,1) set ^x("a")=1' |& $grep -v '^$'

echo "# Dump contents of block=2 using DSE DUMP to verify 4-byte collation header in Directory Tree Leaf record"
dsedump |& $grep -v '^$'

foreach value (0 1 2 127 128 255)
	echo ""
	echo "#--------------------------------------------------"
	echo "# Test 1st byte of 4-byte collation header = $value"
	echo "#--------------------------------------------------"
	echo "# Use DSE OVERWRITE to set the 1st byte of 4-byte collation header to $value"
	$DSE overwrite -block=2 -offset=1b -data=\\$value |& $grep -v '^$'
	echo '# Use MUMPS to access global name ^x. Should not see INVSPECREC error.'
	echo '# Also should see ^x("a") only if 1st byte of collation header is 1. Should see ^x($ZCH(158)) or ^x($C(158)) otherwise.'
	$ydb_dist/mumps -run ^%XCMD 'zwrite ^x' |& $grep -v '^$'
	echo "# Use DSE DUMP to dump block 2 contents of global name ^x. Should see no INVSPECREC error"
	dsedump |& $grep -v '^$'
	echo '# Use MUPIP INTEG to check integrity of database. Should see INVSPECREC error if 1st byte of collation header is not 1'
	$MUPIP integ mumps.dat |& $grep -v '^$'
end

echo "# Use DSE OVERWRITE to set the 1st byte of 4-byte collation header to 1 (so dbcheck will pass)"
$DSE overwrite -block=2 -offset=1b -data=\\1 |& $grep -v '^$'

echo "# Do dbcheck.csh"
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
