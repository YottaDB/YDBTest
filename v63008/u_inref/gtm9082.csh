#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

echo "# In V6.3-007, auto-upgrading the database file headers would not set the"
echo "# flush_trigger_top field properly and would be set to 0 instead of the current flush_trigger value. This test verifies that"
echo "# the flush_triger_top field is correctly auto-upgraded (i.e. does not require MUPIP -SET TRIGGER_FLUSH to fix)"

echo "# Creating a database to a version prior to V63007"

set rand_ver=`$gtm_tst/com/random_ver.csh -lt V63007`
source $gtm_tst/com/ydb_prior_ver_check.csh $rand_ver
echo "# Set version to: $rand_ver" >& ver.log
source $gtm_tst/com/switch_gtm_version.csh $rand_ver $tst_image
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.log

echo "# Checking the current value of Flush trigger"
$DSE dump -fileheader >& fileheader.log
cat fileheader.log | grep -o "Flush trigger.*"

echo "# Switching back to current version"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
$GDE << EOF >& gde.log
EOF
echo "# Verifying that the file header has been automatically upgraded by"
echo "# checking that flush_trigger_top is set to 960"
$DSE << END >& dse.log
END
$ydb_dist/mupip dumpfhead -reg "*" | grep "flush_trigger_top"
$gtm_tst/com/dbcheck.csh >& dbcheck.log
