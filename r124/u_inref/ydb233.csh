#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "-------------------------------------------------------------------------------------------------------"
echo "# Test that MUPIP SET -REORG_SLEEP_NSEC is correctly set, and is accurate during a MUPIP REORG process."
echo "-------------------------------------------------------------------------------------------------------"
#
echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
        echo "# dbcreate failed. Output of dbcreate.out follows"
        cat dbcreate.out
        exit -1
endif
echo "------------------------------------------------------------------------"
echo "# Set REORG_SLEEP_NSEC to 10**9"
$ydb_dist/mupip set -reorg_sleep_nsec=1000000000 -reg "*"
echo ""
echo "# Generate random value > 10**9 (one more than the maximum nanosecond sleep value that can be specificed in REORG_SLEEP_NSEC"
set randlarge=`$ydb_dist/mumps -run ^%XCMD 'write $random(1000000000)+1000000000'`
echo "# Set REORG_SLEEP_NSEC to the random value"
$ydb_dist/mupip set -reorg_sleep_nsec=$randlarge -reg "*" >& sleeperr.txt ; sed -i "s/$randlarge/##HUGERANDOMSLEEP##/g" sleeperr.txt
cat sleeperr.txt
echo "------------------------------------------------------------------------"
echo "# Set REORG_SLEEP_NSEC to the max value, 999999999"
$ydb_dist/mupip set -reorg_sleep_nsec=999999999 -reg "*"
echo ""
echo "# Generate random value < 10**9"
set reorgTT=`$ydb_dist/mumps -run ^%XCMD 'write $random(1000000000)'`
echo "# Set REORG_SLEEP_NSEC to the random value"
$ydb_dist/mupip set -reorg_sleep_nsec=$reorgTT -reg "*" >& sleep.txt ; sed -i "s/$reorgTT/##VALIDNANOSECSLEEP##/g" sleep.txt
cat sleep.txt
echo "------------------------------------------------------------------------"
echo "# Check that PEEKBYNAME shows the correct value of reorg_sleep_mode"
set peek=`$ydb_dist/mumps -run peek^ydb233`
if ("$peek" == "$reorgTT") then
	echo "------>PEEKBYNAME successfully shows the correct value."
else
	echo "------>PEEKBYNAME does not show the correct value."
endif
#
echo ""
echo "# Check the dump to make sure reorg_sleep_nsec was correctly set"
$ydb_dist/dse dump -file |& grep "Reorg Sleep Nanoseconds" > dump.txt
if { grep -q "$reorgTT" dump.txt } then
	echo "------>DSE DUMP -FILE successfully shows the correct value."
else
	echo "------>DSE DUMP -FILE  does not show the correct value."
endif
#
#
echo "------------------------------------------------------------------------"
echo "# Generate global variables to fill database, then kill half of the global variables"
echo "# This creates work for MUPIP REORG below"
$ydb_dist/mumps -direct << YDB_EOF
	For i=1:1:1000 Set ^X(i)=\$Justify(256,100)
	For j=1:2:1000 Kill ^X(j)
YDB_EOF
#
echo ""
echo "# Use strace to test that mupip reorg honors reorg_sleep_nsec value"
strace -T -o trace1.outx $ydb_dist/mupip reorg >& mupipreorg.txt
echo 'strace -T -o trace1.outx $ydb_dist/mupip reorg >& mupipreorg.txt'
#
echo "# Calculate the sleep time across various clock_nanosecond() calls for mupip reorg, and compare it to what was set"
echo "# For every coalesced block, MUPIP REORG does at least one clock_nanosleep(REORG_SLEEP_NSEC) call."
echo "  (Calls could be more than 1 in the case of EINTR interrupts, but the total time slept is the same accross multiple calls)"
echo "  This is why the total call from clock_nanosleep() calls is obtained from strace -T and divided by the # of blocks coalesced."
echo "  This average is compared to the time set for REORG_SLEEP_NSEC."
echo ""
#	     Find the coalesced line	      print only the number in the line
set coalvar=`grep coalesced mupipreorg.txt | $tst_awk '{print substr($0,length($0)-2,length($0)-1)}'`

#    Find the nanosleep calls
grep nanosleep trace1.outx |$tst_awk '{ split ( $0,a,"<" ) ; SPL=a[2]} { print substr(SPL,1,length(SPL)-1) }' > reorgTA.txt

# awk segment 1: split the line obtained by grep and choose the characters after <
# awk segment 2: take only the number in that line

# Calculate the sum of all clock_nanosleep() calls
set reorgTA=`$ydb_dist/mumps -run sleepTime^ydb233 $coalvar`

# Output the random variables generated as well as the amount of coalesced blocks.
cat << EOF > debug.txt
Random Variable > 10**9: $randlarge
Expected sleep time: $reorgTT
Actual sleep time: $reorgTA
Amount of Coalesced Blocks: $coalvar
EOF

echo "# Calculate percent error of MUPIP REORG sleep time to see if it is accurate"
$ydb_dist/mumps -run percent^ydb233 $reorgTA $reorgTT

# Because strace uses microsecond rounding, we allow for +/- 10% error.

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
        echo "# dbcheck failed. Output of dbcheck.out follows"
        cat dbcheck.out
        exit -1
endif

