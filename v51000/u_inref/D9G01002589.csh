#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# D9G01-002589 MUPIP SET and GDE cannot set LOCK_SPACE to more than 1000
#
# dbcreate.csh not used because since we want to manually test various GDE settings.
echo ""
echo "########################################################################################"
echo "                      Test GDE allows LOCK_SPACE upto 262144                            "
echo "########################################################################################"
set verbose
$GDE change -seg DEFAULT -lock=1024
if ("ENCRYPT" == "$test_encryption" ) then
        $gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
$GDE show -seg DEFAULT

$GDE change -seg DEFAULT -lock=2048
$GDE show -seg DEFAULT

$GDE change -seg DEFAULT -lock=4096
$GDE show -seg DEFAULT

$GDE change -seg DEFAULT -lock=16384
$GDE show -seg DEFAULT

$GDE change -seg DEFAULT -lock=32768
$GDE show -seg DEFAULT

$GDE change -seg DEFAULT -lock=262144
$GDE show -seg DEFAULT

$GDE change -seg DEFAULT -lock=524288
$GDE show -seg DEFAULT

$GDE change -seg DEFAULT -lock=262145
$GDE show -seg DEFAULT

$GDE change -seg DEFAULT -lock=262143
$GDE show -seg DEFAULT

$GDE change -seg DEFAULT -lock=32768
$GDE show -seg DEFAULT

unset verbose
echo ""
echo "########################################################################################"
echo "           Test that GDE setting of LOCK_SPACE gets carried over to the database        "
echo "########################################################################################"
set verbose
$MUPIP create
$gtm_tst/com/get_dse_df.csh        # creates dse_df.log
$grep -E "Region          |Lock space" dse_df.log
mv dse_df.log dse_df1.log

unset verbose
echo ""
echo "########################################################################################"
echo "                      Test MUPIP SET allows LOCK_SPACE upto 262144                      "
echo "########################################################################################"
set verbose
$MUPIP set -reg DEFAULT -lock=1024
$MUPIP set -reg DEFAULT -lock=2048
$MUPIP set -reg DEFAULT -lock=4096
$MUPIP set -reg DEFAULT -lock=16384
$MUPIP set -reg DEFAULT -lock=32768

# Randomly check that lock space setting is there in the db file header
$gtm_tst/com/get_dse_df.csh        # creates dse_df.log
$grep -E "Region          |Lock space" dse_df.log
mv dse_df.log dse_df2.log

$MUPIP set -reg DEFAULT -lock=262144
$MUPIP set -reg DEFAULT -lock=524288
$MUPIP set -reg DEFAULT -lock=262145
$MUPIP set -reg DEFAULT -lock=262143
$MUPIP set -reg DEFAULT -lock=16383

# Check that lock space setting is there in the db file header
$gtm_tst/com/get_dse_df.csh        # creates dse_df.log
$grep -E "Region          |Lock space" dse_df.log
mv dse_df.log dse_df3.log

$gtm_tst/com/dbcheck.csh
