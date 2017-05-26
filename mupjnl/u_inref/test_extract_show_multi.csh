#!/usr/local/bin/tcsh -f 
echo "TEST MUPIP JOURNAL -EXTRACT AND -SHOW MULTIPLE REGIONS"
#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore 
source $gtm_tst/com/gtm_test_setbeforeimage.csh
#
setenv test_extract 1
setenv test_show 1 
$gtm_tst/$tst/u_inref/mu_jnl_extract_show.csh 4 >& test_extract_show_multi.outx
# Filter out some output
# ALIGN - align_size is randomly set by $cms_tools/do_test.csh - smaller align size might result in more ALIGN records
$grep -vE "MUJNLSTAT|NOPREVLINK|EPOCH|PBLK|ALIGN|End of Data|End Transaction" test_extract_show_multi.outx
