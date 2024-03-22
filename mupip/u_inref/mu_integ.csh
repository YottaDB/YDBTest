#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2002, 2014 Fidelity Information Services, Inc	#
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
setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode due to differences in MUPIP INTEG and DSE DUMP -FILEHEADER output

if ($?test_replic) then
	# With -replic, if "ydb_test_4g_db_blks" env var is set, dbcreate_multi.awk would pass "-nostats" for the region
	# which would cause the output to be different and make for a complicated reference file (due to "DB shares gvstats"
	# output in "dse dump -file" differing for various conditions). Therefore disable this env var in that case.
	setenv ydb_test_4g_db_blks 0
endif
#
######################################
# mu_integ.csh  test for mupip integ #
######################################
#

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
#
if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	set colno = 0
	if ($?test_collation_no) then
		set colno = $test_collation_no
	endif
	# Only one case (out of 4) below does real updates, useful enough to span regions.
	# Use use_test_specific_gde for that dbcreate and leave alone the others
	setenv use_test_specific_gde $gtm_tst/$tst/inref/mu_integ_col${colno}.sprgde
endif
setenv gtm_test_spanreg 0	# We have already pointed a spanning gld to test_specific_gde
echo MUPIP INTEG
#
#
@ corecnt = 1
#
###############################################
# Verifies the flag -notransaction and -nomax #
###############################################
#
if ($LFE != "L") then
setenv gtmgbldir integneg.gld
# the output of this test relies on dse dump -file output, therefore let's not change the block version:
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	$gtm_tst/com/dbcreate.csh integneg 1 128 256 1024 300 256
else
	$gtm_tst/com/dbcreate.csh integneg 1 128 256 1024 100 256
endif
$GTM << EOF
s sub=""
f i=0:1:100  s sub=sub_"a"
f i=0:1:1000  s ^a(sub_i)=sub_i
h
EOF
$DSE << EOF
ch -f -curr=1
ch -f -key=64
exit
EOF
$MUPIP integ -reg "*" >&! neg1.logs
$MUPIP integ -notransaction -reg "*" >&! neg2.logs
$MUPIP integ -nomax -reg "*" >&! neg3.logs
$MUPIP integ -nomax -notransaction -reg "*" >&! neg4.logs
foreach file (neg?.logs)
	@ $file:r1 = `$grep transaction $file | $grep too | wc | $tst_awk '{print $1}'`
	@ $file:r2 = `$grep larger $file | wc | $tst_awk '{print $1}'`
end
#
echo ""
if (($neg11 == 10) || ($neg12 == 10)) then
	echo PASS from no neg flag
else
	echo FAIL from no neg flag
	echo No. of transaction error is $neg11, should be 10 here.
	echo No. of maxkeysize error is $neg12, should be 10 here.
endif
if (($neg21 > 10) && ($neg22 == 10)) then
	echo PASS from '-notransaction'
else
	echo FAIL from '-notransaction'
	echo No. of transaction error is $neg21, should be bigger than 10 here.
	echo No. of maxkeysize error is $neg22, should be 10 here.
endif
if (($neg31 == 10) && ($neg32 > 10)) then
	echo PASS from '-nomax'
else
	echo FAIL from '-nomax'
	echo No. of transaction error is $neg31, should be 10 here.
	echo No. of maxkeysize error is $neg32, should be bigger than 10 here.
endif
if (($neg41 > 10) && ($neg42 > 10)) then
	echo PASS from '-nomax -transaction'
else
	echo FAIL from '-nomax -transaction'
	echo No. of transaction error is $neg41, should be bigger than 10 here.
	echo No. of maxkeysize error is $neg42, should be bigger than 10 here.
endif
#
$DSE << EOF
ch -f -curr=3EC
ch -f -key=128
exit
EOF
#
#
$gtm_tst/com/dbcheck.csh
#
# this endif is corresponding to if $LFE != L
endif
#
#
###########################
# multi-region + wildcard #
###########################
#
#
setenv gtmgbldir "integ.gld"
if ($?use_test_specific_gde) then
	setenv test_specific_gde $use_test_specific_gde
endif
$gtm_tst/com/dbcreate.csh integ 4 128 256 1024 100 256
unsetenv test_specific_gde
#
#
$GTM << EOF
d fill7^myfill("set")
h
EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "in" "$corecnt"
#
#Region Name in Mixed cases should be accepted
$GTM << cccc >& integAregBreg.out
zsy "$MUPIP integ -region areg,Breg |& sort"
h
cccc
source $gtm_tst/$tst/u_inref/check_core_file.csh "bk" "$corecnt"
$grep "Integ of region" integAregBreg.out
echo "#"
echo "# Integ with a bad region"
echo "#"
$MUPIP integ -region FREELUNCH
#
source $gtm_tst/$tst/u_inref/check_core_file.csh "bk" "$corecnt"
#
# integ region freeze -- to be added later
@ result = 0
echo PASS from mupip integ region freeze.
#
#
echo '$MUPIP integ -region "*" -subscript="^a"'
$MUPIP integ -region "*" -subscript="^a" |& $grep "error"
if ($status > 0) then
    echo ERROR from $MUPIP integ region asterisk subscript.
    exit 5
endif
echo '$MUPIP integ -region "*" -subscript="^a":"^c"'
$MUPIP integ -region "*" -subscript="^a":"^c" |& $grep "error"
if ($status > 0) then
    echo ERROR from $MUPIP integ region asterisk subscript adjacency.
    exit 6
endif
#
#
$gtm_tst/com/dbcheck.csh
#
#
echo '$MUPIP integ -file a.dat -tn_reset'
$MUPIP integ -file a.dat -tn_reset
if ($status > 0) then
    echo ERROR from $MUPIP integ file a.dat tnreset.
    exit 7
endif
$DSE << EOF
f -r=AREG
d -f
exit
EOF
#
#
echo '$MUPIP integ integ.dat'
$MUPIP integ integ.dat
if ($status > 0) then
    echo ERROR from $MUPIP integ default to file integ.dat.
    exit 2
endif
echo '$MUPIP integ -brief -fast -file a.dat'
$MUPIP integ -brief -fast -file a.dat
if ($status > 0) then
    echo ERROR from $MUPIP integ brieg fast file a.dat.
    exit 3
endif
echo '$MUPIP integ -full -file b.dat'
$MUPIP integ -full -file b.dat
if ($status > 0) then
    echo ERROR from $MUPIP integ full file integb.dat.
    exit 4
endif
#
#
echo '$MUPIP integ -file a.dat -nokeyranges -adjacency=50'
$MUPIP integ -file a.dat -nokeyranges -adjacency=50
if ($status > 0) then
    echo ERROR from $MUPIP integ file nokeyrange.
    exit 8
endif
echo '$MUPIP integ -map=20 -maxkeysize=20 -transaction=5 a.dat'
$MUPIP integ -map=20 -maxkeysize=20 -transaction=5 a.dat
if ($status > 0) then
    echo ERROR from $MUPIP integ map maxkeysize transaction default to file a.
    exit 9
endif
echo "# The below command used to previously be equivalent to $MUPIP integ -reg DEFAULT but not after YDB#851"
echo "# We now expect a MUNODBNAME error because -region was not specified"
echo 'echo DEFAULT | $MUPIP integ -online'
echo DEFAULT | $MUPIP integ -online
if ($status == 0) then
	echo 'Exit status was 0. Expecting a non-zero exit status'
	exit 9
endif
#
#
$GTM << EOF
d fill7^myfill("ver")
h
EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "in" "$corecnt"
$gtm_tst/$tst/u_inref/blk_tn.csh
#
if ($?test_replic) exit
# this part does not have to be replicated
# Testing that mupip integ goes on to the next region if one cannot be read or does not exist
$gtm_tst/com/dbcreate.csh . 4
rm b.dat
$MUPIP integ -reg "*" >&! mupip_integ_rm.out
$grep -E "error|-E|-I" mupip_integ_rm.out |& sort -f


$gtm_tst/com/dbcreate.csh . 4
chmod 000 b.dat
$MUPIP integ -reg "*" >&! mupip_integ_chmod.out
$grep -E "error|-E|-W|-I" mupip_integ_chmod.out |& sort -f
chmod 664 b.dat
#

#
#######################
# END of mu_integ.csh #
#######################
