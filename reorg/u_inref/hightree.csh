#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test relies on a particular database block layout as the reference file contains mupip integ output etc.
# Having a mupip reorg -encrypt running in the background (in case of -encrypt run) will disturb this so disable that.
setenv gtm_test_do_eotf 0

# Since the reference file for this test has "SUSPEND_OUTPUT 4G_ABOVE_DB_BLKS" usage, it needs to fixate
# the value of the "ydb_test_4g_db_blks" env var in case it is randomly set by the test framework to a non-zero value.
if (0 != $ydb_test_4g_db_blks) then
	echo "# Setting ydb_test_4g_db_blks env var to a fixed value as reference file has 4G_ABOVE_DB_BLKS usages" >> settings.csh
	setenv ydb_test_4g_db_blks 8388608
endif
# Disable use of V6 DB mode using random V6 versions creating DBs as that changes the output of MUPIP INTEG and MUPIP REORG output
setenv gtm_test_use_V6_DBs 0

setenv test_reorg "NON_REORG"
$gtm_tst/com/dbcreate.csh mumps 1 255 1000 -block_size=1024
$GTM << EOF
f i=1:1:50000 s ^a(i,\$j(i,150),i,i*2)=\$j(i,50)
h
EOF

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 63  # WBTEST_REORG_DEBUG
setenv gtm_white_box_test_case_count 1
$MUPIP reorg -fill=0 >& reorg.outx
sed 's/\(GTMPOOLLIMIT used for mupip reorg :\) '$gtm_poollimit_value'/\1 ##FILTERED##/' reorg.outx
unsetenv gtm_white_box_test_case_enable
$MUPIP integ -r "*"

echo "# Verify that the maximum tree height/depth is 11 (new MAX_BT_DEPTH in GT.M V7.0-001 as part of GTM-9434)"
echo "# Previously, this was only 7. The above part of the test (thanks to the [mupip reorg -fill=0] already created"
echo "# a MAX_BT_DEPTH height global. So all we need to do now is to verify there are blocks from Level 10 to Level 0."
echo "# Run [dse find -key] to verify that the Global tree path includes blocks from Level 10 to Level 0"
echo "# Also run [dse dump -block] of each of those 11 blocks to confirm the levels go from 10 to 0"
cat > dse.cmd << CAT_EOF
find -key="^a"
dump -block=4 -header
CAT_EOF

# The actual block numbers change based on HUGEDB is set or not. Hence the if/else below.
if (0 != $ydb_test_4g_db_blks) then
	cat >> dse.cmd << CAT_EOF
dump -block=100004499 -header
dump -block=100003A0B -header
dump -block=10000404C -header
dump -block=1000055CF -header
dump -block=1000055D6 -header
dump -block=100005467 -header
dump -block=1000055B4 -header
CAT_EOF

else
	cat >> dse.cmd << CAT_EOF
dump -block=4699 -header
dump -block=3C0B -header
dump -block=424C -header
dump -block=57CF -header
dump -block=57D6 -header
dump -block=5667 -header
dump -block=57B4 -header
CAT_EOF
endif

cat >> dse.cmd << CAT_EOF
dump -block=3 -header
dump -block=5 -header
dump -block=6 -header
CAT_EOF

$DSE >& dse.out < dse.cmd

# Filter out the TN part in the output as it can be random (since "gtm_test_disable_randomdbtn" env var is not set in this test).
sed 's/TN [0-9A-F]*/TN xxx/;' dse.out
echo ""

$gtm_tst/com/dbcheck.csh
