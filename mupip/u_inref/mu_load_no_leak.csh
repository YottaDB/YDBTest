#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2011, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
###################################################################################################
### mu_load_no_leak.csh  verify that if mupip is unable to get db shm, it does not leak memory  ###
###################################################################################################
#
# Our extracts are in M (and will not actually be used anyway so stay in M mode)
unsetenv gtm_chset
# Go with dbg image since we are using a whitebox test
source $gtm_tst/com/switch_gtm_version.csh $tst_ver "dbg"
#
echo "Create database"
#
$gtm_tst/com/dbcreate.csh mumps 1
#
echo "Use white box test case 44 to prevent mupip from getting database shared memory"
#
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 44
setenv gtm_white_box_test_case_count 1

echo "Set gtmdbglvl to 2 so that we get a summary of our heap activity"
setenv gtmdbglvl 2
#
echo "Load 10 nodes into the database (all will fail)"
$MUPIP load $gtm_tst/$tst/u_inref/ext10.txt >& ext10.outx
set ext10size=`$grep allocated ext10.outx| cut -d: -f 2 | cut -d, -f1 | cut -d" " -f2`
echo "ext10size=$ext10size" >>! sizes.txt
echo "Load 2000 nodes into the database (all will fail)"
$MUPIP load $gtm_tst/$tst/u_inref/ext2000.txt >& ext2000.outx
set ext2000size=`$grep allocated ext2000.outx | cut -d: -f 2 | cut -d, -f1 | cut -d" " -f2`
echo "ext2000size=$ext2000size" >>! sizes.txt

echo "Allocated memory size should match if we did not leak memory."

# In case of spanning regions, it is possible due to random sprgde files the memory size wont exactly match
# but should still be almost the same. Allow for .1 % discrepancy.
set noleak1 = `echo "if ($ext10size <= $ext2000size) 1" | bc`
set noleak2 = `echo "if ($ext10size * 1.001 >= $ext2000size) 1" | bc`

if ((1 == "$noleak1") && (1 == "$noleak2")) then
	echo "NO LEAK"
else
	echo "LEAK"
endif
#
echo "Turn off white box case before doing the dbcheck to make sure no database issues"
unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number
unsetenv gtm_white_box_test_case_count
unsetenv gtmdbglvl # To prevent heap activity summary from dbcheck activities

$gtm_tst/com/dbcheck.csh
#
