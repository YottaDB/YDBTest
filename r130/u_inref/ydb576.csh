#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '# Test that $PIECE in a database trigger returns correct results when invoked from SimpleAPI (e.g. ydb_set_s())'
echo ""

echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps
if ($status) then
	echo "TEST-E-FAIL : dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate.out
	exit 1
endif

set file = "ydb576"

echo "# Create trigger definition file trigbl.trg"
cat > trigbl.trg << CAT_EOF
+^trigbl -name=myname0 -commands=S -xecute="do trig^$file"
CAT_EOF

echo "# Load trigger in database"
$ydb_dist/mupip trigger -noprompt -trigger=trigbl.trg
if ($status) then
	echo "TEST-E-FAIL : mupip trigger failed."
	exit 1
endif

echo "# Build executable [`pwd`/$file] from SimpleAPI C program $file.c"
$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/$file.c -I$ydb_dist # Compile it
set save_status = $status
if (0 != $save_status) then
	echo "Build failed with status $save_status"
	exit 1
endif

$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& $file.map # Link it
set save_status = $status
if (0 != $save_status) then
	echo "Link failed with status $save_status"
	exit 1
endif

rm $file.o # Get rid of C flavor .o so M linker (invoked later for .m file of same name) doesn't get confused

echo "Run executable [`pwd`/$file]"
`pwd`/$file
set save_status = $status
if (0 != $save_status) then
	echo "Running $file failed with status $save_status"
endif

$gtm_tst/com/dbcheck.csh
