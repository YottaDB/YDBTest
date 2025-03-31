#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-F135427 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-005_Release_Notes.html#GTM-F135427)

GT.M V7.1-000 provides the capability to upgrade a V6 database to V7 in-place. There is no ability to downgrade a V7 database to V6 in place. You can use MUPIP EXTRACT on V7 and MUPIP LOAD on V6 as long as the data does not cause the V6 database file to exceed the V6 maximum limits or revert to a prior version using a suitable combination of replicating instances. GT.M V7.1-000 blocks all access to a V6 database marked as not fully upgraded from V4 format.

GT.M V7 databases differ from V6 in the following ways. Please refer to the Administration and Operations Guide for more details about these differences.

Starting Virtual Block Number (VBN) is 8193, or slightly more on upgraded files, in V7 vs. 513 in V6

Block "Pointers" are 64-bit in V7 rather than 32-bit in V6

A GT.M V7 instance can originate BC/SI replication stream to or replicate from a V6 BC/SI replication stream as long as the V7 database remains within the maximum V6 limits.

The V6 to V7 database upgrade process is split into two phases intended to reduce the downtime necessary for a database upgrade. This process is considerably faster and consumes less disk space than a traditional extract, transfer and load cycle. Please refer to Upgrading to GT.M V7.1-000 (http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-000_Release_Notes.html#upgrade) for more details. (GTM-F135427)
CAT_EOF
echo

setenv gtm_test_use_V6_DBs 0  # Disable V6 mode DBs as this test already switches versions for its various test cases
source $gtm_tst/com/ydb_prior_ver_check.csh $gtm_test_v6_dbcreate_rand_ver
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
echo '# The below tests force the use of V6 mode to create DBs. This requires turning off ydb_test_4g_db_blks since'
echo '# V6 and V7 DBs are incompatible in that V6 cannot allocate unused space beyond the design-maximum total V6 block limit'
echo '# in anticipation of a V7 upgrade.'
setenv ydb_test_4g_db_blks 0
setenv ydb_msgprefix "GTM"
setenv ydb_prompt "GTM>"
echo

echo "### Test case 1: In-place database upgrade from V6 to V7"
echo "# Set version to: V6"
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
setenv gtmgbldir T1.gld
echo "# Create a V6 database"
$gtm_tst/com/dbcreate.csh T1 >& dbcreateT1.log
$gtm_dist/mumps -run GDE exit >&! gdeT1.out
echo "# Set a value in the database: ^x=1"
$gtm_dist/mumps -run %XCMD 'set ^x=1'
echo "# Write the current contents of the database, i.e. ^x=1"
$gtm_dist/mumps -run %XCMD 'write "^x="_^x'
echo "# Confirm the database format is 'V6' format and that the database IS fully upgraded"
$gtm_dist/dse dump -file -all >&! dseT1a.out
grep "Desired DB Format  " dseT1a.out | sed 's/.*\(Desired DB Format .*\)/\1/'
grep "Database is Fully Upgraded" dseT1a.out | sed 's/.*\(Database is Fully Upgraded .*\)/\1/'
echo

echo "# Set version to: V7"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo "# Upgrade the global directory : GDE exit"
$gtm_dist/mumps -run GDE exit >>&! gdeT1.out

echo "# Perform phase 1 of in-place upgrade : MUPIP UPGRADE"
echo "y" | $gtm_dist/mupip upgrade -file T1.dat >&! mupipT1.out
echo "# Confirm the database format is 'V7m' format and that the database is NOT fully upgraded"
$gtm_dist/dse dump -file -all >&! dseT1b.out
grep "Desired DB Format  " dseT1b.out | sed 's/.*\(Desired DB Format .*\)/\1/'
grep "Database is Fully Upgraded" dseT1b.out | sed 's/.*\(Database is Fully Upgraded .*\)/\1/'
echo

echo "# Perform phase 2 of in-place upgrade : MUPIP REORG -UPGRADE"
echo "y" | $gtm_dist/mupip reorg -upgrade -file=T1.dat >>&! mupipT1.out
echo "# Confirm the database format is 'V7m' format and that the database is NOT fully upgraded (need optional phase 3)"
$gtm_dist/dse dump -file -all >&! dseT2a.out
grep "Desired DB Format  " dseT2a.out | sed 's/.*\(Desired DB Format .*\)/\1/'
grep "Database is Fully Upgraded" dseT2a.out | sed 's/.*\(Database is Fully Upgraded .*\)/\1/'
echo

echo "# Perform (optional) phase 3 of in-place upgrade : Manually upgrade all database blocks then redo MUPIP REORG -UPGRADE"
echo "# Update the value of the only global variable to upgrade only database block: ^x=2"
$gtm_dist/mumps -run %XCMD 'set ^x=2'
echo "# Set another value in the database: ^y=2"
$gtm_dist/mumps -run %XCMD 'set ^y=2'
echo "# Write the current contents of the database, i.e. ^x=2, ^y=2"
$gtm_dist/mumps -run %XCMD 'write "^x="_^x_",^y="_^y'
echo "# Run MUPIP REORG -UPGRADE to complete database block upgrade"
echo "y" | $gtm_dist/mupip reorg -upgrade -file=T1.dat >>&! mupipT1.out
echo "# Confirm the database format is 'V7m' format and that the database IS fully upgraded"
$gtm_dist/dse dump -file -all >&! dseT2a.out
grep "Desired DB Format  " dseT2a.out | sed 's/.*\(Desired DB Format .*\)/\1/'
grep "Database is Fully Upgraded" dseT2a.out | sed 's/.*\(Database is Fully Upgraded .*\)/\1/'
echo

echo "# Set another value in the database: ^z=3"
$gtm_dist/mumps -run %XCMD 'set ^z=3'
echo "# Write the current contents of the database, i.e. ^x=2, ^y=2, ^z=3"
$gtm_dist/mumps -run %XCMD 'write "^x="_^x_",^y="_^y_",^z="_^z'
echo

echo "### Test case 2: MUPIP EXTRACT from V7, then MUPIP LOAD to V6 (when EXTRACTed data falls within V6 limits)"
echo "# Set version to: V7"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo "# Create a V7 database"
setenv gtmgbldir T2v7.gld
$gtm_tst/com/dbcreate.csh T2v7 >& dbcreateT2v7.log
echo "# Set a value in the V7 database: ^x=1"
$gtm_dist/mumps -run %XCMD 'set ^x=1'
echo "# Extract the V7 database"
$gtm_dist/mupip extract -format=zwr x.zwr >&! mupipextractT2v7.out

echo "# Set version to: V6"
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
echo "# Create a V6 database"
setenv gtmgbldir T2v6.gld
$gtm_tst/com/dbcreate.csh T2v6 >& dbcreateT2v6.log

echo "# Load the V7 database extract into the V6 database"
$gtm_dist/mupip load -format=zwr x.zwr >&! mupiploadT2.out
echo "# Write the contents of the V6 database using V6 version"
$gtm_dist/mumps -run %XCMD 'write ^x' >&! mumpsT2.out
cat mumpsT2.out
echo

echo "### Test case 3: GT.M V7.1-000 blocks all access to a V6 database marked as not fully upgraded from V4 format."
echo "### For details on this test case see: https://gitlab.com/YottaDB/DB/YDBTest/-/issues/655#note_2328483690"
echo "# Set version to: V6"
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
echo "# Create a V6 global directory"
setenv gtmgbldir T3v6.gld
$gtm_dist/mumps -run GDE exit >&! gdeT3v6.out
echo "# Create a V6 database"
$gtm_dist/mupip create >&! mupipT3.out
echo "# Set the database block format version to V4"
$gtm_dist/mupip set -version=V4 -reg "*" >&! mupipsetT3.out
echo "# Set value in the database"
$gtm_dist/mumps -run %XCMD 'set ^x=1'

echo "# Change version to: V7"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo "# Upgrade the global directory : GDE exit"
setenv gtmgbldir T3v7.gld
$gtm_dist/mumps -run GDE exit >&! gdeT3v7.out
echo "# Attempt to write the value in the database: expect a DBUPGRDREQ error"
$gtm_dist/mumps -run %XCMD 'zwrite ^x'

echo "# Change version to: V6"
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
setenv gtmgbldir T3v6.gld
rm -f T3v6.gld $gtm_dist/mumps -run GDE exit >>&! gdeT3v6.out
echo "# Upgrade the database block format from V4 to V6"
$gtm_dist/mupip reorg -upgrade -reg "*" >&! mupipreorgT3.out

echo "# Change version to: V7"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
setenv gtmgbldir T3v7.gld
$gtm_dist/mumps -run GDE exit >&! gdeT3v7.out
echo "# Attempt to write the value in the database: expect no errors"
$gtm_dist/mumps -run %XCMD 'zwrite ^x'
echo

echo '### Test case 4: GT.M V7.1-000 issues MUNOFINISH error (error detail "Extension size not set") when attempting to MUPIP UPGRADE a V6 database with extension size 0'
echo "### For details on this test case see: https://gitlab.com/YottaDB/DB/YDBTest/-/issues/655#note_2366436858"
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
echo "# Create a V6 database"
setenv gtmgbldir T4.gld
$gtm_tst/com/dbcreate.csh T4 >& dbcreateT4.log
echo "# Set db extension size to 0"
$gtm_dist/mupip set -extension=0 -reg DEFAULT >>&! mupipT4.out
echo "# Change version to: V7"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
$gtm_dist/mumps -run GDE exit >&! gdeT4v7.out
echo "# Run MUPIP UPGRADE, expect MUNOFINISH"
echo "y" | $gtm_dist/mupip upgrade -reg "*"
echo

echo "### Test case 5: GT.M V7.1-000 issues a MUNOFINISH error (and not a DBUPGRDREQ error) when retrying MUPIP UPGRADE on a V6 database with extension size 0"
echo "### For details on this test case see: https://gitlab.com/YottaDB/DB/YDBTest/-/issues/655#note_2373149364"
echo "# Create a V6 database"
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
setenv gtmgbldir T5.gld
$gtm_tst/com/dbcreate.csh T5 >& dbcreateT5.log
echo "# Set db extension size to 0"
$gtm_dist/mupip set -extension=0 -reg DEFAULT >>&! mupipT5.out
echo "# Change version to: V7"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
$gtm_dist/mumps -run GDE exit >&! gdeT5v7.out
echo "# Run MUPIP UPGRADE, expect MUNOFINISH"
echo "y" | $gtm_dist/mupip upgrade -reg "*"
echo "# Retry MUPIP UPGRADE, expect MUNOFINISH"
echo "y" | $gtm_dist/mupip upgrade -reg "*"
echo

echo "### Test case 6: MUPIP UPGRADE of a database that has lots of globals that have been mostly killed does not result in a DBLRCINVSZ integrity error"
echo "### For details on this test case see: https://gitlab.com/YottaDB/DB/YDBTest/-/issues/655#note_2373413989"
echo "# Set version to: V6"
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
echo "# Create a V6 database"
setenv gtmgbldir T6.gld
$gtm_tst/com/dbcreate.csh T6 >& dbcreateT6.log
echo "# Run the manygbls routine"
$gtm_dist/mumps -run manygbls^gtmf135427
echo "# Set version to: V7"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
$gtm_dist/mumps -run GDE exit >&! gdeT6.out
echo "# Run MUPIP UPGRADE"
echo "y" | $gtm_dist/mupip upgrade -reg "*" >&! mupipupgradeT6.out
echo "# Run MUPIP INTEG, expect no DBLRCINVSZ error"
echo "# Prior to YottaDB commit https://gitlab.com/YottaDB/DB/YDB/-/commit/5e80ddb29135a200eaddec6244529dba90eed984,"
echo "# this would randomly issue an DBLRCINVSZ error."
$gtm_dist/mupip integ -reg "*" >&! mupipintegT6.out
grep DBLRCINVSZ mupipintegT6.out
grep "No errors detected by integ." mupipintegT6.out
