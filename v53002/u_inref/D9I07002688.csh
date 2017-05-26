#!/usr/local/bin/tcsh
#
# D9I07-002688 test for warning only for non-graphic characters in a string literal at compile-time
#

echo "# D9I07-002688 test for warning only for non-graphic characters in a string literal at compile-time"
echo ""

$gtm_exe/mumps -run D9I07002688

echo ""
echo "# End of test"
