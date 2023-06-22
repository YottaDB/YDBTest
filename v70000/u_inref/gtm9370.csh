#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

echo '# GTM-9370 - This test generates expressions with each one containing one of the four divide-by-zero'
echo '#            terms. Those terms are:'
echo '#              1. x/0'
echo '#              2. x<backslash>0  (backslash character gets translated incorrectly in output)'
echo '#              3. x#0'
echo '#              4. 0**-1'
echo '#'
echo '# The purpose of this test is to verify that the compiler does not deal with literal evaluations that'
echo '# result in a divide-by-zero and rather pushes them into the runtime. To test that, we write each expr'
echo '# to a separate file, then compile each of them (expecting NO error), then we run each of them and'
echo '# expect an error - except we do not always get errors since some short-circuiting of boolean exprs'
echo '# still occurs even with gtm_boolean and/or gtm_side_effects so while we expect errors when we run the'
echo '# compiled expression, we do not require it. So long as ONE of the expressions failed as expected when'
echo '# the expressions are executed, we consider the run a PASS. This is because EVERY expression is expected'
echo '# to fail when it runs as it has a divide-by-zero term in it. But because of the nature of random'
echo '# expression generation, it is possible that div0 term gets put in some place where normal conditional'
echo '# expression short-cutting happens so it is possible that the expression evaluation never hits the'
echo '# div0 term. In that case, the expression would not fail. We allow this but require at least ONE of the'
echo '# expressions to fail at runtime.'
echo '#'
echo '# Failures using V63014 looked like the following also often accompanied by an assert failure in DBG or'
echo '# a floating exception with a PRO build:'
echo '#'
echo '# Compiling gtm9370expr9.m'
echo '#			set x=(($$Always0&0!(0**-1))&^TRUE&(204226393#0))'
echo '#    		                                                 ^-----'
echo '#			At column 51, line 31, source module /<dirpath>/v70000_0/gtm9370/gtm9370expr9.m'
echo '#	%GTM-E-DIVZERO, Attempt to divide by zero'
echo '# Routine gtm9370expr9.m failed to compile'
echo '#'
echo
echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps
echo
echo '# Drive gtm9370 test routine'
$gtm_dist/mumps -run gtm9370
echo
echo '# Verify database'
$gtm_tst/com/dbcheck.csh
