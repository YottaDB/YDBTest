#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################
# Test for debugging M-utility rounies UTF2HEX and HEX2UTF
#
#
# override utf8 setting for this test
$switch_chset "UTF-8"
#
$gtm_tst/com/dbcreate.csh mumps 1 125 1000 1024
#
echo "Begin test for UTF2HEX , HEX2UTF utilities"

# tcsh 6.14.00 has a bug where if we use inlining "$GTM << GTM_EOF ..." with UTF8 multi-byte characters, it
# loses a byte here and there so GT.M does not get the correct data. To avoid this issue, we store this data
# in a file and use that file as standard input for GT.M
#
# To avoid BADCHAR compilation error before dbfill discount default BADCHAR behavior here
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_badchar gtm_badchar "no"
$GTM < $gtm_tst/$tst/inref/utf2hex.inp >&! utf2hex.outx
$tst_awk -f $gtm_tst/com/filter_litnongraph.awk utf2hex.outx
# restore default BADCHAR behavior
source $gtm_tst/com/unset_ydb_env_var.csh ydb_badchar gtm_badchar
#
$GTM << EOF
write "Final ZSHOW begins - ther should not be any left over local vars",!
ZSHOW "V"
write "END OF TEST",!
quit
EOF
#
echo "End of test for UTF2HEX , HEX2UTF utilities"
#
$gtm_tst/com/dbcheck.csh
