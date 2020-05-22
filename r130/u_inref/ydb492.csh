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
echo '# Test $TRANSLATE with multi-byte string literals in UTF-8 mode does not SIG-11 if executed from shared library'
echo '# -------------------------------------------------------------------------------------------------------------'

echo "# Switch to UTF-8 mode"
$switch_chset "UTF-8"

set file = "ydb492"
cp $gtm_tst/$tst/inref/$file.m .
cp $gtm_tst/com/sstep.m .

echo "# Compile $file.m into $file.o"
$ydb_dist/yottadb $file.m sstep.m

echo "# Link $file.o into shared object $file.so"
$gt_ld_m_shl_linker ${gt_ld_option_output} ${file}$gt_ld_shl_suffix $file.o sstep.o ${gt_ld_m_shl_options} >& link_ld.outx

echo "# setenv ydb_routines (gtmroutines) = $file.so"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_routines gtmroutines "$file.so"

echo "# Running : yottadb -run $file"
$ydb_dist/yottadb -run $file

