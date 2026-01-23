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
echo "# state after the erroring thread had closed. The solution is to empty the"
echo "# dollar_ecode buffer at the start and end of every ydb_ci[p]_t call."
echo "# First, test a will test for this bug by running a mumps program with a"
echo "# division by 0 error in C code with ydb_ci_t."
echo "# Then, it will run code that only produces a TPTIMEOUT error if not already in an error state."
echo '# This is easy as a TPTIMEOUT is deferred until $ECODE is cleared.'
echo "# If ydb_ci_t reset the dollar_ecode then a TPTIMEOUT error will be recorded."
echo "# So, as this bug has been fixed, we expect to get a TPTIMEOUT error."
echo "# Afterwards, test b will be the same test but using ydb_cip_t instead of ydb_ci_t."
echo "# More information about where this test came form: https://gitlab.com/YottaDB/DB/YDB/-/issues/1180#note_2887736924"
echo '# Also includes tests c and d to make sure that $ECODE is reset in [ydb|gtm]_cip and [ydb|gtm]_ci.'
echo '# In these tests, an error is invoked in one script and the value of $ECODE is checked in the next one.'
echo '# This functionality has also been changed as a result of #1180 to be consistent with the'
echo "# ydb_ci[p]_t functionality."
echo "# Relevant Gitlab discussion: https://gitlab.com/YottaDB/DB/YDB/-/issues/1180#note_3025071433"
echo
echo "# Building call in table"
echo "# with ydb1180ma and ydb1180mb to cause errors"
echo '# and ydb1180WE to write out the value of $ECODE.'
setenv call_table_folder_path `pwd`
cat > $call_table_folder_path/ydb1180.xc << CAT_EOF
ydb1180ma: void ^ydb1180ma()
ydb1180mb: void ^ydb1180mb()
ydb1180WE: void ^ydb1180WE()
CAT_EOF
setenv ydb_ci $call_table_folder_path/ydb1180.xc	#  needed to invoke the m routines with ydbci[p]_t

foreach program_name (a b c d)
	echo
	if ($program_name == "a") then
		set funk_name="ydb_ci_t"
	else if ($program_name == "b") then
		set funk_name="ydb_cip_t"
	else if ($program_name == "c") then
		set funk_name="ydb_cip and gtm_cip"
	else if ($program_name == "d") then
		set funk_name="ydb_ci and gtm_ci"
	endif
	echo "# Starting test ${program_name} with ${funk_name} ydb1180${program_name}.c."
	set filename="ydb1180$program_name"
	set file=""$gtm_tst/$tst/inref/ydb1180${program_name}.c""
	set exefile = $file:r
	echo "# Starting compilation."
	$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $exefile.c
	echo "# Starting linking."
	$gt_ld_linker $gt_ld_option_output $filename $gt_ld_options_common $filename.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& $filename.map
	echo "# Running the compiled ydb1180${program_name}.c program."
	if ($program_name == "a" || $program_name == "b") then
		echo "# As stated above, the program will time out if it finds it is not in an error state."
		echo "# So first we expect a zero division error from $funk_name."
		echo "# Then, if the dollar_ecode is properly cleared, we should also get a TPTIMEOUT error"
	else
		echo '# Previously, the error would have persisted so that when we print $ECODE'
		echo '# there would have been an error left from the ydb1180ma call.'
		echo '# Now that ecode does not persist, we expect a line that says'
		echo '# "$ECODE is:" followed immediately by a newline'
		echo '# indicating that $ECODE was correctly cleared.'
		echo '# This result will happen twice, first for the ydb then the gtm version of the API.'
	endif
	$PWD/$filename
end
