#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "Test case : 71: Backward recovery creates  new journal file"
$gtm_tst/com/dbcreate.csh mumps 1
echo mupip set -journal=enable,before -reg '"*"'
$MUPIP set -journal=enable,before -reg "*"
$GTM << EOF
f i=1:1:5 s ^x(i)=i
zsy "$DSE buff"
h 2
zsy "$gtm_tst/com/abs_time.csh time1.txt"
h 2
f i=6:1:15 s ^x(i)=i
zsy "$gtm_tst/com/abs_time.csh time2.txt"
zsy "$DSE buff"
h 2
f i=16:1:20 s ^x(i)=i
Q
EOF
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed as below test assumes db shm has been rundown
set time1 = `cat time1.txt_abs`
set time2 = `cat time2.txt_abs`
echo "Before recovery : Journal header of mumps.mjl"
$MUPIP journal  -show=header -forw mumps.mjl
echo "-----------------------------------------------------------------------------------"
echo mupip journal -recover -back -since=\"$time1\" -before=\"$time2\" mumps.mjl
$MUPIP journal -recover -back -since=\"$time1\" -before=\"$time2\" mumps.mjl
echo "Check  ^x(16) to ^x(30) are not present in database"
$GTM << EOF
zwr ^x
EOF
set oldjnl = `ls mumps.mjl_*`
echo "New Journal file : mumps.mjl"
$DSE dump -fileheader |& $grep "Journal File"
echo "After recovery:"
$MUPIP journal -show=header -forw  $oldjnl
echo "-----------------------------------------------------------------------------------"
echo "mumps.mjl (current generation) will contain trasactions 6 to 15 (total transactions: 10)"
echo mupip journal -extract -forward -det mumps.mjl
$MUPIP journal -extract -forward -det mumps.mjl
$tst_awk -F "\\" '$1 ~ /SET/ {print $NF}' mumps.mjf
set total_trans = `$tst_awk -F "\\" '$1 ~ /SET/ {count++} END { print count}' mumps.mjf`
echo "total transactions in extract file: $total_trans"
echo "-----------------------------------------------------------------------------------"
echo "Prev generation of mumps.mjl (without full) will extract transactions 1 to 5 (total transactions: 5)"
echo mupip journal -extract=extr_nofull.mjf -forward -det $oldjnl
$MUPIP journal -extract=extr_nofull.mjf -forward -det $oldjnl
$tst_awk -F "\\" '$1 ~ /SET/ {print $NF}' extr_nofull.mjf
set total_trans = `$tst_awk -F "\\" '$1 ~ /SET/ {count++} END { print count}' extr_nofull.mjf`
echo "total transactions in extract file: $total_trans"
echo "-----------------------------------------------------------------------------------"
echo "Prev generation of mumps.mjl (with full) will extract transactions 1 to 20 (total transactions: 20)"
echo mupip journal -extract=extr_full.mjf -forward -full -det $oldjnl
$MUPIP journal -extract=extr_full.mjf -forward -full -det $oldjnl
$tst_awk -F "\\" '$1 ~ /SET/ {print $NF}' extr_full.mjf
set total_trans = `$tst_awk -F "\\" '$1 ~ /SET/ {count++} END { print count}' extr_full.mjf`
echo "total transactions in extract file: $total_trans"
echo End of test
$gtm_tst/com/dbcheck.csh
