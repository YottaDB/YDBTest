#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

cp $gtm_pct/v5cbsu.m .
@ testno = 0
alias db_save_and_reset '@ testno++ ; mv mumps.dat mumps.dat.${testno} ; cp backup.dat mumps.dat'

#switching to a random V4 version
$sv4
echo "GTM version is switched to $v4ver"
# priorver.txt is to filter the old version names in the reference file
echo $v4ver >& priorver.txt
$gtm_tst/com/dbcreate.csh -block_size=512 -record_size=504
cp mumps.dat backup.dat

# ---------------------------------------------------------------------------------------------------------------------
# Check that DBCREC2BIG is not falsely issued by DBCERTIFY SCAN if record length is EQUAL TO the max-record-length
echo "--------------------------------------------------------------------------------------------------------------------- "
echo "Test #1"
echo "--------"
db_save_and_reset
$gtm_exe/mumps -run mkdb1^d002556
$DSE change -file -reserved_bytes=8
$DSE change -file -rec=496
$DBCERTIFY scan DEFAULT
$gtm_exe/mumps -run v5cbsu mumps.dat.dbcertscan
$DBCERTIFY scan DEFAULT
echo "yes" | $DBCERTIFY certify mumps.dat.dbcertscan
$DBCERTIFY scan DEFAULT
source $gtm_tst/com/dbcheck.csh >&! dbcheck_1.log
$tst_awk -f $gtm_tst/$tst/inref/filter_64bittn.awk dbcheck_1.log

# --------------------------------------------------------------------------------------------------------------------- "
# Test that DBCERTIFY SCAN checks ALL records (uncompressed) within a block for potential DBCREC2BIG errors."
# This is because a record in its compressed form might not be too-large but in uncompressed form (possible if"
# dbcertify certify block split occurs at the record's offset) it might be too-large to fit in a V5 block."
# This test case is to check that out."
echo "--------------------------------------------------------------------------------------------------------------------- "
echo "Test #2"
echo "--------"
db_save_and_reset
$gtm_exe/mumps -run mkdb2^d002556
$DSE change -file -reserved_bytes=8
$DSE change -file -rec=496
$DBCERTIFY scan DEFAULT
source $gtm_tst/com/dbcheck.csh >&! dbcheck_2.log
$tst_awk -f $gtm_tst/$tst/inref/filter_64bittn.awk dbcheck_2.log

# --------------------------------------------------------------------------------------------------------------------- "
# Test that DBCERTIFY SCAN records the proper split point for V5CBSU to then do the data block split."
# What was happening was that DBCERTIFY SCAN was recording the FIRST key when actually it was possible that "
# a block split that takes the first key to a newly created left sibling block can still result in a too-full"
# right sibling block. This is why DBCERTIFY SCAN was later fixed to note down the SECOND key wherever we have"
# such a key in the block. This way we are guaranteed there will never be a case of too-full right sibling block."
echo "--------------------------------------------------------------------------------------------------------------------- "
echo "Test #3"
echo "--------"
db_save_and_reset
$gtm_exe/mumps -run mkdb3^d002556
$DSE change -file -reserved_bytes=8
$DSE change -file -rec=496
$DBCERTIFY scan DEFAULT
$gtm_exe/mumps -run v5cbsu mumps.dat.dbcertscan
$DBCERTIFY scan DEFAULT
source $gtm_tst/com/dbcheck.csh >&! dbcheck_3.log
$tst_awk -f $gtm_tst/$tst/inref/filter_64bittn.awk dbcheck_3.log

# --------------------------------------------------------------------------------------------------------------------- "
# Test that DBCERTIFY CERTIFY chooses the proper split point in a too-full block."
# In a test case, a too-full block had 3 records where the 1st record had no data but it had a long key that"
# was almost the same as the 2nd record. The 2nd and 3rd record had data which made them almost half the size"
# of the database block. Given this configuration, DBCERTIFY CERTIFY chose the first record as the split point"
# because the 2nd record straddles the midpoint of the block. But splitting at that point will cause the 1st"
# record to move into the left sibling block and the right sibling block ended up still too-full. This is incorrect."
# DBCERTIFY CERTIFY was fixed to choose the 2nd record as the split point in that case. This is a test to check that."
echo "--------------------------------------------------------------------------------------------------------------------- "
echo "Test #4"
echo "--------"
db_save_and_reset
$gtm_exe/mumps -run mkdb4^d002556
$DSE change -file -reserved_bytes=8
$DSE change -file -rec=496
$DBCERTIFY scan DEFAULT
echo "yes" | $DBCERTIFY certify mumps.dat.dbcertscan
$DBCERTIFY scan DEFAULT
source $gtm_tst/com/dbcheck.csh >&! dbcheck_4.log
$tst_awk -f $gtm_tst/$tst/inref/filter_64bittn.awk dbcheck_4.log

