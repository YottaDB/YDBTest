#!/usr/local/bin/tcsh -f
cat > tiny.gde << EOF
change -segment DEFAULT -block_size=512
change -segment DEFAULT -allocation=10
change -segment DEFAULT -global_buffer_count=64
change -region DEFAULT -key_size=3
change -region DEFAULT -record_size=7
EOF
# one extra line to help VIM syntax coloring
setenv test_specific_gde $tst_working_dir//tiny.gde
source $gtm_tst/com/dbcreate.csh mumps 1

source $gtm_tst/$tst/u_inref/maxparse_base.csh

$gtm_tst/com/dbcheck.csh -extract
