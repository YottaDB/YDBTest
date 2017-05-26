#!/usr/local/bin/tcsh -f
#
# create_resolution.csh -- create the resolution file when the test fails or NOTRUN.
#
if !($?timestamp) set timestamp = `date +%Y%m%d_%H%M%S`
echo "#Fill in the resolution note for the failures after the line with the testname" >! $tst_dir/$gtm_tst_out/resolution.$testname
echo "# and timestamp. Note that only the first line of the resolution note will be" >> $tst_dir/$gtm_tst_out/resolution.$testname
echo "# taken into the report (like TR), and that line should have the TR entry" >> $tst_dir/$gtm_tst_out/resolution.$testname
echo "# if it exists." >> $tst_dir/$gtm_tst_out/resolution.$testname
echo "#====DO NOT REMOVE OR MODIFY THE NEXT LINE ===========" >> $tst_dir/$gtm_tst_out/resolution.$testname
echo "$timestamp,$tst_org_host,$testname" >> $tst_dir/$gtm_tst_out/resolution.$testname
