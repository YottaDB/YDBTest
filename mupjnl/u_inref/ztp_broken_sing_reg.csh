#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "Test case : 09 -  ztp_brkn_sing_reg"
$gtm_tst/com/dbcreate.csh mumps 1
set time0 = `date +'%d-%b-%Y %H:%M:%S'`
sleep 2
echo "Start before image journaling"
$MUPIP set -journal=enable,before -reg "*"
cp $gtm_tst/$tst/inref/ztp.m .
echo "mumps -run  ztp"
$gtm_exe/mumps -run  ztp
sleep 3
set time3 = `date +'%d-%b-%Y %H:%M:%S'`
set time1 = `cat time1.txt_abs`
set time2 = `cat time2.txt_abs`
echo "time0 = $time0"
#echo "time1 = $time1"
#echo "time2 = $time2"
echo "time3 = $time3"
$gtm_tst/com/backup_dbjnl.csh save "*.dat *.mjl*" cp nozip
#
echo "------------------------------------------------------------------"
echo mupip journal -recover -back '"*"'
$MUPIP journal -recover -back "*"
echo "Value of  ^a(i) should be i*10"
$GTM << EOF
 f i=1:1:10 w ^a(i),!
EOF
echo "------------------------------------------------------------------"
cp ./save/* .
echo mupip journal -recover -back '"*"' -since=time1
$MUPIP journal -recover -back "*" -since=\"$time1\"
echo "Value of ^a(i) should be i"
$GTM << EOF
 f i=1:1:10 w ^a(i),!
EOF
echo mupip journal -show=broken -back mumps.mjl
$MUPIP journal -show=broken -back mumps.mjl
##
echo "------------------------------------------------------------------"
cp ./save/* .
echo mupip journal -recover -back '"*"' -look=\"time=time1\"
$MUPIP journal -recover -back "*" -look=\"time=$time1\"
#will report no broken transactions
echo "Value of ^a(i) should be i*10"
$GTM << EOF
 f i=1:1:10 w ^a(i),!
EOF
##
echo "------------------------------------------------------------------"
cp ./save/* .
echo mupip journal -recover -back '"*"' -since=\"time0\"
$MUPIP journal -recover -back "*" -since=\"$time0\"
##
echo "------------------------------------------------------------------"
cp ./save/* .
echo mupip journal -recover -back '"*"' -look=\"time=time0\"
$MUPIP journal -recover -back "*" -look=\"time=$time0\"
#will report no broken transactions
echo "Value of ^a(i) should be i*10"
$GTM << EOF
 f i=1:1:10 w ^a(i),!
EOF
##
echo "------------------------------------------------------------------"
cp ./save/* .
echo mupip journal -recover -back '"*"' -since=\"time3\"
$MUPIP journal -recover -back "*" -since=\"$time3\"
#will report no broken transactions
echo "Value of ^a(i) should be i*10"
$GTM << EOF
 f i=1:1:10 w ^a(i),!
EOF
####
echo "------------------------------------------------------------------"
cp ./save/* .
echo mupip journal -recover -back '"*"' -since=\"time1\" -look=\"time=time3\"
$MUPIP journal -recover -back "*" -since=\"$time1\" -look=\"time=$time3\"
# error because time3 > time1
##
echo "------------------------------------------------------------------"
cp ./save/* .
echo mupip journal -recover -back '"*"' -since=\"time1\" -look=\"time=time1\"
$MUPIP journal -recover -back "*" -since=\"$time1\" -look=\"time=$time1\"
#will report 10 broken transactions
echo "Value of ^a(i) should be i"
$GTM << EOF
 f i=1:1:10 w ^a(i),!
EOF
echo mupip journal -show=br -back mumps.mjl
$MUPIP journal -show=br -back mumps.mjl
##
echo "------------------------------------------------------------------"
cp ./save/* .
echo mupip journal -recover -back '"*"' -since=\"time1\" -look=\"time=time1\" -fences=none
$MUPIP journal -recover -back "*" -since=\"$time1\" -look=\"time=$time1\" -fences=none
#will report no broken transactions
echo "Value of ^a(i) should be i*10"
$GTM << EOF
 f i=1:1:10 w ^a(i),!
EOF
##
echo "------------------------------------------------------------------"
cp ./save/* .
echo mupip journal -recover -back '"*"' -before=\"time1\"
$MUPIP journal -recover -back "*" -before=\"$time1\"
# error because time1 > since
##
echo "------------------------------------------------------------------"
cp ./save/* .
echo mupip journal -recover -back '"*"' -since=\"time1\" -before=\"time2\"
$MUPIP journal -recover -back "*" -since=\"$time1\" -before=\"$time2\"
#will report no broken transactions
echo "Value of ^a(i) should be i"
$GTM << EOF
 f i=1:1:10 w ^a(i),!
EOF
##
echo "------------------------------------------------------------------"
cp ./save/* .
rm mumps.dat
$MUPIP create
echo mupip journal -recover -forw -verify mumps.mjl -before=time2
$MUPIP journal -recover -forw -verify mumps.mjl -before=\"$time2\"
#will report no broken transactions
echo "Value of ^a(i) should be i"
$GTM << EOF
 f i=1:1:10 w ^a(i),!
EOF
##
echo "------------------------------------------------------------------"
cp ./save/* .
rm mumps.dat
$MUPIP create
echo mupip journal -recover -forw -verify mumps.mjl
$MUPIP journal -recover -forw -verify mumps.mjl
#will report 10 broken transactions
echo "Value of ^a(i) should be i"
$GTM << EOF
 f i=1:1:10 w ^a(i),!
EOF
echo mupip journal -show=br -back mumps.mjl
$MUPIP journal -show=br -back mumps.mjl
##
echo "------------------------------------------------------------------"
cp ./save/* .
rm mumps.dat
$MUPIP create
echo mupip journal -recover -forw -verify mumps.mjl -fences
$MUPIP journal -recover -forw -verify mumps.mjl -fences
#will report 10 broken transactions
echo "Value of ^a(i) should be i"
$GTM << EOF
 f i=1:1:10 w ^a(i),!
EOF
##
echo "------------------------------------------------------------------"
cp ./save/* .
rm mumps.dat
$MUPIP create
echo mupip journal -recover -forw -verify mumps.mjl -fences=process
$MUPIP journal -recover -forw -verify mumps.mjl -fences=process
#will report 10 broken transactions
echo "Value of ^a(i) should be i"
$GTM << EOF
 f i=1:1:10 w ^a(i),!
EOF
echo mupip journal -show=br -back mumps.mjl
$MUPIP journal -show=br -back mumps.mjl
##
echo "------------------------------------------------------------------"
cp ./save/* .
rm mumps.dat
$MUPIP create
echo mupip journal -recover -forw -verify mumps.mjl -fences=none
$MUPIP journal -recover -forw -verify mumps.mjl -fences=none
#will report no broken transactions
echo "Value of ^a(i) should be i*10"
$GTM << EOF
 f i=1:1:10 w ^a(i),!
EOF
##
echo "------------------------------------------------------------------"
#echo "Step  p : look like illegal combination, since  -after is applicable with extract and show"
cp ./save/* .
rm mumps.dat
$MUPIP create
echo mupip journal -extract  -forw mumps.mjl -after=time2
$MUPIP journal -extract -forw mumps.mjl -after=\"$time2\"
#will report 10 broken transactions
##
echo "------------------------------------------------------------------"
cp ./save/* .
rm mumps.dat
$MUPIP create
echo mupip journal -extract=mumps1.mjf -broken=mumps1.broken -lost=mumps1.lost -forw mumps.mjl -after=time2 -fences
$MUPIP journal -extract=mumps1.mjf -broken=mumps1.broken -lost=mumps1.lost -forw mumps.mjl -after=\"$time2\" -fences
#will report 10 broken transactions
##
echo "------------------------------------------------------------------"
cp ./save/* .
rm mumps.dat
$MUPIP create
echo mupip journal -extract=mumps2.mjf -forw mumps.mjl -after=\"time2\" -fences=none
$MUPIP journal -extract=mumps2.mjf -forw mumps.mjl -after=\"$time2\" -fences=none
#will report no broken transactions
##
echo "------------------------------------------------------------------"
cp ./save/* .
rm mumps.dat
# JOURNAL EXTRACT is issued when there are no database files in the current directory.
# JOURNAL EXTRACT might need to read the database file to get the collation information.
# To skip the JOURNAL EXTRACT from reading the database file, set the env variable
# gtm_extract_nocol to non-zero value.
setenv gtm_extract_nocol 1
echo mupip journal -extract=mumps3.mjf -forw mumps.mjl -before=time2
$MUPIP journal -extract=mumps3.mjf  -forw mumps.mjl -before=\"$time2\"
#will extract before time2
echo "End of test"
cp ./save/* .
$gtm_tst/com/dbcheck.csh
