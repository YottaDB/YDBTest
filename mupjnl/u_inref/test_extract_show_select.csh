#!/usr/local/bin/tcsh -f 
# This takes care of test cases 23, and 26:
# Test Case # 23:  (extract with selection qualifiers with BIJ, also for D9C09-002218)
# Test Case # 26:  (show options with selection qualifiers with BIJ)
# D9C09-002218 MUPIP JOURNAL -EXTRACT -GLOBAL does not work right
#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore 
source $gtm_tst/com/gtm_test_setbeforeimage.csh
#
$gtm_tst/$tst/u_inref/test_extract_show_select_base.csh >& test_extract_show_select.outx
# Filter out some output
# ALIGN - align_size is randomly set by $cms_tools/do_test.csh - smaller align size might result in more ALIGN records
$grep -vE "MUJNLSTAT|EPOCH|PBLK|ALIGN"  test_extract_show_select.outx
