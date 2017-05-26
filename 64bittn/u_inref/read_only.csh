#! /usr/local/bin/tcsh -f
# Test that all newly introduced commands issue DBRDONLY error if operated on a read-only database.
#
echo "Begin of READ_ONLY subtest"
#
source $gtm_tst/$tst/u_inref/read_only_base.csh >&! read_only_base.log
$tst_awk -f $gtm_tst/$tst/inref/filter_64bittn.awk read_only_base.log
$tst_gzip read_only_base.log
#
echo "END of READ_ONLY subtest"
