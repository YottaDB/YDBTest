#!/usr/local/bin/tcsh -f
setenv gtm_white_box_test_case_count 1
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 32

echo $$ >& dse_parent.pid
date > do_dse.started
$DSE << DSE_EOF
 	q
DSE_EOF
date > do_dse.done
