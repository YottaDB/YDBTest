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
echo "# Test that SimpleAPI returns correct results if lvn was set using ydb_incr_s()"
echo "# -----------------------------------------------------------------------------"

set file = "ydb594"
echo "# Compile $file.c"
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/$file.c
$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >&! link.map
if( $status != 0 ) then
    cat link.map
endif

echo "# Set ydb_dbglvl to 0x40 to detect any use of freed memory"
setenv ydb_dbglvl 0x40

echo "# Run ./$file"
`pwd`/$file

