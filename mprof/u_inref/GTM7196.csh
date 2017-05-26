###################################################################################
# This subtest verifies the fix for a long-standing memory leak issue with MPROF. #
# The cause of the issue was allocation and no subsequent freeing of space for    #
# label and route names during unwinds. Those strings are created so that we      #
# could compare them with entries stored in the AVL tree and store, if necessary. #
###################################################################################
$gtm_tst/com/dbcreate.csh .

echo ""

$gtm_dist/mumps -run memleak

echo ""

$gtm_tst/com/dbcheck.csh
