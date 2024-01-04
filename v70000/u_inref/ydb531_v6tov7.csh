#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

# Turn off statshare related env var as it affects test output and is not considered worth the trouble to maintain
# the reference file with SUSPEND/ALLOW macros for STATSHARE and NON_STATSHARE
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

set imptp_runtime = 5  # Since this test does not run on ARM, this is long enough to generate some data on x86 boxes
#
# If $gtm_db_counter_sem_incr is randomly set at 8192 or more, this can leave orphaned shared memory. Normally, this
# is not an issue but in this test which does some things in V6 mode and some in V7 has led to intermittent VERMISMATCH
# errors when a DB was opened by V6, then closed and orphaned the V6 shared memory, then tries to open the same DB
# with V7. So here we set $gtm_db_counter_sem_incr to 0 to prevent this intermittent error. Discussion is
# here: https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1700#note_1629214545
#
setenv gtm_db_counter_sem_incr 0
#
echo
echo '# This test does an upgrade of V6 DBs to V7 DBs via two methods:'
echo '#   1. MUPIP EXTRACT/LOAD'
echo '#   2. Using the MERGE command'
echo
echo '#'
echo '# Force use of a V6 mode to create the DBs. This also means turning off ydb_test_4g_db_blks as the two'
echo '# are incompatible together as V6 cannot create DBs with holes in them.'
setenv gtm_test_use_V6_DBs 1
setenv ydb_test_4g_db_blks 0
echo

# Before running dbcreate.csh, make sure we run all compatability checks of current env vars against old version we are
# going to soon switch too after the "dbcreate.csh" call.
source $gtm_tst/com/ydb_prior_ver_check.csh $gtm_test_v6_dbcreate_rand_ver

echo '# Create 5 DBs for imptp to fill'
$gtm_tst/com/dbcreate.csh mumps 5 -key=255 -rec=1500 -blk=4096 -glo=4096 -null_subscripts=always
echo
echo '# Switch back to the V6 version that created the DBs to create initial content for the DBs'
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
set savegbldir = $gtmgbldir
setenv gtmgbldir "${savegbldir}.old"
echo
echo "# Start imptp to fill DBs - let run for $imptp_runtime seconds then stop imptp"
$gtm_tst/com/imptp.csh 5 >&! imptpmain.out
source $gtm_tst/com/imptp_check_error.csh imptpmain.out; if ($status) exit 1
sleep ${imptp_runtime}s         # Wait for given number of seconds
echo
echo '# Stop imptp and run checkdb.csh'
$gtm_tst/com/endtp.csh >>&! imptpmain.out
$gtm_tst/com/checkdb.csh
echo
echo '# Create a readable extract of the databases as they exist now (V6 mode). Also create a binary extract for'
echo '# use with the extract/load type upgrade.'
#
# Note we add the -freeze option, not because it is needed since everything in this test is quiesced,
# but because this option is recommended in the release notes in the section on upgrading to V7.0-001.
# Release note mention is here: http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-001_Release_Notes.html#upgrade
#
$MUPIP extract -freeze -format=zwr V6OrigDBs.zwr >& extractV6OrigDBs.zwr.out
$MUPIP extract -freeze -format=bin V6OrigDBs.bin >& extractV6OrigDBs.bin.out
echo
echo '# Switching back to test/V7 version'
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
setenv gtmgbldir $savegbldir
echo
echo '# Drive initialization of the upgrade engine'
$gtm_dist/mumps -run UpgradeInit^DBUpgradeMethods
#
# Method #1 - MUPIP EXTRACT/LOAD
#
echo
$echoline
echo '***** Upgrade Method #1 - MUPIP EXTRACT/LOAD'
$echoline
echo
echo '# Drive script that performs upgrade by MUPIP EXTRACT/LOAD'
#
# Note that this routine creates the TrigDefsInV7XtrLoadExtract.txt  trigger extract file that is used in
# extract comparisons later after the two methods are tested.
#
$gtm_dist/mumps -run UpgradeByXtrLoad^DBUpgradeMethods
set savestatus = $status
if (0 != $savestatus) then
	echo '**** Upgrade by MUPIP EXTRACT/LOAD failed with rc='$savestatus
endif
cd ./V7XtrLoadDBs
echo
echo '# Create an extract of this upgraded DB'
$MUPIP extract -format=zwr ../V7XtrLoadDBs.zwr >& ../extractV7XtrLoadDBs.out
echo
echo "# Start imptp to validate upgrade by MUPIP EXTRACT/LOAD V7 DBs - let run for $imptp_runtime seconds then stop imptp"
$gtm_tst/com/imptp.csh 5 >&! imptpXtrLoad.out
source $gtm_tst/com/imptp_check_error.csh imptpXtrLoad.out; if ($status) exit 1
sleep ${imptp_runtime}s         # Wait for given number of seconds
echo
echo '# Stop imptp and run checkdb.csh'
$gtm_tst/com/endtp.csh >>&! imptpXtrLoad.out
$gtm_tst/com/checkdb.csh
cd .. # Revert back to main directory
#
# Method #2 - MERGE command
#
echo
echo
$echoline
echo '***** Upgrade Method #2 - Use MERGE command to migrate globals from V6 to V7 database'
$echoline
cat << CAT_EOF
#
# Second update method is via using one or more MERGE commands to migrate existing globals from the V6 DB
# to the V7 DB.
#
# The global directory is copied from the main directory to a created directory V7MergedDBs.
# Since the database names in the global directory created by dbcreate.csh are just the DB names without any
# path information, then when we MERGE one global to the same global, since the DB name is the same in both
# global directories, the data is copied onto itself instead of copying between the two databases. So with
# our merge running (locally) in the V6 DB, we need the global directory for the V7 DB to have full path
# information so YottaDB knows to copy the data to a DIFFERENT database.
#
# To determine the databases and global names that need to be merged, we run first run GDE SHOW -SEGMENT
# to get a list of the databases in this global directory. Then for each database in the global directory,
# we run GDE CHANGE -SEG xxxx -FILE=yyyy to change the database name for segment/region xxxx to the database
# name (including full path).
#
# Once the DB access is setup, we \$ORDER through the globals of the V6 database and do a MERGE for each
# one to migrate it to the V7 database.
#
CAT_EOF
echo
echo '# Drive script that performs upgrade by MERGE (output file UpgradeByMerge_output.txt)'
#
# Note that this routine creates the TrigDefsInV7MergedDBsExtract.txt trigger extract file that is used in
# extract comparisons later after the two methods are tested.
#
$gtm_dist/mumps -run UpgradeByMerge^DBUpgradeMethods
if (0 != $savestatus) then
	echo '**** Upgrade by MUPIP EXTRACT/LOAD failed with rc='$savestatus
endif
cd ./V7MergedDBs
echo
echo '# Create an extract of this upgraded DB'
$MUPIP extract -format=zwr ../V7MergedDBs.zwr >& ../extractV7MergedDBs.out
echo
echo "# Start imptp to validate upgrade by MERGE V7 DBs - let run for $imptp_runtime seconds then stop imptp"
$gtm_tst/com/imptp.csh 5 >&! imptpMerged.out
source $gtm_tst/com/imptp_check_error.csh imptpMerged.out; if ($status) exit 1
sleep ${imptp_runtime}s         # Wait for given number of seconds
echo
echo '# Stop imptp and run checkdb.csh'
$gtm_tst/com/endtp.csh >>&! imptpMerged.out
$gtm_tst/com/checkdb.csh
cd .. # Revert back to main directory
#
echo
$echoline
echo '# Verify the database extract from the V6 DBs is the same as the extracts from the two upgraded V7 DBs.'
echo '# Note comparisons are done starting with record 3 to avoid differences in header.'
$echoline
echo
tail -n +3 V6OrigDBs.zwr > V6OrigDBsNoHdr.zwr
tail -n +3 V7XtrLoadDBs.zwr > V7XtrLoadDBsNoHdr.zwr
tail -n +3 V7MergedDBs.zwr > V7MergedDBsNoHdr.zwr
@ statusdb = 0
diff -bcw V6OrigDBsNoHdr.zwr V7XtrLoadDBsNoHdr.zwr >& xtractdiff1.out
set diffstatus = $status
@ statusdb = $statusdb + $diffstatus
if (0 != $diffstatus) echo "V6OrigDBs.zwr and V7XtrLoadDBs.zwr differ unexpectedly - see xtractdiff1.out"
diff -bcw V6OrigDBsNoHdr.zwr V7MergedDBsNoHdr.zwr >& xtractdiff2.out
set diffstatus = $status
@ statusdb = $statusdb + $diffstatus
if (0 != $diffstatus) echo "V6OrigDBs.zwr and V7MergedDBs.zwr differ unexpectedly - see xtractdiff2.out"
#
if (0 == $statusdb) then
	if (0 == $gtm_test_trigger) then
		echo '** DB extracts match - PASS'
	else
		echo '** DB extracts match'
	endif
else
	echo '** Some extracts did not match - see xtractdiff[1-2].out'
endif
if (1 == $gtm_test_trigger) then
	@ statustrig = 0
	echo
	$echoline
	echo '# Verify the trigger extract from the V6 DB is the same as the extracts from the two upgraded V7 DBs.'
	echo '# Note the extracts need to be "normalized" first by removing the "cycle: n[nn..]" values in the comments'
	echo '# of the trigger extracts. When extracts are being freshly loaded into a DB, the cycle values will'
	echo '# change.'
	$echoline
	echo
	cp V6TriggerDefs.txt V6TriggerDefs.txt.orig
	sed -i 's/  cycle: [0-9]*//g' V6TriggerDefs.txt
	#
	cp V7XtrLoadDBs/TrigDefsInV7XtrLoadDBsExtract.txt V7XtrLoadTriggerDefs.txt
	sed -i 's/  cycle: [0-9]*//g' V7XtrLoadTriggerDefs.txt
	#
	cp V7MergedDBs/TrigDefsInV7MergedDBsExtract.txt V7MergedTriggerDefs.txt
	sed -i 's/  cycle: [0-9]*//g' V7MergedTriggerDefs.txt
	#
	diff -bcw V6TriggerDefs.txt V7XtrLoadTriggerDefs.txt >& xtractdiff3.out
	set diffstatus = $status
	@ statustrig = $statustrig + $diffstatus
	if (0 != $diffstatus) echo "V6TriggerDefs.txt and V7XtrLoadTriggerDefs.txt differ unexpectedly - see xtractdiff3.out"
	diff -bcw V6TriggerDefs.txt V7MergedTriggerDefs.txt >& xtractdiff4.out
	set diffstatus = $status
	@ statustrig = $statustrig + $diffstatus
	if (0 != $diffstatus) echo "V6TriggerDefs.txt and V7MergedTriggerDefs.txt differ unexpectedly - see xtractdiff4.out"
	#
	if (0 == $statustrig) then
		echo '** Trigger extracts match'
	else
		echo '** Some extracts did not match - see xtractdiff[3-4].out'
	endif
	echo
	@ statustot = $statusdb + $statustrig
	if (0 == $statustot) then
		echo '*** DB and Trigger extracts match - PASS ***'
	endif
endif
#
echo
echo "# Verify DBs"
$gtm_tst/com/dbcheck.csh
