#!/usr/local/bin/tcsh -f 
#Test Case # 27
#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore 
source $gtm_tst/com/gtm_test_setbeforeimage.csh
#
$gtm_tst/$tst/u_inref/time_qualifier_since_before_after_base.csh  >& time_qualifier_since_before_after_base.outx
$grep  -vE "MUJNLSTAT|MUJNLPREVGEN" time_qualifier_since_before_after_base.outx
