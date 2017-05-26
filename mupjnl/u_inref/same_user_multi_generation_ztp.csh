#! /usr/local/bin/tcsh -f

set ver = `basename $gtm_ver`
set img = `basename $gtm_dist`
$gtm_tst/com/send_env.csh

$gtm_tst/$tst/u_inref/second_process_multi_generation_ztp.csh $ver $img $tst_working_dir >& second_process.log &
