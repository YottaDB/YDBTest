#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Test of ydb_file_name_to_id(), ydb_file_is_identical(), and ydb_file_id_free() in the SimpleAPI"
echo ""

echo "# Create empty files to be tested."
touch utils_file_HL.txt
ln -s utils_file_HL.txt utils_file_SL.txt
ln -s utils_file_HL.txt utils_file_SL2.txt
touch utils_file_1.txt
touch utils_file_2.txt

cp $gtm_tst/$tst/inref/utils_file.c .

set file = utils_file.c
set exefile = $file:r

echo "# Compile and run the C code"
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
if (0 != $status) then
	echo "UTILS_FILE-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
	continue
endif

rm $exefile.o

`pwd`/$exefile
