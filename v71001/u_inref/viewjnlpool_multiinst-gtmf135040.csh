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
GTM-F135040 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-001_Release_Notes.html#GTM-F135040):

Specifying a second expression for \$VIEW("JNLPOOL") provides a means of iterating through active Journal Pools. If the second expression is an empty string, the function returns the replication instance file name associated with the instance first attached by the process or the string "*" if the process has not previously engaged with any instance. If the file name specified in the second expression does not match the replication instance file name for any of the active Journal Pools the string "*" is returned. Otherwise the file name of the Journal Pool attached after the Journal Pool with the file name given in the second expression is returned. Note the two argument form of \$VIEW("JNLPOOL") does not change the current Replication Instance. (GTM-F135040)

CAT_EOF
echo

setenv gtm_repl_instance "mumps.repl"
$MULTISITE_REPLIC_PREPARE 4

echo "# Create a 1 region DB with gbl_dir mumps.gld and region DEFAULT" # , AREG, and BREG"
$gtm_tst/com/dbcreate.csh mumps 1  -gld_has_db_fullpath >& dbcreate_log.txt

echo "# Start INST1 INST2 replication"
$MSR START INST1 INST2
echo
echo "# Start INST3 INST4 replication"
$MSR START INST3 INST4
echo

if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/merge_gtmcrypt_config.csh INST3
endif

echo '# Test 1: The second expression is an empty string, i.e.: $VIEW("JNLPOOL",""),'
echo '# and the process has not previously engaged with any replication instance.'
echo '# Expect the string "*".'
$gtm_dist/mumps -run emptystr^gtmf135040
echo

echo '# Test 2: The second expression is an empty string, i.e.: $VIEW("JNLPOOL",""),'
echo '# and a replication instance was previously attached by the process.'
echo '# Expect the name of the initially attached process.'
$gtm_dist/mumps -run emptystrattached^gtmf135040
echo

echo '# Test 3: The second expression does not match a replication instance file, e.g.: $VIEW("JNLPOOL","NOTAFILENAME")'
echo '# Expect the string "*".'
$gtm_dist/mumps -run nomatch^gtmf135040
echo

echo '# Test 4: Iterate through journal pools when the second expression matches a replication instance file, e.g.: $VIEW("JNLPOOL","")'
echo '# Expect the file name of the first Journal Pool, i.e. INST1, followed by the file name of the second one, i.e. INST3,'
echo '# followed by the empty string.'
echo '# Get the paths to the INST1 and INST3 replication instance files'
setenv path_INST1 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST1 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`
setenv path_INST3 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST3 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`
echo '# Run gtmf135040.m to update both INST1 and INST3'
$gtm_dist/mumps -run gtmf135040 $tst_working_dir
echo

echo '# Test 5: Iterate through journal pools in reverse order when the second expression matches a replication instance file, e.g.: $VIEW("JNLPOOL","")'
echo '# Expect the file name of the second Journal Pool, i.e. INST3, followed by the file name of the first one, i.e. INST1,'
echo '# followed by the empty string.'
echo '# Run reversed^gtmf135040.m to update both INST1 and INST3'
$gtm_dist/mumps -run reversed^gtmf135040 $tst_working_dir
echo

echo '# Test 6: Single-argument form shows the current instance file, i.e.: $VIEW("JNLPOOL")'
echo '# Expect the file name of the current Journal Pool, i.e. INST1. Then change the Journal Pool to INST3,'
echo '# then expect its filename.'
echo '# Run single^gtmf135040 to update both INST1 and INST3'
$gtm_dist/mumps -run single^gtmf135040 $tst_working_dir
echo

echo '# Test 7: $VIEW("JNLPOOL") shows the instance file of the first-accessed instance when:'
echo '# 1. A DB update is made to a replication instance, e.g. INST1'
echo '# 2. The global directory is changed to a second replication instance, e.g. INST3'
echo '# 3. NO updates are made while using the second replication instance, e.g. INST3'
echo '# 4. $VIEW("JNLPOOL") is called while still using the second replication instance, e.g. INST3'
echo '# Expect the file name of the initial Journal Pool, i.e. INST1.'
echo '# Run noupdate^gtmf135040 to update only INST1 but not INST3'
$gtm_dist/mumps -run noupdate^gtmf135040 $tst_working_dir
echo

echo '# Test 8: $VIEW("JNLPOOL") shows the replication instance file of the latest instance when:'
echo '# 1. A DB update is made to a replication instance, e.g. INST1'
echo '# 2. A DB update is made to a second replication instance using an extended reference, e.g. INST3'
echo '# 3. $VIEW("JNLPOOL") is called'
echo '# Expect the file name of the latest Journal Pool, i.e. INST3.'
echo '# Run erefswitch^gtmf135040 to update INST3 through an extended reference'
$gtm_dist/mumps -run erefswitch^gtmf135040 $tst_working_dir
echo

echo "# Stop INST1 INST2 replication"
$MSR STOP INST1 INST2
echo
echo "# Stop INST3 INST4 replication"
$MSR STOP INST3 INST4
echo

$gtm_tst/com/dbcheck.csh
