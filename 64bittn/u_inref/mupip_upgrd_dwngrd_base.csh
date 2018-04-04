#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2005-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# alias to use v4 databases
alias restore 'cp -f mumps_v4.dat mumps.dat;cp -f mumps_v4.gld mumps.gld'
# alias for running a normal dbcertify operations
alias sc '$DBCERTIFY scan DEFAULT'
alias cc '$DBCERTIFY certify mumps.dat.dbcertscan < yes.txt'
###############################################################################################
# 					section 4 					      #
echo ""
echo "Begin Section 4"
echo ""
# dbcreate already called by mupip_upgrd_dwngrd.csh
\rm -f mumps.dat mumps.gld
# use the v4 db already created
restore
$MUPIP set -reserved_bytes=8 -reg DEFAULT
## run dbcertify scan
$DBCERTIFY scan -outfile=dbcertify_scanout.scan DEFAULT
echo "Attempting MUPIP UPGRADE without running dbcertify CERTIFY.Should issue MUUPGRDNRDY error"
$MUPIPV5 upgrade mumps.dat < yes.txt
## change forcefully using DSE the certified bit to V5
# since now the db is not upgraded we will not be able to use the certified bit field in dse dump
# instead using its offset(5112,hex-13F8) we can explicitly change the same
# hexloc is used to locate the field at a particular offset & hexvalue is to set it forcefully.
# this feature is not documented and hence NOT recommended to the customer,it is only for testing purposes.
$DSE change -file -hexloc=13F8 -size=4 -hexvalue=1
echo "Attempting MUPIP UPGRADE after explicit certify bit using DSE. Shoud PASS"
$MUPIPV5 upgrade mumps.dat < yes.txt
if ($status ) then
	echo "TEST-E-ERROR. MUPIP UPGRADE expected to PASS after setting the dbcertify bit.But failed"
endif
echo "Attempting MUPIP DOWNGRADE after the UPGRADE.Should PASS"
$MUPIPV5 downgrade mumps.dat < yes.txt
if ($status ) then
	echo "TEST-E-ERROR. MUPIP DOWNGRADE failed"
endif
## run dbcertify certify phase again to be used for the remainder of the test
$DBCERTIFY certify dbcertify_scanout.scan < yes.txt >>&! dbcertify_scanout.out
if ($status) then
	echo "TEST-E-ERROR.dbcertify failed"
else
	$grep "DBCDBCERTIFIED" dbcertify_scanout.out
endif
## check for "Certified for DB format" field from dse output
$DSE change -fileheader -hexloc=13F8 -size=4 | & $tst_awk ' /New Value / {print $8}' | $tst_awk '{if (1 !~ $0) print "TEST-E-ERROR.Certfied bit expected as 1 but got "$0""}'
#
$MUPIP set -reserved_bytes=0 -reg DEFAULT
# 504 is evaluated as block_size - 8
$DSE change -fileheader -record_max_size=504
# set too-big records
$GTM << EOF
do setbig^upgrdtst
halt
EOF
# 496 is evaluated as block_size - 16
$DSE change -fileheader -record_max_size=496
$MUPIP set -reserved_bytes=7 -reg DEFAULT
echo "Attempting MUPIP UPGRADE with less reserved bytes.Should issue DBMINRESBYTES error"
$MUPIPV5 upgrade mumps.dat < yes.txt
$MUPIP set -reserved_bytes=8 -reg DEFAULT
$DSE change -fileheader -record_max_size=497
echo "Attempting MUPIP UPGRADE with incorrect record size .Should issue DBMAXREC2BIG error"
$MUPIPV5 upgrade mumps.dat < yes.txt
$DSE change -fileheader -record_max_size=496
echo "Attempting MUPIP UPGRADE should PASS"
$MUPIPV5 upgrade mumps.dat < yes.txt
if ($status ) then
	echo "TEST-E-ERROR. MUPIP UPGRADE expected to PASS but failed"
endif
# check dse output, so from here switch to V5 version
# to do that we have to convert gld file to V5 format
$sv5
$GDE exit
cp mumps.gld mumps_v5.gld # purpose is to restore down the line
echo "check for reserved bytes reduced by 8 and zero counters in the DSE dump output"
$DSE dump -file | & $tst_awk '/Reserved Bytes/ {print $1" "$2" "$3}'
$DSE dump -file -all|& $grep -E "Retries|^  TP blkmod"
# Check that there is at least one line of GVSTATS information. Each such line has a ": # of" in it and is
# printed only if it is non-zero (starting from V5.3-003). For previous versions the dse dump output is different
# so the search operation would be different (see similar grep down below after mupip downgrade to V4).
# The exceptions are "DFL : # of Database FLushes" the C?? critical section counts which may be nonzero so exclude that.
if (`$DSE dump -file -all |& $grep " : # of " | grep -vE "^  (DFL|CAT|CFE|CFS|CFT|CQS|CQT|CYS|CYT) : " | wc -l` != 0 ) then
	echo "TEST-E-ERROR.counter expected to be zero"
endif
# get_blks_to_upgrade.csh is called to get the calculated value of total-free blocks &
# check it against the blks2upgrd field
source $gtm_tst/com/get_blks_to_upgrade.csh "check" "default"
#
echo "dbcheck should issue DYNUPGRDFAIL error here"
$gtm_tst/com/dbcheck.csh
$GTM << EOF
do setgood^upgrdtst
halt
EOF
if ( "dbg" != "$tst_image" ) then
echo "verification should issue DYNUPGRDFAIL error here,as too-big records were previously set"
$GTM << EOF
do vrfybig^upgrdtst
halt
EOF
endif
echo "Attempting MUPIP REORG UPGRADE with too big records. Should error out"
$MUPIP reorg -upgrade -reg DEFAULT >>&! reorg_toobig_up.out
$grep "YDB-E" reorg_toobig_up.out
if ($status) then
	echo "TEST-E-ERROR upgrade didn't issue expected too-big record error"
endif
echo "Attempting MUPIP REORG DOWNGRADE with too big records. Should run fine"
$MUPIP reorg -downgrade -reg DEFAULT>>&! reorg_toobig_down.out
cat reorg_toobig_down.out | $tail -n 10
if ($status) then
	echo "TEST-E-ERROR,MUPIP reorg downgrade failed"
else
	echo "MUPIP reorg downgrade PASS"
endif
echo "Attempting MUPIP DOWNGRADE. Should run fine"
$MUPIP downgrade mumps.dat < yes.txt
if ($status) then
	echo "TEST-E-ERROR,MUPIP downgrade failed"
endif
# need to delete .o for 64bit flavors
\rm upgrdtst.o gengvn.o >&! /dev/null
# switch to v4 to kill the too-big records set above
$sv4
# restore V4 gld
cp mumps_v4.gld mumps.gld
$GTM << EOF
write "Killing too-big records",!
do killbig^upgrdtst
halt
EOF
# since we just did a successful downgrade , attemtping an upgrade now would need a dbcertify phase here.
# scan
sc
# certify
cc >>&! cert.out
$grep "DBCDBCERTIFIED" cert.out
# switch back to v5 to continue tests
$sv5
# restore V5 gld
cp mumps_v5.gld mumps.gld
$MUPIP upgrade mumps.dat < yes.txt
if ($status ) then
	echo "TEST-E-ERROR. MUPIP UPGRADE expected to PASS after killing big-records.But failed"
endif
$GTM << EOF
write "Running verify",!
do verify^upgrdtst
write "Running verify big",!
do vrfybig^upgrdtst
halt
EOF
# need to delete .o for 64bit flavors
\rm upgrdtst.o gengvn.o >&! /dev/null
# switch again to a V4 version to check error on verification
$sv4
cp mumps_v4.gld mumps.gld
#
echo "verification error expected since database is upgraded to V5 but the version now is V4"
$GTM << EOF
do verify^upgrdtst
halt
EOF
# switch back to V5 to continue the tests
$sv5
# restore V5 gld
cp mumps_v5.gld mumps.gld
# start running onlnread.m concurrently
$MUPIP set -version=V4 -file mumps.dat
($gtm_exe/mumps -run ^onlnread < /dev/null >>& onlnread_mupip2.out&) >&! bg2.out
$gtm_tst/$tst/u_inref/wait_for_onlnread_to_start.csh 60
echo "Attempting MUPIP DOWNGRADE without standalone access. Should issue MUSTANDLONE error"
$MUPIP downgrade mumps.dat < yes.txt
# stop concurrent process
$GTM << EOF
set ^stop=1
halt
EOF
set pid = `cat concurrent_job.out`
# this is to ensure the above process stops and properly run down to start next set of commands
$gtm_tst/com/wait_for_proc_to_die.csh $pid -1
\rm -f concurrent_job.out
# check for errors reported by onlnread
if (`$grep -v "PASS" onlnread_mupip2.out|$grep -i "[a-z]"|wc -l`) then
        echo "TEST-E-ERROR Verification failed for GT & DT.Pls. check onlnread_mupip2.out"
	cat onlnread_mupip2.out
endif
#
echo "Attempting MUPIP DOWNGRADE again with standalone access. Should PASS"
$MUPIP downgrade mumps.dat < yes.txt
if ($status) then
	echo "TEST-E-ERROR. MUPIP downgrade failed inspite of standalone access"
endif
# need to delete .o for 64bit flavors
\rm upgrdtst.o gengvn.o genstr.o >&! /dev/null
# switch now to V4 again to check for no errors this time
$sv4
cp mumps_v4.gld mumps.gld
echo "check for reserved bytes incremented by 8 and zero counters in the DSE dump output"
$DSE dump -file | & $tst_awk '/Reserved Bytes/ {print $1" "$2" "$3}'
# check dse output.The pattern below matches the counters which are all expected to be zero.
$DSE dump -file -all|& $grep -E "Retries|^  TP blkmod"
if (`$DSE dump -file -all|& $grep "^  Number of "|&$tst_awk -F":" '{print $3}'|$grep "[1-9]"|wc -l` != 0 ) then
	echo "TEST-E-ERROR.counter expected to be zero"
endif
echo "verification & setting should  pass since database is downgraded to V4"
$GTM << EOF
do verify^upgrdtst
set type="dirtrand1",num=10000
do setdirt^upgrdtst
set type="gvtrand1",num=50000
do setgvt^upgrdtst
halt
EOF
echo "dbcheck on a downgraded v4 database should be clean here"
$gtm_tst/com/dbcheck.csh
# switch to V5 to check verify issues baddbver error
$sv5
cp mumps_v5.gld mumps.gld
echo "verification expected to now fail with BADDBVER error as V5 version is used on a V4 database"
$GTM << EOF
do verify^upgrdtst
halt
EOF
echo "Clean up ftok semaphore which will be left around from the BADDBVER error before attempting MUPIP UPGRADE"
$MUPIP rundown -reg DEFAULT
echo "MUPIP UPGRADE should issue MUUPGRDNRDY error here as dbcertify is not yet run"
$MUPIP upgrade mumps.dat < yes.txt
if ( 0 == $status ) then
	echo "TEST-E-ERROR MUPIP upgrade expected to fail"
endif
\rm upgrdtst.o gengvn.o >&! /dev/null
# conduct dbcertify both phases
$sv4
cp mumps_v4.gld mumps.gld
$DBCERTIFY scan DEFAULT -outfile=dbcertify_out.scan
if ($status) then
        echo "TEST-E-ERROR.dbcertify scan failed"
endif
$DBCERTIFY certify dbcertify_out.scan < yes.txt >>&! dbcertify_out.out
if ($status) then
        echo "TEST-E-ERROR.dbcertify certify failed"
else
	$grep "DBCDBCERTIFIED" dbcertify_out.out
endif
echo "MUPIP UPGRADE should be fine now since dbcertify is done"
$MUPIPV5 upgrade mumps.dat < yes.txt
if ($status) then
	echo "TEST-E-ERROR.mupip upgrade failed even after dbcertify"
endif
$sv5
cp mumps_v5.gld mumps.gld
$GTM << EOF
do verify^upgrdtst
halt
EOF
source $gtm_tst/com/get_blks_to_upgrade.csh "nocheck" "-1"
# $calculated var. set from the above script now carries the value of total-freeblocks-1
$DSE change -file -blks_to_upgrade=$calculated
echo "Attempting MUPIP downgrade when blks_to_upgrade!=tot_blks - free_blks.Should issue MUDWNGRDNRDY error"
$MUPIP downgrade mumps.dat < yes.txt
source $gtm_tst/com/get_blks_to_upgrade.csh "nocheck" "default"
$DSE change -file -blks_to_upgrade=$calculated
$DSE change -file -current_tn=F8000000
echo "Attempting MUPIP DOWNGRADE with curr_tn > M32 - 128M. Should issue MUDWNGRDTN error"
$MUPIP downgrade mumps.dat < yes.txt
# reset txn. number using mupip integ
$MUPIP integ -tn_reset mumps.dat >&! tnreset.log
$grep "No errors detected by integ" tnreset.log
# reset would have fixed blks_to_upgrade to zero , hence reset it back to tot_blks-free_blks
$DSE change -file -blks_to_upgrade=$calculated
$MUPIP downgrade mumps.dat < yes.txt
if ($status) then
	echo "TEST-E-ERROR.mupip downgrade failed even after tn_reset"
endif
# to proceed with upgrade here
# forcefully change the certified bit back to 1 as previous downgrade would have made it 0
# this feature is not documented and hence NOT recommended to the customer,it is only for testing purposes.
cp mumps_v4.gld mumps.gld
# Need to delete .o's for 64bit flavors
\rm upgrdtst.o gengvn.o >&! /dev/null
$sv4
$DSE change -file -hexloc=13F8 -size=4 -hexvalue=1
$sv5
$MUPIP upgrade mumps.dat < yes.txt
if ($status) then
	echo "TEST-E-ERROR.mupip upgrade failed even after tn_reset"
endif
$GDE exit
$DSE change -file -current_tn=F7FFFFFF
$MUPIP downgrade mumps.dat < yes.txt
if ($status) then
	echo "TEST-E-ERROR.mupip downgrade failed for cur_tn=M32-128M"
endif
