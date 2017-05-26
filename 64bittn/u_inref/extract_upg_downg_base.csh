#!/usr/local/bin/tcsh -f

#This procedure initially ran with the smallest extension size=1 in order to ensure the database is 100% packed with data.
#But we ended up overflowing the system logs, so after months of testing we decided to remove the exten=1 condition for the DB
#if in future we need this particular attribute again to test things out, this is the place to add.
#
# The test loads an earlier version extract into new version. Because of random gtm_chset modes if utf8 is chosen then load will error out
# because of chset mode incompatibility.
# So make this test always run under "M" mode
# save the old chset value and restore it at the end for the other subtests to continue with the random choice.
if ($?gtm_chset) then
	set gtm_chset_saved=$gtm_chset
endif
$switch_chset "M" >&! switch_chset1.out
$sv4
echo "The GTM version is switched to $v4ver"
echo ""
# priorver.txt is to filter the old version names in the reference file
echo $v4ver >& priorver.txt
source $gtm_tst/$tst/u_inref/v4dat.csh
echo "MUPIP extract -format=zwr v4.zwr"
$MUPIP extract -format=zwr v4.zwr >&! v4extract_zwr.log
echo "MUPIP extract -format=binary v4.bin"
echo ""
$MUPIP extract -format=binary v4.bin >&! v4extract_bin.log
mkdir v4
\mv *.dat *.gld v4
$sv5
echo "The GTM version is switched to V5"
echo ""
$gtm_tst/com/dbcreate.csh -record_size=496 -block_size=512
\cp mumps.dat bak.dat
echo "MUPIP load v4.zwr"
$MUPIP load v4.zwr
$gtm_tst/com/dbcheck.csh
$gtm_exe/mumps -run verify^upgrdtst

\cp bak.dat mumps.dat
echo "MUPIP load -format=bin v4.bin"
$MUPIP load -format=bin v4.bin
$gtm_tst/com/dbcheck.csh
$gtm_exe/mumps -run verify^upgrdtst

echo "MUPIP extract -format=zwr v5.zwr"
$MUPIP extract -format=zwr v5.zwr >&! v5extract_zwr.log
echo "MUPIP extract -format=binary v5.bin"
$MUPIP extract -format=binary v5.bin >&! v5extract_bin.log

mkdir v5
\mv *.dat *.gld v5

# need to delete .o for 64bit flavors
\rm upgrdtst.o gengvn.o genstr.o >>&! /dev/null
$sv4
echo "The GTM version is switched to $v4ver"
echo ""
cat >&! v4.gde << gde_eof
change -segment DEFAULT -file=mumps.dat
change -region DEFAULT -record_size=496
change -segment DEFAULT -block_size=512
exit
gde_eof
$GDE_SAFE @v4.gde
$MUPIP create

echo "MUPIP load v5.zwr"
$MUPIP load v5.zwr 				#---> should load without any errors
echo "MUPIP load -format=bin v5.bin"
$MUPIP load -format=bin v5.bin >&! loadv5inv4.log			#---> should issue LDBINFMT error due to incompatible binary format (created by V5)
$grep -E "GTM-E-LDBINFMT" loadv5inv4.log >>& /dev/null
if ($status == 0) then
	echo "The expected error (LDBINFMT) was issued (V44 versions)"
else
	echo "TEST-E-ERROR. The expected error LDBINFMT not issued"
endif 
	$tst_gzip loadv5inv4.log
endif
$gtm_tst/com/dbcheck.csh
$gtm_exe/mumps -run verify^upgrdtst
# switch/restore gtm_chset value here
if ($?gtm_chset_saved) then
	$switch_chset $gtm_chset_saved >&! switch_chset2.out
else
	# this means gtm_chset was left undefined at the beginning and so restore it similarly
	$switch_chset >&! switch_chset2.out
endif
#
