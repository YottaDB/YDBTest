#!/usr/local/bin/tcsh -f
#
# C9L04-003407 blk-split heuristic should be cleaned up for directory tree too in case of TP restart
#
$gtm_tst/com/dbcreate.csh mumps
$DSE change -file -rec=980   >& dse_change1.out
$DSE change -file -reser=100 >& dse_change2.out
$gtm_dist/mumps -run c003407
$gtm_tst/com/dbcheck.csh
