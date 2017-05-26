#!/usr/local/bin/tcsh -f

$gtm_tst/$tst/u_inref/refresh_secondary_base.csh >&! refresh_secondary_base.log
grep -v "shmpool lock preventing" refresh_secondary_base.log >& refresh_secondary_base1.log
$tst_awk -f $gtm_tst/$tst/inref/filter_64bittn.awk refresh_secondary_base1.log

# The filter_64bittn.awk is just a copy from 64bittn test. This particular subtest was moved from 64bittn. For now we will have a copy of the awk here
