#! /usr/local/bin/tcsh -f

set arg =  "$1"
set ver = `basename $gtm_ver`
set img = `basename $gtm_dist`
$gtm_tst/com/send_env.csh

$gtm_tst/$tst/u_inref/second_process.csh $ver $img $tst_working_dir $arg >& second_process.log &
