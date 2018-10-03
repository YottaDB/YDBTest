#!/usr/local/bin/tcsh -f
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
# Set white box testing environment to avoid assert failures along with REPLMULTINSTUPDATE error
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 137
setenv gtm_repl_instance "mumps.repl"

$MULTISITE_REPLIC_PREPARE 4

echo "Create the DB"
# Set up a non replicated region HREG for our trigger activities (the 9th region from the dbcreate)
# Relies on the existance of HREG, hence the 9 region DB
setenv gtm_test_repl_norepl 1
$gtm_tst/com/dbcreate.csh mumps 9 -gld_has_db_fullpath >>& dbcreate.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate.out
	exit -1
endif
echo ""
echo ""


echo "# Show INST1 mapped instance file"
$GDE SHOW -INSTANCE  >& show1.log
$grep "mumps.repl" show1.log
echo ""

echo "# Remove INST1 gld mapping to instance file"
echo "# to test that gtm_repl_instname determines .repl mapping when otherwise unset and "
echo "# that GDE CHANGE -INSTANCE -FILE_NAME=" '""' "removes the .repl mapping in the gld file."
echo "----------------------------------------------------------------------------"

$GDE CHANGE -INSTANCE -FILE_NAME=\"\" >>& GDEchangeINST1_1.log
echo ""

echo "# Show INST1 mapped instance file"
$GDE SHOW -INSTANCE  >& show2.log
$grep "mumps.repl" show2.log
echo ""



echo "# Start INST1 INST2 replication"
$MSR START INST1 INST2
echo ""
echo "# Start INST3 INST4 replication"
$MSR START INST3 INST4
echo ""

setenv path_INST1 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST1 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`
setenv path_INST3 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST3 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`

#gtm_repl_instance is now explicitly set to INST1's .repl file
setenv gtm_repl_instance "$path_INST1/mumps.repl"



echo "# Remove and replace INST3 .repl mapping "
echo "# to test that .repl file mapping overrides the gtm_repl_instname env var."
echo "----------------------------------------------------------------------------"

echo "# Show INST3 mapped instance file"
$MSR RUN INST3 "$GDE SHOW -INSTANCE  ">& show1.log; $grep "mumps.repl" show1.log

echo "# Remove INST3 mapping"
$MSR RUN INST3 "$gtm_tst/com/rmv_map.csh" >>& GDEchangeINST3_1.log
echo "# Change INST3 mapped instance file"
$MSR RUN INST3 "$GDE CHANGE -INSTANCE -FILE_NAME=$path_INST3/mumps.repl" >>& GDEchangeINST3_1.log

echo "# Show INST3 mapped instance file"
$MSR RUN INST3 "$GDE SHOW -INSTANCE " >& show2.log; $grep "mumps.repl" show2.log
echo ""
echo ""




echo "# Run gtm8182.m to update both INST1 and INST3 DB"
echo "----------------------------------------------------------------------------"
$gtm_dist/mumps -run gtm8182

# Set gtm_repl_instance back to the non-INST1 specific instance file
setenv gtm_repl_instance "mumps.repl"

echo "# Show INST1 mapped instance file"
$GDE SHOW -INSTANCE  >& show3.log
$grep "mumps.repl" show3.log
echo ""

echo "# Sync originating and replicating instances"
$MSR SYNC INST1 INST2
$MSR SYNC INST3 INST4
echo ""

echo "# Check INST2 receiver server for update (expecting only ^jake to be defined)"
$MSR RUN INST2 '$MUPIP extract INST2_extract.glo'
echo ""

echo "# Check INST4 receiver server for update (expecting only ^zack to be defined)"
$MSR RUN INST4 '$MUPIP extract INST4_extract.glo'
echo ""
echo ""


echo "# Remove mapping from both INST1 and INST3 in order to test for error"
echo "# upon using both instances in a single process"
echo "----------------------------------------------------------------------------"
echo "# Remove INST3 mapping"
$MSR RUN INST3 "$gtm_tst/com/rmv_map.csh" >>& GDEchangeINST3_2.log
echo "# Remove INST1 mapping"
$GDE CHANGE -INSTANCE -FILE_NAME=\"\" >>& GDEchangeINST1_2.log
echo "# Run gtm8182.m again"
$gtm_dist/mumps -run gtm8182 # | grep "YDB-E-"
echo "# Return INST3 mapping to correct state"
$MSR RUN INST3 "$GDE CHANGE -INSTANCE -FILE_NAME=$path_INST3/mumps.repl" >>& GDEchangeINST3_2.log
echo ""
echo ""


echo "# Change INST1 mapped instance file to the INST3 instance file"
echo "# in order to test for an error upon sharing a region between 2 instances"
echo "----------------------------------------------------------------------------"
$GDE CHANGE -INSTANCE -FILE_NAME=$path_INST3/mumps.repl >>& GDEchangeINST1_3.log
echo "# Run gtm8182.m again"
$gtm_dist/mumps -run gtm8182 # | grep "YDB-E-"
echo "# Remove INST1 mapping"
$GDE CHANGE -INSTANCE -FILE_NAME=\"\" >>& GDEchangeINST1_3.log
echo ""
echo ""


echo "# Run TP1^gtm8182 to test for an error when updating multiple "
echo "# instances within the same TP transaction"
echo "----------------------------------------------------------------------------"
$gtm_dist/mumps -run TP1^gtm8182 # | grep "YDB-E-"
echo "# Sync originating and replicating instances"
$MSR SYNC INST1 INST2
$MSR SYNC INST3 INST4
echo ""
echo "# Check INST2 receiver server for update (expecting variable ^mike) "
$MSR RUN INST2 '$MUPIP extract INST2_2_extract.glo'
echo ""
echo "# Check INST4 receiver server for update (expecting no new variables)"
$MSR RUN INST4 '$MUPIP extract INST4_2_extract.glo'
echo ""
echo ""


echo "# Run TP2^gtm8182 to test that updating multiple instances in a single"
echo "# TP transaction is allowed as long as the second instance only has"
echo "# non-replicating regions updated (HREG in this case)"
echo "----------------------------------------------------------------------------"
$gtm_dist/mumps -run TP2^gtm8182 # | grep "YDB-E-"
$MSR SYNC INST1 INST2
$MSR SYNC INST3 INST4
echo ""
echo "# Check INST2 receiver server for update (expecting variable ^edd) "
$MSR RUN INST2 '$MUPIP extract INST2_3_extract.glo'
echo ""
echo "# Check INST3 receiver server for update (expecting variable ^al)"
$MSR RUN INST3 '$MUPIP extract INST3_1_extract.glo'
echo ""
echo "# Check INST4 receiver server for update (expecting no new variables)"
$MSR RUN INST4 '$MUPIP extract INST4_3_extract.glo'
echo ""
echo ""
echo ""


echo "# Run testPool^gtm8182 to test that "'$VIEW("JNLPOOL")' "returns different"
echo "# instance file names when switching between multiple instances and when"
echo "# another instance is accessed through an extended reference"
echo "----------------------------------------------------------------------------"
$gtm_dist/mumps -run testPool^gtm8182
echo ""
echo ""


echo "# Stop replication between INST3 INST4 and run gtm8182.m in order to test"
echo "# that using 2 instances will cause an error when 1 jnl pool is not set up"
echo "----------------------------------------------------------------------------"
$MSR STOP INST3 INST4
echo "# Run gtm8182.m again"
$gtm_dist/mumps -run gtm8182 # | grep "YDB-E-"
echo ""
echo ""



echo "Check and shutdown the DB"
echo "----------------------------------------------------------------------------"
$gtm_tst/com/dbcheck.csh >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
	exit -1
endif
echo "DB has shutdown gracefully"
