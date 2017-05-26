#!/usr/local/bin/tcsh
#;;;To test $ZEOF maintenance if there is no input device

echo "blah" >! file1.txt
$convert_to_gtm_chset file1.txt
$gtm_dist/mumps -direct << xxx
do ^zeoftest
halt
xxx

echo 1 | $gtm_dist/mumps -run zeoftest >&! has_input.out
$gtm_dist/mumps -run zeoftest </dev/null >&! has_no_input.out
# extra test for different form of null input to validate no infinite loop 
cat /dev/null | $gtm_dist/mumps -run zeoftest >&! has_no_input2.out
diff has_no_input.out has_no_input2.out
if ($status) echo "FAIL"

diff has_input.out has_no_input.out
if (! $status) echo "PASS"
