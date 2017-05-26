#! /usr/local/bin/tcsh -f

set arg =  "$1"
set ver = `basename $gtm_ver`
set img = `basename $gtm_dist`
$gtm_tst/com/send_env.csh

if ( "ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/encrypt_for_gtmtest1.csh mumps_dat_key mumps_remote_dat_key
endif

$rsh $tst_org_host -l $gtmtest1 $gtm_tst/$tst/u_inref/second_process.csh $ver $img $tst_working_dir $arg >& second_process.log &
