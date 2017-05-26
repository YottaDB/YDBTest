#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This test case covers from test case 01 to 13
# from mupip set journal test plan
#
echo Test case 01
# needs file or region option
$MUPIP set -journal=enable,on,nobefore
echo "============================================================"
#
echo Test case 02
#
#nonexistent file
$MUPIP set -journal=enable,nobefore -file dummy.dat
#nonexistent regions
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh . 3
\rm a.dat
$MUPIP set -journal=enable,nobefore -reg "*"
$MUPIP set -journal=enable,nobefore -reg AREG
#nonexistent database
$MUPIP set -journal=enable,nobefore -file dummy.dat
echo "============================================================"
#
echo Test case 03
#
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh . 3
# mupip set journal command to set journaling and nonjournaling charateristics
$MUPIP set -journal=disable -file mumps.dat
$MUPIP set -res=1000 -journal=enable,nobefore -file mumps.dat
$MUPIP set -res=600 -journal=enable,nobefore -file mumps.dat
$MUPIP set -journal=enable,on,off,nobefore -res=600 -file mumps.dat
echo "============================================================"
#
# test case 04
#
echo DISABLE option
echo $MUPIP set -journal=disable -file mumps.dat
$MUPIP set -journal=disable -file mumps.dat
echo $MUPIP set -journal=disable -file mumps.dat
$MUPIP set -journal=disable -file mumps.dat
$MUPIP set -journal=enable,nobefore,alignsize=4096,allocation=2048,autoswitchlimit=16448,buffer_size=2308,extension=100,filename="abcd.mjl",sync_io,yield_limit=1000 -file mumps.dat
$DSE << DSE_EOF >& dse_dump_1.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
\cat dse_dump_1.txt | $grep "Journal"
# DISABLE journaling
$MUPIP set -journal=disable -file mumps.dat
$DSE << DSE_EOF >& dse_dump_2.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
\cat dse_dump_2.txt | $grep "Journal"
#
$MUPIP set -journal=enable,nobefore -file mumps.dat
$DSE << DSE_EOF >& dse_dump_3.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
\cat dse_dump_3.txt | $grep "Journal"
echo "============================================================"
#
echo Test case : 5
#
echo DISABLE option is not compatible with any other option
$MUPIP set -journal=disable,nobefore -file mumps.dat
$MUPIP set -journal=disable,before -file mumps.dat
$MUPIP set -journal=disable,on -file mumps.dat
$MUPIP set -journal=disable,off -file mumps.dat
$MUPIP set -journal=disable,alignsize=4096 -file mumps.dat
$MUPIP set -journal=disable,allocation=2048 -file mumps.dat
$MUPIP set -journal=disable,auto=4096 -file mumps.dat
$MUPIP set -journal=disable,buffer_size=2308 -file mumps.dat
$MUPIP set -journal=disable,ep=600 -file mumps.dat
$MUPIP set -journal=disable,extension=16448 -file mumps.dat
$MUPIP set -journal=disable,filename="abcd.mjl" -file mumps.dat
$MUPIP set -journal=disable, -file mumps.dat
echo "============================================================"
#
echo Test case 06
#
echo NOJOURNAL option
$MUPIP set -nojournal -journal=enable,nobefore -file mumps.dat
$MUPIP set -journal=enable,nobefore -nojournal -file mumps.dat
echo NOJOURANL qualifier is equivalent to DISABLE option
$MUPIP set -journal=disable -file mumps.dat
\mkdir ./save6 ; mv *.mjl* ./save6
$MUPIP set -journal=enable,nobefore,alignsize=4096,allocation=2048,autoswitchlimit=16448,buffer_size=2308,extension=100,filename="abcd.mjl",sync_io,yield_limit=1000 -file mumps.dat
$DSE << DSE_EOF >& dse_dump_4.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
\cat dse_dump_4.txt | $grep "Journal"
#
$MUPIP set -NOJOURNAL -file mumps.dat
$DSE << DSE_EOF >& dse_dump_5.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
set jnl_state = `cat dse_dump_5.txt | $grep "Journal State" | $tst_awk '{print $3}'`
echo "Journal state (expected DISABLED): $jnl_state"
#now enable journaling and verify that everyhting related to
# journal is default value
$MUPIP set -journal=enable,nobefore -file mumps.dat
$DSE << DSE_EOF >& dse_dump_6.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
\cat dse_dump_6.txt | $grep "Journal"
echo "============================================================"
#
echo Test case 07
#
echo "[NO]BEFORE qualifier"
$MUPIP set -journal=disable -file mumps.dat
$MUPIP set -journal=enable -file mumps.dat
$MUPIP set -journal=on -file mumps.dat
$MUPIP set -journal=enable,on -file mumps.dat
#The following two should be successful
$MUPIP set -journal=enable,before -file mumps.dat
$MUPIP set -journal=enable,nobefore -file mumps.dat
echo "============================================================"
#
echo Test case 08
echo If both BEFORE and NOBEFORE are given  latter is taken
echo $MUPIP set -journal=enable,before,nobefore -file mumps.dat
$MUPIP set -journal=enable,before,nobefore -file mumps.dat
echo "============================================================"
#
echo Test case 09
echo ON option does not have any effect if journaling is not enabled
echo $MUPIP set -journal=disable -file mumps.dat
$MUPIP set -journal=disable -file mumps.dat
echo $MUPIP set -journal=on,nobefore -file mumps.dat
$MUPIP set -journal=on,nobefore -file mumps.dat
$DSE << DSE_EOF >& dse_dump_7.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
set jnl_state = `cat dse_dump_7.txt | $grep "Journal State" | $tst_awk '{print $4}'`
echo "Journal state: $jnl_state"
echo $MUPIP set -journal=enable,on,nobefore -file mumps.dat
$MUPIP set -journal=enable,on,nobefore -file mumps.dat
$DSE << DSE_EOF >& dse_dump_7.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
set jnl_state = `cat dse_dump_7.txt | $grep "Journal State" | $tst_awk '{print $4}'`
echo "Journal state: $jnl_state"
echo $MUPIP set -journal=off -file mumps.dat
$MUPIP set -journal=off -file mumps.dat
$DSE << DSE_EOF >& dse_dump_7.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
set jnl_state = `cat dse_dump_7.txt | $grep "Journal State" | $tst_awk '{print $4}'`
echo "Journal state: $jnl_state"
echo $MUPIP set -journal=on,nobefore -file mumps.dat
$MUPIP set -journal=on,nobefore -file mumps.dat
$DSE << DSE_EOF >& dse_dump_7.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
set jnl_state = `cat dse_dump_7.txt | $grep "Journal State" | $tst_awk '{print $4}'`
echo "Journal state (expected ON): $jnl_state"
echo "============================================================"
#
echo Test case 10
#
echo ON is default value with enable option
$MUPIP set -journal=enable,nobefore -file mumps.dat
$DSE << DSE_EOF >& dse_dump_8.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
set jnl_state = `cat dse_dump_8.txt | $grep "Journal State" | $tst_awk '{print $4}'`
echo "Journal state (expected ON): $jnl_state"
echo "============================================================"
#
echo Test case 11
#
echo OFF option does have any effect if journaling is not enabled
echo $MUPIP set -journal=disable -file mumps.dat
$MUPIP set -journal=disable -file mumps.dat
echo $MUPIP set -journal=off -file mumps.dat
$MUPIP set -journal=off -file mumps.dat
\mkdir ./save11 ; mv *.mjl* ./save11
echo $MUPIP set -journal=enable,off,alignsize=4096,allocation=2048,autoswitchlimit=16448,buffer_size=2308,extension=100,filename=abcd.mjl,sync_io,yield_limit=1000 -file mumps.dat
$MUPIP set -journal=enable,off,alignsize=4096,allocation=2048,autoswitchlimit=16448,buffer_size=2308,extension=100,filename="abcd.mjl",sync_io,yield_limit=1000 -file mumps.dat
$DSE << DSE_EOF >& dse_dump_9.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
\cat dse_dump_9.txt | $grep "Journal"
#
echo $MUPIP set -journal=on,nobefore -file mumps.dat
$MUPIP set -journal=on,nobefore -file mumps.dat
$DSE << DSE_EOF >& dse_dump_10.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
\cat dse_dump_10.txt | $grep "Journal"
echo "============================================================"
#
echo Test case 12
echo ON and OFF are mutually exclusive
$MUPIP set -journal=enable,on,off,nobefore -file mumps.dat
echo "============================================================"
#
echo "Test case 13 (default value of qualifiers)"
# This is covered by other test cases
#
echo "Default values are  tested with  other test cases"
echo "============================================================"
$gtm_tst/com/dbcheck.csh
#
#! END
#
