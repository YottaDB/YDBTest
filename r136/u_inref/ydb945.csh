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
#
# ydb_env_set only works in sh, which is why this csh redirects to ydb945.sh
#

echo "# Test 1 : Create .gld file with db file name = [/dev/null]"
setenv gtmgbldir test1.gld
$ydb_dist/yottadb -run GDE >& gde.out << GDE_EOF
change -segment DEFAULT -file=/dev/null
GDE_EOF

# Now run the sh script to invoke "ydb_env_set"
echo "# Now invoke ydb_env_set. Expect a %YDBENV-F-NOTADBFILE error"
sh $gtm_tst/$tst/u_inref/ydb945.sh

# Move test1 artifacts out of the way before test2 starts
mkdir test1
mv *.gld *.dat test1

echo ""
echo "# Test 2 : Create .gld file with db file name pointing to a non-existent file [notexist.dat]"
setenv gtmgbldir test2.gld
$ydb_dist/yottadb -run GDE >& gde.out << GDE_EOF
change -segment DEFAULT -file=notexist.dat
GDE_EOF

# Now run the sh script to invoke "ydb_env_set"
echo "# Now invoke ydb_env_set. We expect no errors (ydb_env_set should have created notexist.dat)."
sh $gtm_tst/$tst/u_inref/ydb945.sh

echo "# Verify notexist.dat got created by a [ls -1 notexist.dat]"
ls -1 notexist.dat

# Move test2 artifacts out of the way before test3 starts
mkdir test2
mv *.gld *.dat test2

echo ""
echo "# Test 3 : Create .gld file with db file name pointing to an existing file [exist.dat]"
setenv gtmgbldir test3.gld
$ydb_dist/yottadb -run GDE >& gde.out << GDE_EOF
change -segment DEFAULT -file=exist.dat
GDE_EOF

echo "# Create database file [exist.dat]"
$ydb_dist/mupip create

# Create ydb945.outx before we remove write permissions in current directory (to avoid errors when we do ">& ydb945.outx" below)
touch ydb945.outx

echo "# Remove write permissions on current directory"
chmod -w .

# Now run the sh script to invoke "ydb_env_set"
echo "# Now invoke ydb_env_set"
echo "# We expect ydb_env_set to encounter error while creating YDBOCTO and/or YDBAIM regions"
echo "# We see that it issues appropriate error message and returns with non-zero exit status"
sh $gtm_tst/$tst/u_inref/ydb945.sh >& ydb945.outx
cat ydb945.outx
echo "# Currently ydb_env_set does not point us to the first error in this use-case. But it points us"
echo "# to the directory containing the information. So get that real error out".
set dir = `grep %YDBENV-F-MUPIPCREATEERR ydb945.outx | $tst_awk '{print $NF}' | sed 's,/MUPIP_YDBOCTO.err,,g'`
grep -E 'YDB-E|YDB-F' $dir/*

echo "# Restore write permissions on current directory"
chmod +w .

$gtm_tst/com/dbcheck.csh

