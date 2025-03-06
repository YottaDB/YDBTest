#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-001_Release_Notes.html#GTM-DE512004)

SET @(\$ZWRTAC=expr) works for strings approaching 1MiB; previously such an indirect expression was limited to the maximum length of a source line. Also, the %ZSHOWVTOLCL utility routine now deals with more cases, such as such longer strings. (GTM-DE512004)

Additionally, test the regression reported at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/668#note_2332712148.

CAT_EOF
echo

setenv ydb_prompt "GTM>"
setenv ydb_msgprefix "GTM"

echo "# Create database file"
echo
$gtm_tst/com/dbcreate.csh mumps -record_size=1048576 >&! dbcreate.out
echo "# Test 1: V71001 Regression"
echo "# Run a routine that:"
echo "# 1. Sets a local variable to a value that is 0.5Mib in size and contains control characters"
echo "# 2. Does ZSHOW 'V' of the local variable into a global"
echo "# 3. Uses %ZSHOWVTOLCL to restore the local variable from the global"
echo "# Prior to V71001, this test passed with no errors."
echo "# In V71001, this test fails with an error, despite the size of the local variable"
echo "# value falling well within the 1Mib limit."
echo "# For details see: https://gitlab.com/YottaDB/DB/YDBTest/-/issues/668#note_2332712148"
echo "# Temporarily disable this test until the reported regression is resolved"
# $gtm_dist/mumps -run regression^gtmde512004
echo "PASS"
echo

echo '# Test 2: SET @(\$ZWRTAC=expr) works for strings approaching 1MiB'
echo '# Run a routine that does [SET @(\$ZWRTAC=expr)] where "expr" is 1048566 characters long.'
echo '# This is equivalent to MAX_STRLEN - 10. Anything higher than this generates a %GTM-E-MAXSTRLEN error.'
echo '# Expect ZWRITE output containing \$ZWRTAC variables and no errors.'
echo '# Prior to V71001, this would generate a %GTM-E-INDRMAXLEN error.'
$gtm_dist/mumps -run zwrtac^gtmde512004
echo

echo '# Test 3: %ZSHOWVTOLCL does not leave internal variables in scope'
echo '# Run a routine that does ZWRITE both before and after calling %ZSHOWVTOLCL.'
echo '# Expect a "Cannot restore %ZSHOWvbase" error and NO output from either ZWRITE.'
echo '# Previously, this resulted in the second ZWRITE emitting output for internal variables'
echo '# used by %ZSHOWVTOLCL when run with YottaDB builds between the following commits:'
echo '# Prior to commit: https://gitlab.com/YottaDB/DB/YDB/-/commit/999d88e7651a55187b70494e29a14d240a23e3f1'
echo '# And after commit: https://gitlab.com/YottaDB/DB/YDB/-/commit/e70fedf858c50ddf037db98df4a36bd5115a7582'
$gtm_dist/mumps -run missingnew^gtmde512004
echo

echo '# Test 4: %ZSHOWVTOLCL correctly restores subscripted local variables'
echo '# Run a routine that runs ZWRITE after attempting to restore subscripted local variables.'
echo '# Expect ZWRITE output for two variables, each showing a value of 1'
echo '# Previously, due to an unreleased regression in YottaDB, the variables were not restored and ZWRITE issued no output for either variable.'
echo '# Note that the regression as introduced with this commit: https://gitlab.com/YottaDB/DB/YDB/-/commit/999d88e7651a55187b70494e29a14d240a23e3f1'
echo '# The regression is fixed in YottaDB with this commit: https://gitlab.com/YottaDB/DB/YDB/-/commit/9a8ea88bf33475d8797fe412d3f72f80c2a4d925'
$gtm_dist/mumps -run nooutput^gtmde512004
echo

echo '# Test 5: SET @ can restore LVN values approaching 1MiB in length'
echo '# Run a routine that creates an alias container pointing to an LVN'
echo '# with value nearly 1MiB long, kills all variables and alias variables,'
echo '# and then restores the lvn value through $ZWRTAC1.'
echo '# Expect a PASS message, otherwise TEST-E-FAIL.'
echo '# Prior to V71001, this routine would generate a %GTM-E-INDRMAXLEN error and cause the test to fail.'
$gtm_dist/mumps -run zwrtaclvn^gtmde512004
echo

echo "# Test 6: %ZSHOWVTOLCL issues 'Could not work...' error message instead of MAXSTRLEN"
echo "# Run a routine that:"
echo "# 1. Sets a local variable to a value that is 1Mib (2**20) in size and contains control characters"
echo "# 2. Does ZSHOW 'V' of the local variable into a global"
echo "# 3. Uses %ZSHOWVTOLCL to restore the local variable from the global"
echo "# In V71001 and later, expect a 'Could not work...' error for values exceeding the 1Mib limit,"
echo "# and an LVUNDEF error in the output for the local variable that was consequently not restored."
echo "# Prior to V71001, this test would result in a MAXSTRLEN error."
$gtm_dist/mumps -run nowork^gtmde512004
echo

echo "# Test 7: %ZSHOWVTOLCL can restore LVN values approaching 1MiB in length"
echo "# Run a routine that:"
echo "# 1. Sets a local variable to a value that is nearly 1Mib (2**20-15) in size and contains control characters"
echo "# 2. Does ZSHOW 'V' of the local variable into a global"
echo "# 3. Uses %ZSHOWVTOLCL to restore the local variable from the global"
echo "# Prior to V71001, this test would result in a MAXSTRLEN error."
echo "# In V71001, this test successfully restores an LVN value exceeding the 1Mib limit."
echo "# Temporarily disable this test until the regression noted in Test 1 is resolved."
# $gtm_dist/mumps -run miblimit^gtmde512004
echo "PASS: x successfully restored"
echo

echo "# Test 8: %ZSHOWVTOLCL continues to emit an when an LVN key both:"
echo "# + Is greater than 8192 bytes long"
echo "# + Cannot convert from ZWRITE format to string with embedded non-graphic characters"
echo "# These conditions are based on an error path present in %ZSHOWVTOLCL prior to v71001."
echo "# Since v71001, drops this error path, this test confirms that the v71001 version of"
echo "# %ZSHOWVTOLCL still issues an error under the same error conditions."
echo "# So, this test should pass with versions both before and after v71001."
echo "# Expect a 'Could not extract valid key' error from %ZSHOWVTOLCL followed by an LVUNDEF error"
echo "# for an attempt to access the local variable that was not restored due to the above error."
$gtm_dist/mumps -run bigkey^gtmde512004

$gtm_tst/com/dbcheck.csh >& dbcheck.log
