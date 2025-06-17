#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-DE556760 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-002_Release_Notes.html#GTM-DE556760)

MUPIP UPGRADE correctly handles global trees with depths greater than supported by GT.M version 6.x, but possible when running version 7.x on a version 6.x database. Previously, attempts to upgrade V6 databases containing these tall global trees would result in a segmentation violation and the process would terminate early without upgrading the database. (GTM-DE556760)

CAT_EOF
echo

setenv ydb_msgprefix "GTM"
setenv ydb_prompt "GTM>"
# This test relies on a particular database block layout as the reference file contains mupip integ output etc.
# Having a mupip reorg -encrypt running in the background (in case of -encrypt run) will disturb this so disable that.
setenv gtm_test_do_eotf 0
setenv test_reorg "NON_REORG"
# Disable SEMINCR to prevent shared memory segments from being left over due
# to the test system simulating many processes simultaneously accessing a single
# database file. See the following thread for details:
# https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2281
unsetenv gtm_db_counter_sem_incr
setenv gtm_test_use_V6_DBs 0  # Disable V6 mode DBs as this test already switches versions for its various test cases
source $gtm_tst/com/ydb_prior_ver_check.csh $gtm_test_v6_dbcreate_rand_ver

echo '# The below tests force the use of V6 mode to create DBs. This requires turning off ydb_test_4g_db_blks since'
echo '# V6 and V7 DBs are incompatible in that V6 cannot allocate unused space beyond the design-maximum total V6 block limit'
echo '# in anticipation of a V7 upgrade.'
setenv ydb_test_4g_db_blks 0

echo '# Create a V6 database'
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
$gtm_tst/com/dbcreate.csh mumps 1 255 1000 -block_size=1024
echo '# Switch to V7'
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo "# Upgrade the global directory $gtmgbldir : GDE exit"
$gtm_dist/mumps -run GDE exit >>&! gde.out
$GTM << EOF
f i=1:1:50000 s ^a(i,\$j(i,150),i,i*2)=\$j(i,50)
h
EOF

echo '# Run MUPIP REORG to ensure tree depth > 7'
$gtm_dist/mupip reorg -fill=0 >& mupipreorg.outx
$gtm_dist/mupip integ -r "*" >& mupipinteg.outx

echo "# Perform phase 1 of in-place upgrade on region DEFAULT: MUPIP UPGRADE"
echo "# Prior to GT.M V7.1-002, this would fail with a segmentation violation like the following:"
echo "     %GTM-F-KILLBYSIGSINFO1, MUPIP process 56678 has been killed by a signal 11 at address 0x00005BFC8DE2EB89 (vaddr 0x0000006900000003)"
echo "     %GTM-F-SIGMAPERR, Signal was caused by an address not mapped to an object"
echo "y" | $gtm_dist/mupip upgrade -region DEFAULT >&! mupipupgrade.out
echo "# Perform phase 2 of in-place upgrade on region DEFAULT: MUPIP REORG -UPGRADE"
echo "# Prior to GT.M V7.1-002, this would fail with a MUNOFINISH error."
echo "# This step is omitted from the GT.M release note, but is included here for completeness,"
echo "# per the upgrade instructions at http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-000_Release_Notes.html#upgrade."
echo "y" | $gtm_dist/mupip reorg -upgrade -region DEFAULT >&! mupipreorgupgrade.out
echo

echo "# Verify that the maximum tree height/depth is 11 (new MAX_BT_DEPTH in GT.M V7.0-001 as part of GTM-9434)"
echo "# Previously, this was only 7. The above part of the test (thanks to the [mupip reorg -fill=0] already created"
echo "# a MAX_BT_DEPTH height global. So all we need to do now is to verify there are blocks from Level 10 to Level 0."
echo "# Run [dse find -key] to verify that the Global tree path includes blocks from Level 10 to Level 0"
echo "# Also run [dse dump -block] of each of those 11 blocks to confirm the levels go from 10 to 0"
cat > dse.cmd << CAT_EOF
find -key="^a"
dump -block=5ADC -header
CAT_EOF
$gtm_dist/dse < dse.cmd
