#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2008, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# C9I06-002997 MUPIP FREEZE should inhibit new kills and wait for ongoing kills to complete
#
echo "ENTERING C9I06002997"
#
setenv bkp_dir "`pwd`/C9I06002997"
mkdir $bkp_dir
chmod 777 $bkp_dir

# Create database with 3 regions
$gtm_tst/com/dbcreate.csh . 3

#multi-region commands works on ftok order. Do a mupip backup to get database and region name variables defined in ftok order
source $gtm_tst/$tst/u_inref/db_reg_var.csh

#Set KIP = 1
echo "# Set kill_in_prog=1 for second region : GTM_TEST_DEBUGINFO $reg2"
$DSE << DSE_EOF >&! dse_change_kip.out
find -reg="$reg2"
change -file -kill_in_prog=1
exit
DSE_EOF

echo "# MUPIP FREEZE test starts ..."
#Set KIP = 1 for region $reg2. ( This is already done in previous section of the test )
#Test mupip freeze, mupip integ region and mupip integ file
echo ""
# This should be succuessful
echo "# set MUPIP freeze ON for the first region. Expect success : GTM_TEST_DEBUGINFO $reg1"
$MUPIP freeze -on $reg1 >& freeze1_${reg1}.out
$grep "All requested regions frozen" freeze1_${reg1}.out

# Save dse dump in case freeze error for region1 later
$DSE dump -file -all >& dse_region1_1.out

# MUPIP FREEZE on second region will wait for KIP and fail. We have added timing test so ensure that
# FREEZE actually waited for KIP before erroring out.
set format="%Y %m %d %H %M %S %Z"
set stime=`date +"$format"`	# Start time
# This should generate YDB-W-MUKILLIP error
echo "# set MUPIP freeze ON for the second region. Expect error message : GTM_TEST_DEBUGINFO $reg2"
$MUPIP freeze -on  $reg2 >& freeze1_${reg2}.outx
$tst_awk -v "region=$db2" '{gsub(region,"##DBNAME2##") ; print }' freeze1_${reg2}.outx
set etime=`date +"$format"`	# End time
echo $stime " " $etime >>& time_diff_freeze.txt
@ difftime =`$tst_awk -f $gtm_tst/com/diff_time.awk time_diff_freeze.txt`
if ($difftime < 30) then
	echo "kiptest failed in FREEZE. Please check the time difference in time_diff_freeze.txt"
endif
# Save dse dump in case freeze error for region1 later
$DSE dump -file -all >& dse_region1_2.out
# This should be succuessful
echo "# set MUPIP freeze ON for the third region. Expect success : GTM_TEST_DEBUGINFO $reg3"
$MUPIP freeze -on $reg3 >& freeze1_${reg3}.out
$grep "All requested regions frozen" freeze1_${reg3}.out
echo "# MUPIP FREEZE test ends"
echo ""

# Save dse dump in case freeze error for region1 later
$DSE dump -file -all >& dse_region1_3.out

# Test MUPIP INTEG on regions
echo "MUPIP INTEG test on REGION started ..."
# This command should display error "Database for region $reg1 is already frozen, not integing"
# This indicates success on MUPIP FREEZE $reg1 commands above
echo "# MUPIP integ for first region. Expect region already frozen : GTM_TEST_DEBUGINFO $reg1"
$MUPIP integ -noonline -region $reg1 >& integ_${reg1}.outx
$tst_awk -v "region=$reg1" '{gsub(region,"##REGION1##") ; print }' integ_${reg1}.outx

# MUPIP INTEG on second region will wait for KIP and fail. We have added timing test so ensure that
# INTEG actually waited for KIP before erroring out.
set stime=`date +"$format"`
# This command should display integrity error "Database for region $reg2 has kills in progress"
echo "# MUPIP integ for second region. Expect error message: GTM_TEST_DEBUGINFO $reg2"
$MUPIP integ -noonline -region $reg2 >& integ_${reg2}.outx
$tst_awk -v "region=$reg2" -v "db=$db2" '{gsub(region,"##REGION2##") ; gsub(db,"##DBNAME2##"); print }' integ_${reg2}.outx
set etime=`date +"$format"`
echo $stime " " $etime >>& time_diff_integ.txt
@ difftime =`$tst_awk -f $gtm_tst/com/diff_time.awk time_diff_integ.txt`
if ($difftime < 30) then
        echo "kiptest failed in INTEG. Please check the time difference in time_diff_integ.txt"
endif
# This command should display error "Database for region $reg3 is already frozen, not integing"
# This indicates success on MUPIP FREEZE $reg3 commands above
echo "# MUPIP integ for third region. Expect region already frozen : GTM_TEST_DEBUGINFO $reg1"
$MUPIP integ -noonline -region $reg3 >& integ_${reg3}.outx
$tst_awk -v "region=$reg3" '{gsub(region,"##REGION3##") ; print }' integ_${reg3}.outx
echo "# MUPIP INTEG test on REGION ends"

# Test MUPIP INTEG on file
echo ""
echo "# MUPIP INTEG test on FILE started ..."
echo "# MUPIP integ -file for first region"
# No integ errors
$MUPIP integ -file $db1 >& integ2_${dbname1}.out
if ($status) echo "$db1 has integ errors"
$grep "No errors detected by integ" integ2_${dbname1}.out
# Expect a warning %YDB-W-MUKILLIP but no integrity errors
echo "# MUPIP integ -file for second region. Expect warning"
$MUPIP integ -file $db2  >& integ2_${dbname2}.outx
$tst_awk -v "region=$db2" '{gsub(region,"##DBNAME2##") ; print }' integ2_${dbname2}.outx
# No integ errors
echo "# MUPIP integ -file for third region"
$MUPIP integ -file $db3 >& integ2_${dbname3}.out
if ($status) echo "$db3 has integ errors"
$grep "No errors detected by integ" integ2_${dbname3}.out
# No integ errors as KIP should be reset by integ in the prior MUPIP INTEG -FILE
# Note that the output is now redirected to .out instead of .outx
echo "# MUPIP integ -file for second region. No warning expected"
$MUPIP integ -file $db2 >& integ2_${dbname2}.out
if ($status) echo "$db2 has integ errors"
$grep "No errors detected by integ" integ2_${dbname2}.out
echo "# MUPIP INTEG test on FILE ends"
echo ""
echo "# TEST MUPIP FREEZE '*' "
echo "# DSE SET KILL_IN_PROG=1 for second region : GTM_TEST_DEBUGINFO $reg2"
$DSE << DSE_EOF >&! dse_change_kip1.out
find -reg="$reg2"
change -file -kill_in_prog=1
exit
DSE_EOF
echo ""
# Turn freeze off on all the regions
echo "# Turn freeze off on all the regions"
$MUPIP freeze -off '*' >& freeze1_off_all.out
$grep "All requested regions unfrozen" freeze1_off_all.out
echo "# Turn ON freeze on all the regions. Expect failure"
$MUPIP freeze -on '*' >& freeze2_${dbname2}.outx
$tst_awk -v "region=$reg1" -v "db=$db2" '{gsub(region,"##REGION1##") ; gsub(db,"##DBNAME2##"); print }' freeze2_${dbname2}.outx
# FREEZE on first and third region should fail in the above freeze "*" command. This also means that MUPIP INTEG on
# first and third region should pass"
echo "# MUPIP integ for first region. Expect success : GTM_TEST_DEBUGINFO $reg1"
$MUPIP integ -noonline -region $reg1 >& integ2_${reg1}.out
if ($status) echo "$reg1 has integ errors"
$grep "No errors detected by integ" integ2_${reg1}.out

echo "MUPIP integ for third region. Expect success : GTM_TEST_DEBUGINFO $reg3"
$MUPIP integ -noonline -region $reg3 >& integ2_${reg3}.out
if ($status) echo "$reg3 has integ errors"
$grep "No errors detected by integ" integ2_${reg1}.out

echo "# Turn freeze off on all the regions"
$MUPIP freeze -off '*' >& freeze2_off_all.out
$grep "All requested regions unfrozen" freeze2_off_all.out

echo "# Start testing inhibit_kills counter"
# Start MUPIP FREEZE, INTEG and online BACKUP in background.
# Since KIP is set for second region. above processes should wait for KIP to become zero and also increment inhibit_kills
# flag. DSE dump will show KIP=1 and inhibit_kills=3
# Remove the fake KIP on second region.
# Examine KIP=0 and inhibit_kills=0.
echo "# Start MUPIP FREEZE, BACKUP and INTEG in backgroud"
$gtm_tst/$tst/u_inref/mupip_bkgrnd.csh "$reg2" $bkp_dir
# To ensure backup,integ and freeze processes running in background, is now in its KIP wait logic.
$gtm_tst/com/wait_for_log.csh -log mupip_bkgrnd_backup.out -waitcreation -duration 60 -message "Start kill-in-prog wait for database"
$gtm_tst/com/wait_for_log.csh -log mupip_bkgrnd_freeze.out -waitcreation -duration 60 -message "Start kill-in-prog wait for database"
$gtm_tst/com/wait_for_log.csh -log mupip_bkgrnd_integ.out -waitcreation -duration 60 -message "Start kill-in-prog wait for database"
echo "# inhibit_kills flag should be set to 3 by mupip freeze, backup and integ"

$DSE << DSE_EOF >&! dse_dump1.out
find -reg="$reg2"
dump -file -all
change -file -kill_in_prog=0
exit
DSE_EOF

$grep -E "KILLs in progress|Actual kills in progress|inhibiting KILLs" dse_dump1.out

#We sleep to ensure that the processes running in background get enough time to proceed after we had set KIP=0
$gtm_tst/com/wait_for_log.csh -log mupip_bkgrnd_backup.out -waitcreation -duration 60 -message "BACKUP COMPLETED"
$gtm_tst/com/wait_for_log.csh -log mupip_bkgrnd_integ.out -waitcreation -duration 60 -message "No errors detected by integ"
$gtm_tst/com/wait_for_log.csh -log mupip_bkgrnd_freeze.out -waitcreation -duration 60 -message "All requested regions frozen"
echo "# inhibit_kills flag should get cleared after MUPIP backup, freeze and integ are successful."

$DSE << DSE_EOF >&! dse_dump2.out
find -reg="$reg2"
dump -file -all
exit
DSE_EOF

$grep -E "KILLs in progress|Actual kills in progress|inhibiting KILLs" dse_dump2.out
$MUPIP freeze -off $reg2 -override >& freeze3_${reg2}_off.out
echo "# End testing inhibit_kills counter"
echo "# Start testing abandoned_kills counter"
# SET abandoned_kills flag.
# Test mupip backup, freeze and integ behaviour
echo "# Set abandoned_kills flag"
$DSE << DSE_EOF >&! dse_dump3.out
find -reg="$reg2"
change -file -abandoned_kills=1
exit
DSE_EOF

setenv bkp_dir "`pwd`/C9I06002997_1"
mkdir $bkp_dir
chmod 777 $bkp_dir
echo "# MUPIP BACKUP ALL regions. Region2 is expected to have warning but will not affect backup."
$MUPIP backup -online '*' $bkp_dir  >& backup3_${dbname2}.outx
$grep "YDB-W-KILLABANDONED" backup3_${dbname2}.outx | $tst_awk -v "region=$db2" '{gsub(region,"##DBNAME2##") ; print }'
$grep "BACKUP COMPLETED" backup3_${dbname2}.outx

echo "# MUPIP FREEZE ALL regions. Region2 is expected to have warning but will be frozen."
$MUPIP freeze -on '*' >& freeze3_${dbname2}.outx
$grep "WARNING: The region"  freeze3_${dbname2}.outx | $tst_awk '{gsub(/'$reg2/',"##REGION2##"); print }'
$grep "All requested regions frozen"  freeze3_${dbname2}.outx
$MUPIP freeze -off '*' >& freeze3_off_all.out

echo "# MUPIP INTEG ALL regions. Region2 is expected to have warning, but will be frozen."
$MUPIP integ -noonline -region '*' >& integ3_${dbname2}.outx
$grep "YDB-W-KILLABANDONED" integ3_${dbname2}.outx | $tst_awk -v "region=$db2" '{gsub(region,"##DBNAME2##") ; print }'
#$grep "Database for region" integ3_${dbname2}.outx | $tst_awk '{gsub(/'$reg1/',"##REGION1##"); gsub(/'$reg2/',"##REGION2##"); gsub(/'$reg3/',"##REGION3##") ; print }'

echo "# Reset abandoned_kills flag"
$DSE << DSE_EOF >&! dse_dump4.out
find -reg="$reg2"
change -file -abandoned_kills=0
exit
DSE_EOF
$grep "All requested regions unfrozen" freeze3_off_all.out
echo "# End testing abandoned_kills counter"
$gtm_tst/com/dbcheck.csh
echo "# LEAVING C9I06002997"
