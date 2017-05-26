#!/usr/local/bin/tcsh -f
#
#########################################################################
# The test script uses a common utility called check_inctn_pblk.csh     #
# It is called to check the status of           			#
# INCTN & PBLK records after every MUPIP upgarde or downgrade command   #
# the script accepts a parameter which indicates the existence of       #
# INCTN,PBLK records to check						#
# The test script also utilizes get_blks_to_upgrade utility which checks#
# for blks2upgrd field being equal/not equal to a calculated value      #
#########################################################################
#
# set aliases for MUPIP REORG that will be used throughout the test
###################################################################
alias musj '$MUPIP reorg -upgrade -safejnl -region DEFAULT'
alias mdsj '$MUPIP reorg -downgrade -safejnl -region DEFAULT'
alias munsj '$MUPIP reorg -upgrade -nosafejnl -region DEFAULT'
alias mdnsj '$MUPIP reorg -downgrade -nosafejnl -region DEFAULT'
###################################################################
#
##### COMMON section to be used for the entire sub-test ###########
$sv4
echo "GT.M switched to $v4ver version"
# use the already prepared too-full blocks V4 database instead of calling dbcreate.csh
source $gtm_tst/$tst/u_inref/v4dat.csh
$MUPIP set -reserved_bytes=8 -reg DEFAULT
#scan phase
$DBCERTIFY scan -outfile=dbcertify_scanreport.scan DEFAULT
if ($status) then
        echo "TEST-E-ERROR. scan phase failed for $v4ver database"
endif
#certify phase
$DBCERTIFY certify dbcertify_scanreport.scan < yes.txt >>&! dbcertify_scanreport.out
if ($status) then
        echo "TEST-E-ERROR. certify phase failed for $v4ver database"
else
	$grep "DBCDBCERTIFIED" dbcertify_scanreport.out
endif
$MUPIPV5 upgrade mumps.dat < yes.txt
# save the datafile & ".gld" layout to be used throughout the test
cp mumps.dat mumps_v4.dat
cp mumps.gld mumps_v4.gld
############################# Section 2 ####################################
echo ""
echo "Begin Section 2"
echo ""
$sv5
$GDE exit
$MUPIP reorg -upgrade -region DEFAULT
if ($status) then
        echo "TEST-E-ERROR. Upgrade failed with region qualifier"
endif
# the script called checks for blk2upgrd value against zero
source $gtm_tst/com/get_blks_to_upgrade.csh "check" 0
#
$gtm_tst/com/dbcheck.csh
$GTM << gtm_eof
do verify^upgrdtst
halt
gtm_eof
$MUPIP reorg -downgrade -region DEFAULT
if ($status) then
        echo "TEST-E-ERROR. Downgrade failed with region qualifier"
endif
#
# the script is called to check blks2upgrd value against tot-free blocks from dse dump
source $gtm_tst/com/get_blks_to_upgrade.csh "check" "default"
#
$gtm_tst/com/dbcheck.csh
$GTM << gtm_eof
do verify^upgrdtst
halt
gtm_eof
# restore the earlier saved data file & ".gld" layout
cp mumps_v4.dat mumps.dat
cp mumps_v4.gld mumps.gld
$GDE exit
############################# Section 3 ####################################
echo ""
echo "Begin Section 3"
echo ""
if ("DISABLED" != `$DSE dump -fileheade|& $grep "Journal State"|$tst_awk '{print $3}'`) then
        echo "TEST-E-ERROR.Jounaling enabled at this point.Expected to be disabled"
endif
echo "upgrade with -safejnl should pass as journaling is turned off"
# reorg upgrade with safejnl
musj
source $gtm_tst/com/get_blks_to_upgrade.csh "check" 0
#
# reorg downgrade with safejnl
mdsj
#
source $gtm_tst/com/get_blks_to_upgrade.csh "check" "default"
$MUPIP set -journal="enable,on,nobefore" -region DEFAULT
$DSE dump -file|& $grep "Journal Before imaging"| $tst_awk '{if ("FALSE" ~ $8) print "No Before Image turned on";else print "TEST-E-ERROR.check journalling"}'
# reorg upgrade with safejnl
musj
#
source $gtm_tst/com/get_blks_to_upgrade.csh "check" 0
$gtm_tst/$tst/u_inref/check_inctn_pblk.csh "10"
# switch to a new journal file from now.
$MUPIP set -journal="on,nobefore" -region "*"
#
# reorg downgrade with safejnl
mdsj
#
source $gtm_tst/com/get_blks_to_upgrade.csh "check" "default"
#
# the script called checks for INCTN,PBLK record status.10 indicates yes for INCTN & no for PBLK
$gtm_tst/$tst/u_inref/check_inctn_pblk.csh "10"
#
$MUPIP set -journal="enable,on,before" -region "*"
# please keep this sleep as granularity for Journaling is in terms of seconds
sleep 1
$DSE dump -file|& $grep "Journal Before imaging"| $tst_awk '{if ("TRUE" == $8) print "Before Image turned on";else print "TEST-E-ERROR.check journalling"}'
set format="%d-%b-%Y %H:%M:%S"
set time1=`date +"$format"`
#
# reorg upgrade with safejnl
musj
#
source $gtm_tst/com/get_blks_to_upgrade.csh "check" 0
$gtm_tst/$tst/u_inref/check_inctn_pblk.csh "11"
#
# switch again to a new journal file
$MUPIP set -journal="enable,on,before" -region "*"
# reorg downgrade with safejnl
mdsj
#
source $gtm_tst/com/get_blks_to_upgrade.csh "check" "default"
$gtm_tst/$tst/u_inref/check_inctn_pblk.csh "11"
#
$MUPIP journal -recover -back -since=\"$time1\" mumps.mjl >>&! rec.log
set stat1=$status
$grep "Recover successful" rec.log
set stat2=$status
if ($stat1 != 0 || $stat2 != 0)  then
	echo "TEST-E-ERROR.Journaling Recovery ERROR"
	cat rec.log;rm -f rec.log
endif
$gtm_tst/com/dbcheck.csh
$GTM << gtm_eof
do verify^upgrdtst
halt
gtm_eof
cp mumps_v4.dat mumps.dat
cp mumps_v4.gld mumps.gld
$GDE exit
############################# Section 4 ####################################
echo ""
echo "Begin Section 4"
echo ""
rm -f mumps*.mjl*
# reorg upgrade with nosafejnl
munsj
if ($status) then
	echo "TEST-E-ERROR.reorg with nosafejnl & no journaling expected to pass but failed"
endif
source $gtm_tst/com/get_blks_to_upgrade.csh "check" 0
#
# reorg downgrade with nosafejnl
mdnsj
source $gtm_tst/com/get_blks_to_upgrade.csh "check" "default"
$MUPIP set -journal="enable,nobefore" -region "*"
munsj
source $gtm_tst/com/get_blks_to_upgrade.csh "check" 0
$gtm_tst/$tst/u_inref/check_inctn_pblk.csh "10"
# switch to a new journal file
$MUPIP set -journal="enable,nobefore" -region "*"
# reorg downgrade with nosafejnl
mdnsj
source $gtm_tst/com/get_blks_to_upgrade.csh "check" "default"
# PBLK should also not exist at this point since before image is not yet turned on
$gtm_tst/$tst/u_inref/check_inctn_pblk.csh "10"
$MUPIP set -journal="enable,on,before" -region "*"
# please keep this sleep as granularity for Journaling is in terms of seconds
sleep 1
set time2=`date +"$format"`
# reorg upgrade with nosafejnl
munsj
source $gtm_tst/com/get_blks_to_upgrade.csh "check" 0
$gtm_tst/$tst/u_inref/check_inctn_pblk.csh "10"
# switch to a new journal
$MUPIP set -journal="enable,before" -region "*"
# reorg downgrade with nosafejnl
mdnsj
source $gtm_tst/com/get_blks_to_upgrade.csh "check" "default"
$gtm_tst/$tst/u_inref/check_inctn_pblk.csh "10"
$MUPIP journal -recover -back -since=\"$time2\" mumps.mjl >>& rec.log
set stat1=$status
$grep "Recover successful" rec.log
set stat2=$status
if ($stat1 != 0 || $stat2 != 0)  then
        echo "TEST-E-ERROR.Journaling Recovery ERROR"
	cat rec.log
endif
$gtm_tst/com/dbcheck.csh
$GTM << gtm_eof
do verify^upgrdtst
halt
gtm_eof
#
cp mumps_v4.dat mumps.dat
cp mumps_v4.gld mumps.gld
$GDE exit
#
############################# Section 5 ####################################
echo ""
echo "Begin Section 5"
echo ""
rm -f mumps*.mjl*
$MUPIP set -journal="enable,before" -region "*"
$MUPIP reorg -upgrade -region "*"
#
source $gtm_tst/com/get_blks_to_upgrade.csh "check" 0
$gtm_tst/$tst/u_inref/check_inctn_pblk.csh "11"
# also check for AIMG records
if ( 0 != `$grep "AMIG" extr1.out|wc -l`) then
	echo "TEST-E-ERROR.AIMG records incorrect"
	cat mupip_show.out
endif
$gtm_tst/com/dbcheck.csh
$GTM << gtm_eof
do verify^upgrdtst
halt
gtm_eof
#
# from here the saved database & the .gld layout should not be used
rm -f mumps*
