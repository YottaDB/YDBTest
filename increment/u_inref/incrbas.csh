#! /usr/local/bin/tcsh -f
# This subtest tests all the basic functionality of $increment for both local and global variables
echo "Begining of incrbas subtest"
source $gtm_tst/com/dbcreate.csh mumps 3
$GTM <<\aa
d ^incrbas
\aa
$gtm_tst/com/dbcheck.csh
echo "End of incrbas subtest"
