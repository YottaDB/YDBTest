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
echo
echo "Test of ydb_zstatus() return code and that it no longer writes to a specified 0 length buffer"
echo
# Compile and link ydb515.c.
$gt_cc_compiler $gt_cc_shl_options $gtm_tst/$tst/inref/ydb515.c -I $ydb_dist -g -DDEBUG
$gt_ld_linker $gt_ld_option_output ydb515 $gt_ld_options_common ydb515.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map
if ($status) then
	echo "Linking failed:"
	cat link.map
	exit 1
endif
rm -f link.map

# Invoke the executable.
ydb515
