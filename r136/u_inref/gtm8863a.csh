#################################################################
#								#
# Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# gtm8863a - This test verifies that 3 yottadb file-header fields were moved correctly when
#            merging GTM8863. We will give the fields a value in r1.34, then update the file
#            to r1.36 and verify those fields as reported by DSE DUMP -FILEHEADER are correct.
#            The fields we care about in cs_data are: max_procs.cnt, max_procs.time and
#	     reorg_sleep_nsec.
setenv gtm_db_counter_sem_incr ''  # Don't potentially leave orphaned IPCs if 16384 is picked as this
                                   # causes problems when switching versions.
setenv gtm_test_use_V6_DBs 0	   # Prevent version switch in dbcreate.csh that confuses
       				   # .. version switching that follows
echo '# Test to verify 3 fields in DSE file header dump are same in r1.34 and r1.36 (or later version) to'
echo '# make sure the fields are being upgraded (moved inside the header) properly by autoupgrade.'
echo
echo '# Un-setting $gtm_db_counter_sem_incr - reasoning is this envvar has random values chosen and when'
echo '# those values meet or exceed 16384, this causes a rundown situation such that the IPCs for the open'
echo '# DB are orphaned and left in place. If we then switch versions, YottaDB thinks the DB is open with'
echo '# a different version and reports the VERMISMATCH error. Not leaving IPCs orphaned is what we need'
echo '# so unsetenv gtm_db_counter_sem_incr'
unsetenv gtm_db_counter_sem_incr
echo
echo '# Setting runversion to YottaDB r1.34'
set prev_ver = "V63011_R134"
source $gtm_tst/com/switch_gtm_version.csh $prev_ver $tst_image
echo
echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate_r134.log
echo
echo '# Set max_procs.time to the current time and bump max_procs.cnt by getting two processes accessing DB'
$gtm_dist/mumps -run setconcproc^gtm8863a
echo
echo '# Set the "Reorg Sleep Nanoseconds" field to 42244224'
$gtm_dist/mupip set -file mumps.dat -reorg_sleep_nsec=42244224
echo
echo '# Get fileheader dump from this r1.34 DB'
$gtm_dist/dse dump -fileheader >& fhead_${prev_ver}.txt
echo
echo "# Now switch back to our main test version ($tst_ver) - need to run GDE EXIT to reformat the gld"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
$gtm_dist/mumps -run GDE exit               # Reformat the global directory for post r1.34 GLD version
#
# Note, the below command is not strictly needed but this test chooses to do the header upgrade in this
# step and then the header dump as a subsequent step instead of just allowing DSE to both upgrade the
# DB and dump the upgraded file-header.
#
$gtm_dist/mumps -run ^%XCMD 'set ^done=1'   # Drive simple command to reformat the DB by opening it
echo
echo "# Grab file header dump using $tst_ver"
$gtm_dist/dse dump -fileheader >& fhead_${tst_ver}.txt
echo
echo '# Compare the two fileheader dumps noting any discrepancies in the 3 values we are looking at'
$gtm_dist/mumps -run verifyDumps^gtm8863a fhead_${prev_ver}.txt fhead_${tst_ver}.txt
echo
echo '# Verify database'
$gtm_tst/com/dbcheck.csh
