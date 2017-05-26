#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# To test moving data between the default collation and the alternative Chinese collation.
#
# Test plan
#	This script verifies that data can be extracted from a default collated db
#	and loaded into a Chinese collated db. In the end, it is verified that:
#	- nothing gets lost
#	- data items are ordered correctly based on the collation sequence
#	Unique things in this test:
#	- use chn^mixfill to fill the db
#	- use check_chnm.csh to verify the data and collation order.
#	The flow of this test is described below. It is a common pattern in collation
#	test.
#	1. Create a database with one of the collation settings. (default in this subtest)
#	2. Fill some data into the database
#	3. Use ZWR to verify the data is in expected order
#		- by comparing to a pre-generated reference text file like
#			defm.txt, polm.txt and chnm.txt
#	4. Extract data out of the database.
#	5. Create a database with another collation setting. (chn in this subtest)
#	6. Load the previously extracted data
#	7. Use ZWR to verify that the data is in expected order
#	8. Verify that the no data is lost either.
#	Following is added to test kill does NOT mess up the collation.
#	9. Call mixfill with parameter "kill" to kill some data
#	10. Use check_chnm_afterkill.csh to verify that after the kill, we got data
#	    exactly as we expect.
#
$switch_chset "UTF-8"
source $gtm_tst/com/cre_coll_sl.csh chinese 1

# ========= debug section ===========
echo "DEBUG INFORMATION"
echo $gtm_local_collate
env | $grep gtm_collate_1
echo "DEBUG INFORMATION"
# ======== end of debug section =====

setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 2 255 2048 4096
$GTM << aaa
d s^mixfill
d s1^mixfill
h
aaa
$gtm_tst/com/dbcheck.csh -extr -nosprgde
if ($?test_replic) then
	$MUPIP journal -extract=jnl.ext -forward -detail mumps.mjl
endif
unsetenv test_replic
$gtm_tst/$tst/u_inref/check_chinese_defc.csh
#
echo "$MUPIP extract chinese.bin -format=bin"
$MUPIP extract -format=bin chinese.bin >&! mupip_extract_bin.out
if ($status) then
	echo "Extract failed"
	exit 1
endif
$grep -v '(region' mupip_extract_bin.out
# note: GLO format extract is not supported in UTF-8 mode
echo "$MUPIP extract -format=zwr chinese_defc.zwr"
$MUPIP extract -format=zwr chinese_defc.zwr >&! mupip_extract_zwr.out
if ($status) then
	echo "Extract failed"
	exit 1
endif
$grep -v '(region' mupip_extract_zwr.out
$gtm_tst/com/dbcheck.csh
#
# create a db with chinese collation, and load it from previous extract file
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 2 255 2048 4096 -col=1
echo "$MUPIP load -format=bin chinese.bin"
$MUPIP load -format=bin chinese.bin >&! mu_load_bin.out
if ($status) then
	echo "Load failed"
	exit 1
endif
$grep "LOAD TOTAL" mu_load_bin.out
$gtm_tst/$tst/u_inref/check_chinese_chnc.csh
echo "$MUPIP extract -format=zwr chinese_chnc.zwr"
$MUPIP extract -format=zwr chinese_chnc.zwr >&! mupip_extract_zwr_2.out
if ($status) then
	echo "Extract failed"
	exit 1
endif
$grep -v '(region' mupip_extract_zwr_2.out
#
# now kill some data with the the alternative collation sequence
$GTM << bbb
d ks^mixfill
d ks1^mixfill
h
bbb
$gtm_tst/$tst/u_inref/check_chinese_chnc_afterkill.csh
echo "$MUPIP extract chinese_afterkill.bin -format=bin"
$MUPIP extract -format=bin chinese_afterkill.bin >&! mupip_extract_bin_afterkill.out
if ($status) then
	echo "Extract failed"
	exit 1
endif
$grep -v '(region' mupip_extract_bin_afterkill.out
$gtm_tst/com/dbcheck.csh
#
# create a db with default collation, and load it from previous extract file
setenv gtm_test_sprgde_id "ID3"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 2 255 2048 4096
echo "$MUPIP load -format=bin chinese_afterkill.bin"
$MUPIP load -format=bin chinese_afterkill.bin >&! mupip_load_bin_afterkill.out
if ($status) then
	echo "Load failed"
	exit 1
endif
$grep "LOAD TOTAL" mupip_load_bin_afterkill.out
$gtm_tst/$tst/u_inref/check_chinese_defc_afterkill.csh
$gtm_tst/com/dbcheck.csh
echo DONE DONE DONE
