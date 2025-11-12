#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Test to make sure that ECODE race condition problem does not occur."
echo "# There was a bug where after a call to ydb_ci[p]_t the dollar_ecode buffer"
echo "# would not be cleared. This would result in the program remaining in an error"
echo "# state after the erroring thread had closed. The solution is the empty the"
echo "# dollar_ecode buffer at the start and end of every ydb_ci[p]_t call."
echo "# First, test a will test for this bug by running a mumps program with a"
echo "# division by 0 error in C code with ydb_ci_t."
echo "# Then, it will run code that only produces a TPTIMEOUT error if not already in an error state."
echo '# This is easy as a TPTIMEOUT is deferred until $ECODE is cleared.'
echo "# If ydb_ci_t reset the dollar_ecode then a TPTIMEOUT error will be recorded."
echo "# So, as this bug has been fixed, we expect to get a TPTIMEOUT error."
echo "# Afterwards, test b will be the same test but using ydb_cip_t instead of ydb_ci_t."
echo "# More information about where this test came form: https://gitlab.com/YottaDB/DB/YDB/-/issues/1180#note_2887736924"
echo
echo "# Building call in table."
setenv call_table_folder_path `pwd`
cat > $call_table_folder_path/ydb1180.xc << CAT_EOF
ydb1180ma: void ^ydb1180ma()
ydb1180mb: void ^ydb1180mb()
CAT_EOF
setenv ydb_ci $call_table_folder_path/ydb1180.xc	#  needed to invoke the m routines with ydbci[p]_t

echo
echo "# Starting test a with ydb_ci_t ydb1180a.c."
set filename="ydb1180a"
set file=""$gtm_tst/$tst/inref/ydb1180a.c""
set exefilea = $file:r
echo "# Starting compilation."
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $exefilea.c
echo "# Starting linking."
$gt_ld_linker $gt_ld_option_output $filename $gt_ld_options_common $filename.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& $filename.map
echo "# As stated above, the program will time out if it finds it is not in an error state."
echo "# So first we expect a zero division error from ydb_ci_t."
echo "# Than, if the dollar_ecode is properly cleared, we should also get a TPTIMEOUT error"
echo "# Runing the compiled ydb1180a.c program:"
$PWD/$filename

echo
echo "# Starting test b with ydb_cip_t ydb1180b.c."
set filename="ydb1180b"
set file=""$gtm_tst/$tst/inref/ydb1180b.c""
set exefileb = $file:r
echo "# Starting compilation."
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $exefileb.c
echo "# Starting linking."
$gt_ld_linker $gt_ld_option_output $filename $gt_ld_options_common $filename.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& $filename.map
echo "# Same as test a, we expect a zero division error and a TPTIMEOUT error."
echo "# Runing the compiled ydb1180b.c program:"
$PWD/$filename
