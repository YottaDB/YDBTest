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

echo '# Test for warning when YDB compiles mumps program. Warning will be'
echo '# %YDB-W-DUPLICATENEW variable [variable name] appears twice in the same new command'
echo '# Warning should happen when the same variable appears twice on 1 line with the new command'
$gtm_dist/mumps $gtm_tst/$tst/inref/ydb1111.m
echo
echo '# Now testing various cases with a syntax error to ensure that no fake warnings are issued.'
echo "# This tests the code to clear the error buffer after a syntax error"
echo "# is encountered before the next command starts."
echo '# First case is to check when a variable name starts with an illegal character.'
$gtm_dist/mumps $gtm_tst/$tst/inref/ydb1111SyntaxErr.m
echo '# Second case is trying to use indirection on an intrinsic special variable.'
$gtm_dist/mumps $gtm_tst/$tst/inref/ydb1111SyntaxErr2.m
echo '# Third case is having an illegal character instead of a comma after a variable being NEWed in parentheses.'
$gtm_dist/mumps $gtm_tst/$tst/inref/ydb1111SyntaxErr3.m
echo '# Fourth case is having an illegal character starting a variable name with an indirected variable.'
$gtm_dist/mumps $gtm_tst/$tst/inref/ydb1111SyntaxErr4.m
echo '# Fifth case is having an illegal character starting a variable name with an indirected variable in parentheses.'
$gtm_dist/mumps $gtm_tst/$tst/inref/ydb1111SyntaxErr5.m
echo '# Sixth case is having an illegal character starting a variable being NEWed in parentheses.'
$gtm_dist/mumps $gtm_tst/$tst/inref/ydb1111SyntaxErr6.m
echo "# Now testing that no DUPLICATENEW warnings are issued during runtime."
$GTM -dir << END
n a,a
new a,@(cat
n a
END
