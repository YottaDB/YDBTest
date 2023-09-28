#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2005, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# TEST to check MUPIP JOURNAL
setenv gtm_test_use_V6_DBs 0	  	# Disable V6 DB mode due to differences in MUPIP INTEG outputs

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

###################  Show header section ##########################
#			Section 1				  #
$gtm_tst/com/dbcreate.csh mumps
# Turn on Jounaling
$MUPIP set -journal="enable,on,nobefore" -region "*"
# change curr_tn to 2**32 -10
$DSE change -file -curr=FFFFFFF6
# switch journal files
$MUPIP set -journal="enable,on,nobefore" -region "*"
$GTM << EOF
for i=1:1:20 set ^twentytwentywith32(i)=\$justify(i,100)
halt
EOF
$MUPIP journal -extract=ext1.out -forward mumps.mjl
# check for transaction number from the extract out which is in the third column
# the value should be 2 ** 32 +10 now
# "02" in the comamnd below is to search for "Process termination record" record type in the output
if ("4294967306" != `$tst_awk -F \\ '/^02/ {a=$3} END {print a}' ext1.out`) then
	echo ""
	echo "TEST-E-ERROR. transaction number expected to increase but hasn't under 2 ** 32 category"
	echo ""
else
	echo ""
	echo "PASS. tn number is 2**32+10"
	echo ""
endif
#change TN again to 2**63 -10
$DSE change -file -curr=7FFFFFFFFFFFFFF6
# switch journal files
$MUPIP set -journal="enable,on,nobefore" -region "*"
$GTM << EOF
for i=1:1:20 set ^twentytwentywith64(i)=\$justify(i,100)
halt
EOF
$MUPIP journal -extract=ext2.out -forward mumps.mjl
# check for transaction number from the extract out which is in the third column
# the value should be 2 ** 63 +10 now
if ("9223372036854775818" != `$tst_awk -F \\ '/^02/ {a=$3} END {print a}' ext2.out`) then
	echo ""
	echo "TEST-E-ERROR. transaction number expected to increase but hasn't under 2 ** 63 category"
	echo ""
else
	echo ""
	echo "PASS. tn number is 2**63+10"
	echo ""
endif
echo ""
echo "BEGIN & END trnasaction number should be 64 bit values here"
echo ""
$MUPIP journal -show=header -forward mumps.mjl|& $grep -E "Begin Transaction|End Transaction"
$gtm_tst/com/dbcheck.csh
# backup old files
mkdir section_1
mv mumps.dat mumps.gld mumps*.mjl* section_1
#
###################  APPLY_AFTER_IMAGE issues section ###########################
#				Section 2					#
set format="%d-%b-%Y %H:%M:%S"
# create emtpy V5 DB
$gtm_tst/com/dbcreate.csh mumps
$MUPIP set -journal="enable,on,before" -region "*"
$GTM << EOF
set ^x=1
halt
EOF
# to avoid issues with time-granularity of 1 second
sleep 2
set time1=`date +"$format"`
# to avoid issues with time-granularity of 1 second
sleep 2
# cause an after-image to be written
$DSE add -block=3 -rec=2 -key="^x(2)" -data="2"
# do a recover from the noted time above
################################################################################################################
# <note from test plan>
#This is because there would have been an EPOCH written after the GTM process halted out.
#And after that, the DSE process would have written a before-image of the block=3 before updating it.
#Also it would have written an after-image of that block.
#The backward recovery with -since_time ensures we go at least as back as the EPOCH written before the DSE started.
#That would mean backward recovery would have processed the before-image and later forward recovery will
#process the after-image of the same block=3 which should then trigger the WRNGBLKS2UPGRD message
################################################################################################################
$MUPIP journal -recover -back -since=\"$time1\" -APPLY_AFTER_IMAGE "*" >>&! journal_recover.out
$grep "WRNBLKS2UPGRD" journal_recover.out
if !($status) then
	echo ""
	echo "TEST-E-ERROR. WRNBLKS2UPGRD not expected here"
	echo ""
else
	echo "PASS"
endif
cat journal_recover.out
$MUPIP integ -reg "*"
if ($status) then
	echo "TEST-E-ERROR. integ errors pls.check"
else
	echo " integ clean.PASS"
endif
$gtm_tst/com/dbcheck.csh
###################  APPLY_AFTER_IMAGE issues section ends ##########################
