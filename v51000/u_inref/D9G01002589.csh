#!/usr/local/bin/tcsh
#
# D9G01-002589 MUPIP SET and GDE cannot set LOCK_SPACE to more than 1000
#
# dbcreate.csh not used because since we want to manually test various GDE settings.
echo ""
echo "########################################################################################"
echo "                      Test GDE allows LOCK_SPACE upto 65536                             "
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

$GDE change -seg DEFAULT -lock=65536
$GDE show -seg DEFAULT

$GDE change -seg DEFAULT -lock=131072
$GDE show -seg DEFAULT

$GDE change -seg DEFAULT -lock=65537
$GDE show -seg DEFAULT

$GDE change -seg DEFAULT -lock=65535
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
echo "                      Test MUPIP SET allows LOCK_SPACE upto 65536                       "
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

$MUPIP set -reg DEFAULT -lock=65536
$MUPIP set -reg DEFAULT -lock=131072
$MUPIP set -reg DEFAULT -lock=65537
$MUPIP set -reg DEFAULT -lock=65535
$MUPIP set -reg DEFAULT -lock=16383

# Check that lock space setting is there in the db file header
$gtm_tst/com/get_dse_df.csh        # creates dse_df.log
$grep -E "Region          |Lock space" dse_df.log
mv dse_df.log dse_df3.log

$gtm_tst/com/dbcheck.csh
