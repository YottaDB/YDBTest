#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "Test case : 08 - ztp_tp_multi_region"
$gtm_tst/com/dbcreate.csh mumps 4
echo "start before image  journaling"
$MUPIP set -journal=enable,before -reg "*" |& sort -f
$GTM << EOF
d ^test08
EOF
set time1 = `cat time1.txt_abs`
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before cp/mv of dat files
$gtm_tst/com/backup_dbjnl.csh save "*.dat *.mjl*" cp nozip
echo "----------------------------------------------------------------------------------"
echo mupip journal -recover -back a.mjl,b.mjl
$MUPIP journal -recover -back a.mjl,b.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
#
echo "----------------------------------------------------------------------------------"
cp -f ./save/* .
echo mupip journal -recover -back a.mjl,b.mjl -since=\"$time1\" -look=\"time=0 0:0:0\" -broken=a.broken
# FILERENAME messages will appear below for each .mjl file that is renamed to .mjl_<timestamp>
# But since the order in which MUPIP JOURNAL processes regions is the ftok order of the *.dat files
# (not the alphabetic order), the output order of FILERENAME messages is not guaranteed to be a.mjl, b.mjl, c.mjl, d.mjl
# Since the FILERENAME message is not pertinent to this test, just filter that non-deterministic part of the output away.
$MUPIP journal -recover -back -since=\"$time1\" -look=\"time=0 0:0:0\" a.mjl,b.mjl -broken=a.broken |& $grep -v "FILERENAME"
if ($status == 0) then
	echo PASSED
else
	echo FAILED
endif
## transactions (^a(2) to ^a(10)and ^b(2) to ^b(10)are written to the broken transaction file
#
$GTM << EOF
zwr ^a,^b,^c,^d
EOF
echo "^a(2) to ^a(10) and ^b(2) to ^b(10) will be in the a.broken file"
$tst_awk -F "\\" '/^05/ {print $NF}' a.broken
echo "----------------------------------------------------------------------------------"
##successful case
cp -f ./save/* .
echo mupip journal -recover -back '*' -since=\"$time1\"
$MUPIP journal -recover -back a.mjl,b.mjl,c.mjl,mumps.mjl -since=\"$time1\" -lookback=\"time=0 0:0:0\" |& $grep -v "FILERENAME"
##all  transactions will be  in database and no broken transaction file
#
$GTM << EOF
zwr ^a,^b,^c,^d
EOF
echo "----------------------------------------------------------------------------------"
## Forward recovery
echo "Again delete databases"
rm *.dat
$MUPIP create
cp -f ./save/*.mjl* .
echo "mupip journal -recover -forward -verify a.mjl,b.mjl -lost=a1.lost"
$MUPIP journal -recover -forward -verify a.mjl,b.mjl -broken=a.broken -lost=a1.lost
if ($status == 0) then
	echo PASSED
else
	echo FAILED
endif
## all ^a(1) to ^a(10), ^b(1) to ^b(10) will be in a.broken
## Nothing will be in database
$GTM << EOF
zwr ^a
zwr ^b
zwr ^c
zwr ^d
EOF
echo "^a(1) to ^a(10) and ^b(1) to ^b(10) will be in the a.broken file"
$tst_awk -F "\\" '/^05/ {print $NF}' a.broken
echo "----------------------------------------------------------------------------------"
echo "Again delete databases"
rm *.dat
$MUPIP create
cp -f ./save/*.mjl* .
echo "mupip journal -recover -forward -verify a.mjl,b.mjl,c.mjl -broken=a.broken -lost=a2.lost"
$MUPIP journal -recover -forward -verify a.mjl,b.mjl,c.mjl -broken=a.broken -lost=a2.lost
if ($status == 0) then
	echo PASSED
else
	echo FAILED
endif
#
## Nothing will be in database
$GTM << EOF
zwr ^a
zwr ^b
zwr ^c
zwr ^d
EOF
echo "^a(1) to ^a(10) and ^b(1) to ^b(10) and ^c(1) to ^c(10) will be in the a.broken file"
$tst_awk -F "\\" '/^05/ {print $NF}' a.broken
echo "----------------------------------------------------------------------------------"
## suceesful case, no broken transactions
echo "Again delete databases"
rm *.dat
$MUPIP create
cp -f ./save/*.mjl* .
echo "mupip journal -recover -forward -verify a.mjl,b.mjl,c.mjl,mumps.mjl -broken=a.broken"
$MUPIP journal -recover -forward -verify a.mjl,b.mjl,c.mjl,mumps.mjl -broken=a.broken
if ($status == 0) then
	echo PASSED
else
	echo FAILED
endif
##  recoverd
#
$GTM << EOF
zwr ^a,^b,^c,^d
EOF
echo "----------------------------------------------------------------------------------"
# ######################################################
# The following  are moved to extract related test
######################################################
echo "End of test 08"
cp ./save/*.dat .
$gtm_tst/com/dbcheck.csh
