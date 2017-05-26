#! /usr/local/bin/tcsh -f
# max_strlen [Mohammad] basic functionality with long string
# ac_loc_coll [Mohammad] local collation with long string 
# biglcgb [Layek] Merge with long local string
echo "longstr  test starts"
setenv subtest_list "max_strlen ac_loc_coll biglcgb"
$gtm_tst/com/submit_subtest.csh
echo "End of longstr test"
