#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2005, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TEST MUPIP-REORG UPGRADE DOWNGRADE feature of GT.M
# The test is divided into 9 sections as per the test plan,first section is taken care in disallow test
#
# priorver.txt is to filter the old version names in the reference file
echo $v4ver >& priorver.txt
# yes.txt to be used for user prompts in certification/upgrades.
cp $gtm_tst/$tst/inref/yes.txt .
# This test uses databases that are not fully upgraded and runs dbcheck. If gtm_test_online_integ is set to
# "-online" then SSV4NOALLOW will be issued. So, we better turn off online integ for the dbchecks done as
# a part of this test.
setenv gtm_test_online_integ ""

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
#
##########################################################################################
# Sections 1 to 5 which are the random sections of the sub-test are moved
# to another base script and the output filtered to avoid reference file issues.
$gtm_tst/$tst/u_inref/mu_reorg_upgrd_dwngrd_base.csh >>&! mu_reorg_upgrd_dwngrd_base.log
$tst_awk -f $gtm_tst/$tst/inref/filter_64bittn.awk mu_reorg_upgrd_dwngrd_base.log
################################### Section 6 ############################################
echo ""
echo "Begin Section 6"
echo ""
# switch to a v4 version
$sv4
echo "GT.M switched to $v4ver version"
$gtm_tst/com/dbcreate.csh mumps 2
$DSE << \dse_eof
change -file -reserved_bytes=8
find -region=DEFAULT
change -file -reserved_bytes=8
quit
\dse_eof
$GTM << \gtm_eof
set ^a=1,^b=1
halt
\gtm_eof
foreach region ("DEFAULT"  "AREG")
	$DBCERTIFY scan -outfile=dbcertify_$region.scan $region
	if ($status) then
        	echo "TEST-E-ERROR dbcertify scan phase failed for $region"
	endif
	$DBCERTIFY certify dbcertify_$region.scan < yes.txt >>&! dbcertify_$region.out
	if ($status) then
		echo "TEST-E-ERROR dbcertify.certify phase failed for $region region"
	else
		$grep "DBCDBCERTIFIED" dbcertify_$region.out
	endif
end
$MUPIPV5 upgrade mumps.dat < yes.txt
set stat1=$status
$MUPIPV5 upgrade a.dat < yes.txt
set stat2=$status
if ($stat1 || $stat2) then
        echo "TEST-E-ERROR.mupip upgrade failed"
endif
# switch back to V5
$sv5
$GDE exit
$MUPIP reorg -upgrade -region AREG
echo "blks_to_upgarde value should be zero in AREG"
$DSE dump -fileheader
echo "blks_to_upgarde value should be untouched in DEFAULT"
$DSE << dse_eof
find -region=DEFAULT
dump -fileheader
quit
dse_eof
$gtm_tst/com/dbcheck.csh
# confirm globals reside in proper database using extract_database utility.
$gtm_tst/com/extract_database.csh a >&! /dev/null
$gtm_tst/com/extract_database.csh mumps >&! /dev/null
if ( (`$grep '\^a="1"' a_extract.glo|wc -l`) && (`$grep '\^b="1"' mumps_extract.glo|wc -l`) ) then
	echo "Correct mapping for globals"
else
	echo "TEST-E-ERROR. Globals  mapping incorrect"
endif
################################### Section 7 ############################################
echo ""
echo "Begin Section 7"
echo ""
rm -f mumps.dat mumps.gld
$gtm_tst/com/dbcreate.csh mumps
$MUPIP set -version=V4 -file mumps.dat
$MUPIP reorg -upgrade -region DEFAULT
# check db format to  be v5 here
if ( "V6" != `$DSE dump -fileheader|& $tst_awk ' / Desired DB Format / {print $8}'`) then
	echo "TEST-E-ERROR DB FORMAT expected as V6 but not to be"
	dse dump -f
else
	echo "Desired DB format is V6.PASS"
endif
$MUPIP set -version=V6 -file mumps.dat
$MUPIP reorg -downgrade -region DEFAULT
# check db format to  be v4 here
if ( "V4" != `$DSE dump -fileheader|& $tst_awk ' / Desired DB Format / {print $8}'`) then
	echo "TEST-E-ERROR DB FORMAT expected as V4 but not to be"
	dse dump -f
else
	echo "Desired DB format is V6.PASS"
endif
################################### Section 8 ############################################
echo ""
echo "Begin Section 8"
echo ""
rm -f mumps.dat mumps.gld
$gtm_tst/com/dbcreate.csh mumps
# change current transaction valueto 4G - 128M -50
set value="F7FFFFCE"
set value_dec=`expr 4160749518 + 50`
$DSE  change -file -curr=$value
# do 40 no-TP updates and ensure each transaction updates one unique block
$GTM << \gtm_eof
set str="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMN"
for i=1:1:40 set x="^"_$E(str,i) s @x="non TP"
halt
\gtm_eof
# ensure curr_tn < 4G - 128M
set curr_tn=`$DSE dump -file|& $grep "Current transaction"|$tst_awk '{print $3}'|cut -c3-`
set curr_tn_dec=`$DSE eval -h -n=$curr_tn|& $grep "Dec: "|$tst_awk -F":" '{print $3}'`
if ( $curr_tn_dec < $value_dec) then
	echo "Correct Transaction number after non-tp updates"
else
	echo "TEST-E-ERROR. curr_tn is NOT < 4G - 128M"
endif
# ensure 40 different blocks getting updated
# for this we make use of block=0 information where a mark of "X" indicates the bit to be busy
# in dse dump
set blk_upd_cnt=`$DSE dump -block=0 | & $grep "|  X" | $tst_awk -F"|" '{print $2}' | sed 's/ *//g' | sed 's/\t*//g' | sed 's/\.//g'|wc -c`
# 43 is checked against because when we create an empty DB there is always the first 3 blocks marked as busy
# so it should be > than 40+3 here
if ( 43 > $blk_upd_cnt ) then
	echo "TEST-E-ERROR desired 40 Blocks not updated"
else
	echo "PASS.40 blocks updated"
endif
echo "TNTOOLARGE error expected here on reorg -downgrade"
$MUPIP reorg -downgrade -region DEFAULT
# check db format to  be V4 here
if ( "V4" != `$DSE dump -fileheader|& $tst_awk ' / Desired DB Format / {print $8}'`) then
	echo "TEST-E-ERROR DB FORMAT expected as V4 but not to be"
	dse dump -f
else
	echo "Desired DB format is V4.PASS"
endif
# check blks_to_upgrade NOT EQUAL to tot-free blks
source $gtm_tst/com/get_blks_to_upgrade.csh "nocheck" "default"
if( $calculated == `$DSE dump -fileheader|& $grep "blks_to_upgrade"|$tst_awk '{print $3}'|cut -c3-`) then
	echo "TEST-E-ERROR. blks_to_upgrade incorrect "
else
	echo "blks_to_upgrade correct at this stage"
endif
$MUPIP integ -TN_RESET mumps.dat
if ($status) then
	echo "TEST-E-ERROR. MUPIP TN_RESET errors"
endif
# check db format to  be V4 here
if ( "V4" != `$DSE dump -fileheader|& $tst_awk ' / Desired DB Format / {print $8}'`) then
	echo "TEST-E-ERROR DB FORMAT expected as V4 but not to be"
	dse dump -f
else
	echo "Desired DB format is V4.PASS"
endif
source $gtm_tst/com/get_blks_to_upgrade.csh "check" "default"
# check some non-TP updates done before still exists
$MUPIP extract db_extract.glo >&! /dev/null
if ( 40 != `$grep "\^.*=" db_extract.glo|wc -l`) then
	echo "TEST-E-ERROR. NON-TP updates missing"
endif
$gtm_tst/com/dbcheck.csh
################################### Section 9 ############################################
echo ""
echo "Begin Section 9"
echo ""
rm -f *.dat *.gld *.o
$sv4
echo "GT.M switched to $v4ver version"
#  create a database with record size=1000 block size=1024
$gtm_tst/com/dbcreate.csh mumps 1 125 1000 1024
$DSE change -file -reserved_bytes=8
# the set below ensures we have atleast 10 data blocks updated
$GTM << \gtm_eof
for i=1:1:10 set ^x(i)=$justify(i,800)
halt
\gtm_eof
$DBCERTIFY scan -outfile=dbcertify_report2.scan DEFAULT
$DBCERTIFY certify dbcertify_report2.scan < yes.txt >>&! dbcertify_report2.out
if ($status) then
	echo "TEST-E-ERROR dbcertify.certify phase failed"
else
	$grep "DBCDBCERTIFIED" dbcertify_report2.out
endif
$MUPIPV5 upgrade mumps.dat < yes.txt
if ($status) then
        echo "TEST-E-ERROR.mupip upgrade failed"
endif
$sv5
$GDE exit
# this creates BLKTNTOOLG integrity error
$DSE change -block=8 -tn=100
# this creates a DBINVGBL integrity error
$DSE add -block=9 -rec=2 -key="^B(2)" -data="1"
$MUPIP reorg -upgrade -region DEFAULT >>&! blk_lng_reorg.out
if ( `$grep -E "DBINVGBL|BLKTNTOOLG" blk_lng_reorg.out|wc -l`) then
	echo "TEST-E-ERROR. BLKTNTOOLG or DBINVGBL error not expected here"
else
	cat blk_lng_reorg.out
endif
$DSE dump -block=8 -header
# check db format to  be v5 here
if ( "V6" != `$DSE dump -fileheader|& $tst_awk ' / Desired DB Format / {print $8}'`) then
	echo "TEST-E-ERROR DB FORMAT expected as V6 but not to be"
	dse dump -f
else
	echo "Desired DB format is V6.PASS"
endif
$DSE dump -block=9 -header
# check db format to  be v5 here
if ( "V6" != `$DSE dump -fileheader|& $tst_awk ' / Desired DB Format / {print $8}'`) then
	echo "TEST-E-ERROR DB FORMAT expected as V6 but not to be"
	dse dump -f
else
	echo "Desired DB format is V6.PASS"
endif
#
source $gtm_tst/com/get_blks_to_upgrade.csh "check" 0
#
$DSE change -block=8 -tn=1000
$MUPIP reorg -downgrade -reg DEFAULT
if ($status) then
	echo "TEST-E-ERROR. reorg downgrade failed"
endif
$DSE dump -block=8 -header
if ( "V4" != `$DSE dump -fileheader|& $tst_awk ' / Desired DB Format / {print $8}'`) then
	echo "TEST-E-ERROR DB FORMAT expected as V4 but not to be"
	dse dump -f
else
	echo "Desired DB format is V4.PASS"
endif
#
$DSE dump -block=9 -header
if ( "V4" != `$DSE dump -fileheader|& $tst_awk ' / Desired DB Format / {print $8}'`) then
	echo "TEST-E-ERROR DB FORMAT expected as V4 but not to be"
	dse dump -f
else
	echo "Desired DB format is V4.PASS"
endif
#
source $gtm_tst/com/get_blks_to_upgrade.csh "check" "default"
#
