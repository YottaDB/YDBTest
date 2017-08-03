#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# mumps.repl is not created at this point. unset gtm_custom_errors and restore later when replication servers are started
if ($?gtm_custom_errors) then
	setenv save_gtm_custom_errors $gtm_custom_errors
	unsetenv gtm_custom_errors
endif
# The test switches to prior versions. The default encryption is different for each version (random)
# Turn off encryption for the first test case.
setenv save_test_encryption $test_encryption
setenv test_encryption NON_ENCRYPT
# Versions prior to V62001 do not support triggers AND spanning regions; disable it. GTM-7877 added support
setenv gtm_test_spanreg 0

if (! $?gtm_test_replay) then
	set gtm7509_prior_ver = `$gtm_tst/com/random_ver.csh -gte V54002 -lte V61000`
	if ("$gtm7509_prior_ver" =~ "*-E-*") then
		echo "The requested prior version is not available: $gtm7509_prior_ver"
		exit 1
	endif
	echo "setenv gtm7509_prior_ver $gtm7509_prior_ver"	>>&! settings.csh
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $gtm7509_prior_ver

$MULTISITE_REPLIC_PREPARE 2
echo "# Test case 1 : Trying mupip trigger -select using a prior version, with a multi-line trigger created with current version"
$gtm_tst/com/dbcreate_base.csh mumps 1

$gtm_exe/mumps -run itemmultiline^gtm7509    # will create mumps[1-5].dat that we need to try out with V61000
mv mumps.gld mumps.gld_orig
source $gtm_tst/com/switch_gtm_version.csh $gtm7509_prior_ver $tst_image
$GDE exit >&! oldvergde.out
foreach file (mumps[0-9]*.dat)
	cp $file mumps.dat
	echo "# Trying $file (multi-line trigger created with current version) with prior version trigger select"
	cat /dev/null | $MUPIP trigger -select
	echo "------------------------------------------------------------------------------------"
end
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
mv mumps.gld mumps.gld_olver
mv mumps.gld_orig mumps.gld

echo '# Test case 5: While deleting triggers do not consider $c(10) as part of trigger'
echo "# Since the below two operations do not touch the db, just reuse the db of the current test case"
$gtm_exe/mumps -run deletenl^gtm7509

$gtm_tst/com/dbcheck_base.csh

# Backup the databases before proceeding to the next test case
$gtm_tst/com/backup_dbjnl.csh testcase1 "*.dat *.gld" "mv"

# Restore encryption
setenv test_encryption $save_test_encryption

echo "# Test case 2 : Doing a trigger select when the XECUTE string in the ^#t global is corrupted such that the last newline is instead some other character"
echo "# should not SIG-11(pro) or assert fail(dbg)"
$gtm_tst/com/dbcreate_base.csh mumps 1
cat > testcase2.trg << CAT_EOF
+^a -commands=S -name=abcd -xecute=<<
 do ^twork1
 do ^twork2
>>
CAT_EOF

echo "# Install the multiline trigger"
$gtm_exe/mumps -run %XCMD 'write $ztrigger("file","testcase2.trg"),!'

# Corrupt the last 1-byte of the ^#t("a",1,"XECUTE") node. This would be a newline.
# Overwrite last newline in the multi-line trigger with a byte randomly chosen from $c(64) thru $c(90) (to make it simple in avoiding special characters)
# The DSE DUMP of block 3 will display something like the below
#       Rec:9  Blk 3  Off A6  Size 24  Cmpc A  Key ^#t("a",1,"XECUTE")
# In this case, we want to add 0xA6 and 0x24 and subtract 1 to get the offset of the last byte and then use that to do the corruption.
setenv corruptoffset `$DSE dump -bl=3 |& $grep "XECUTE" | $tst_awk '{printf "obase=16; ibase=16; %s+%s-1\n",$5, $7}' | bc`
echo '# Corrupt the last byte of the multi-line trigger with a byte randomly chosen from $c(0) thru $c(255)'
$gtm_exe/mumps -run %XCMD 'write "$DSE overwrite -block=3 -offset="_$ztrnlnm("corruptoffset")_" -data="_$char(64+$r(26))' >&! dse_corrupt.csh
source dse_corrupt.csh

echo "# do mupip trigger -select and expect it to work"
cat /dev/null | $MUPIP trigger -select

$gtm_tst/com/dbcheck_base.csh
# Backup the databases before proceeding to the next test case
$gtm_tst/com/backup_dbjnl.csh testcase2 "*.dat *.gld" "mv"


echo "# Test case 3a : while doing a wildcard trig deletion,"
echo "# a TLGTRIG record should be written to only one journaled region"

$gtm_tst/com/dbcreate.csh mumps 4
cat >> testcase3.trg << cat_EOF
+^aglobal   -commands=set -xecute="do ^twork"
+^bcolon(:) -commands=set -xecute="do ^twork" -name=atrigger2
cat_EOF

$MSR START INST1 INST2
#$MUPIP set ${tst_jnl_str} -reg "*" >&! jnl_on_case3a.out
echo "# Install triggers in regions AREG And BREG"
$MUPIP trigger -trig=testcase3.trg
echo "# Delete all triggers with -*"
$gtm_exe/mumps -run %XCMD 'write $ztrigger("item","-*"),!'
$gtm_tst/$tst/u_inref/jnl_extract_detailed.csh
$gtm_tst/com/dbcheck.csh -extract

# Backup the databases before proceeding to the next test case
$gtm_tst/com/backup_dbjnl.csh testcase3a "*.dat *.gld *.mjl* *.mjf" "mv"
$MSR RUN INST2 '$gtm_tst/com/backup_dbjnl.csh testcase3a "*.dat *.gld *.mjl* *.mjf" "mv"'

echo "# Test case 3b : For a wildcard trigger deletion, if none of the trigger participating regions are journaled"
echo "# TLGTRIG should NOT be written to a non-participating region"
$gtm_tst/com/dbcreate_base.csh mumps 4
$MUPIP set ${tst_jnl_str} -reg CREG >&! jnl_on_case3b.out
echo "# Install triggers in regions AREG And BREG"
$MUPIP trigger -trig=testcase3.trg
echo "# Wildcard trigger delete with -a*"
$gtm_exe/mumps -run %XCMD 'write $ztrigger("item","-a*"),!'
$gtm_tst/$tst/u_inref/jnl_extract_detailed.csh
$gtm_tst/com/dbcheck_base.csh

# Backup the databases before proceeding to the next test case
$gtm_tst/com/backup_dbjnl.csh testcase3b "*.dat *.gld *.mjl* *.mjf" "mv"

echo "# Test case 4 : Replication with multiline and large triggers"
if ($?save_gtm_custom_errors) then
	setenv gtm_custom_errors $save_gtm_custom_errors
endif
$gtm_tst/com/dbcreate_base.csh mumps 2 -record_size=1024 -glob=65536
$MSR RUN INST2 "$gtm_tst/com/dbcreate_base.csh mumps 2 -record_size=512 -glob=65536"
$MSR START INST1 INST2
if (1 == $test_replic_suppl_type) then
	$MSR RUN INST2 '$gtm_exe/mumps -run sectrig^gtm7509'
else
	# To keep reference file consistent, redirect the output to files
	$MSR STOPRCV INST1 INST2 >&! stoprcv_inst1_inst2.out
	$MSR RUN INST2 'source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh '$0'; $MUPIP set -replic=off -reg "*"' >&! inst2_set_replic_off.out
	$MSR RUN INST2 '$gtm_exe/mumps -run sectrig^gtm7509'
	$MSR STARTRCV INST1 INST2 >&! startrcv_inst1_inst2.out
endif
$MSR SYNC INST1 INST2
$gtm_exe/mumps -run pritrig^gtm7509
# Create a trigger larger than the record size of the secondary.
# Primary would  chunk it to fit it's record size 1024. Though secondary record size is 512, it should work fine
$gtm_exe/mumps -run multiline^gtm7509 8191 127	# Generate a 1 MB file - 8K per M line
$MUPIP trigger -trig=multiline8191.trg
$MSR SYNC INST1 INST2
$gtm_exe/mumps -run updateSAMPLE^gtm7509
$MSR SYNC INST1 INST2
$MSR STOP INST1 INST2
$MSR RUN INST1 '$gtm_tst/$tst/u_inref/jnl_extract_detailed.csh' > inst1_extracted_jnl_data.log
$MSR RUN INST2 '$gtm_tst/$tst/u_inref/jnl_extract_detailed.csh' > inst2_extracted_jnl_data.log

echo "# ^SAMPLE and ^count in primary journal files"
$grep -E "/\^SAMPLE|/\^count" inst1_extracted_jnl_data.log
echo "# ^SAMPLE and ^count in secondary journal files"
$grep -E "/\^SAMPLE|/\^count" inst2_extracted_jnl_data.log

echo "# Test LGTRIG record gets generated and replicated without issues for maximum multi-line trigger size"
echo "# TLGTRIG record in primary extract"
$tst_awk '/TLGTRIG."..MULTILINE.8191,127./ {printf "Length of the record %s is : %d\n",$1,length($0)}' inst1_extracted_jnl_data.log
echo "# TLGTRIG record in secondary extract"
$tst_awk '/TLGTRIG."..MULTILINE.8191,127./ {printf "Length of the record %s is : %d\n",$1,length($0)}' inst2_extracted_jnl_data.log

$MUPIP trigger -select INST1.trg
$MSR RUN INST2 '$MUPIP trigger -select INST2.trg'
$MSR RUN SRC=INST1 RCV=INST2 '$gtm_tst/com/cp_remote_file.csh _REMOTEINFO___RCV_DIR__/INST2.trg __SRC_DIR__/'
echo "# diff trigger extracts from INST1 and INST2. Expect only SAMPLE related diff"
echo "# MULTILINE trigger should be the same and not show up in the diff below"
diff INST1.trg INST2.trg
# Both the database and the trigger definitions will be different on primary and secondary - do not do -extract
$gtm_tst/com/dbcheck.csh
