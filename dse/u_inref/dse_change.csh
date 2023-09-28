#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#create a global directory with two regions -- DEFAULT, REGX
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
setenv gtm_test_use_V6_DBs 0   # Disable V6 DB mode as it causes changes in output of DSE commands (block #s, offsets, etc)
$gtm_tst/com/dbcreate.csh mumps 2 -block_size=1024

# Set some global variables - to fill some blocks

$GTM << GTM_EOF
do ^createdb
halt
GTM_EOF

echo "TEST DSE - CHANGE COMMAND"

echo "--------------------- Test 1 ---------------------"
# BLOCK FIELDS

# try changing bsize of block zero
# only the last one should work

$DSE << DSE_EOF

change -block=0 -bsiz=0
change -block=0 -bsiz=30
change -block=0 -bsiz=90

DSE_EOF

echo "--------------------- Test 2 ---------------------"
# change the level, and transaction number fields for block zero
# block zero should allow only a level of 0xFF (-1)
# Additionally test that change -block -tn holds onto crit if crit -seize was previously done

$DSE << DSE_EOF

crit -seize
change -block=0 -tn=10
crit -all
change -block=0 -level=10
change -block=0 -level=FF

DSE_EOF

echo "--------------------- Test 3 ---------------------"
# try changing record and offset qualifiers for block zero

$DSE << DSE_EOF

change -bloc=0 -offset=10 -rsiz=3
change -bloc=0 -record=2 -rsiz=32
change -bloc=0 -record=2 -cmpc=2
change -block=0 -offset=2 -cmpc=3

DSE_EOF

echo "--------------------- Test 4 ---------------------"
# OTHER BLOCKS

# change the level of a block and restore it to default

$DSE << DSE_EOF

change  -leve=1 -block=27
dump -block=27 -header

change -block=27 -level=0
dump -block=27 -header

DSE_EOF

echo "--------------------- Test 5 ---------------------"
# change the transaction number field of a block
# change the cmpc of a record and bring them to default

$DSE << DSE_EOF

change  -tn=1000 -block=27
dump -block=27 -header
change  -tn=4D2 -block=27

change  -reco=4 -cmpc=0 -block=27
dump -block=27 -record=4 -hea

change -reco=4 -cm=A -block=27
dump -block=27 -record=4 -hea

DSE_EOF

echo "--------------------- Test 6 ---------------------"
# try reducing the record size to zero
# try reducing the record size to minimum possible
# increase the record size than the actual and dump it
# bring the size to default

$DSE << DSE_EOF

change -record=4 -rs=0  -block=27

change -record=4 -rs=4 -block=27
dump -block=27 -record=4 -hea

change -record=4 -rsiz=3B  -block=27
dump -block=27 -record=4 -hea

change -record=4 -rsiz=2B -block=27
dump -block=27 -record=4 -hea

DSE_EOF

echo "--------------------- Test 7 ---------------------"
# try all the above with offset field

$DSE << DSE_EOF

change  -offs=9E -cmpc=0 -block=27
dump -block=27 -record=4 -hea

change -offs=9E -cmpc=A -block=27
dump -block=27 -record=4 -hea

change -offset=9E -rsiz=0 -block=27

change -offset=9E -rsiz=4 -block=27
dump -block=27 -offset=9E         -hea

change -offset=9E -rsiz=3B -block=27
dump -block=27 -offset=9E -hea

change -offset=9E -rsiz=2B -block=27
dump -block=27 -offset=9E -hea

DSE_EOF

echo "--------------------- Test 8 ---------------------"
# change the blocksize
# try making it zero, then the minimum possible
# try size greater than maximum

$DSE << DSE_EOF

change -bsiz=0 -block=27

change -bsiz=10 -block=27
dump -block=27 -hea

change -bsiz=2300  -block=27

change  -bsiz=272  -block=27
dump -block=27 -header

DSE_EOF

echo "--------------------- Test 9 ---------------------"
# try changing a record which is non existant

$DSE << DSE_EOF

change -reco=F -cmpc=0 -block=27
change -reco=0 -cmpc=0 -block=27

DSE_EOF

echo "--------------------- Test 10 ---------------------"
# try changing a record at offset zero, the minimum possible  and greater than the maximum in a block

$DSE << DSE_EOF

change -offset=0 -cmpc=0 -block=27
change -offset=10 -cmpc=A -block=27
dump -offset=10 -hea
change -offset=10 -cmpc=0 -block=27
dump -offset=10 -hea
change -offset=2BE -cmpc=0 -block=27
change -offset=271 -cmpc=0 -block=27
dump -record=E -hea
change -offset=271 -cmpc=A -block=27
dump -record=E -hea

DSE_EOF

# FILE HEADER FIELDS

# For replication make sure that backlog is cleared which will give consistent output
if ($?test_replic == 1) then
	$gtm_tst/com/wait_until_src_backlog_below.csh 0 300
	if ($status == 1) then
		echo "TEST-E-TIMEOUT, it took too long to send data from source server to receive server."
 		$gtm_tst/com/dbcheck "mumps"
		exit
	endif
endif

echo "--------------------- Test 11 ---------------------"
# change the block size to an arbitrary value ( not a multiple of 512 )

$DSE << DSE_EOF
change -fileheader -blk_size=0
DSE_EOF

echo "--------------------- Test 12 ---------------------"
$DSE << DSE_EOF >& change.log
dump -fileheader
DSE_EOF

echo -n
$grep -E "(Block size|Modified cache)" change.log

echo "--------------------- Test 13 ---------------------"
$DSE << DSE_EOF
change -fi -blk_size=1023
DSE_EOF

echo "--------------------- Test 14 ---------------------"
$DSE << DSE_EOF >& change.log
dump -fileheader
DSE_EOF

echo -n
$grep "Block size" change.log

echo "--------------------- Test 15 ---------------------"
# change the number of free blocks to greater than, less than the existing and
# bring it back to default

$DSE << DSE_EOF

change -file -blocks_free=75

change -fileheader -blo=0

change -fileheader -bloc=3D

DSE_EOF

echo "--------------------- Test 16 ---------------------"
# change various TN fields

$DSE << DSE_EOF
change -fileheader -b_comprehensive=1000
change -fileheader -b_incremental=1000
change -fileheader -b_record=1000
change -fileheader -current_tn=1000

change -fileheader -b_co=1
change -fileheader -b_in=1
change -fileheader -b_reco=1
change -fileheader -curr=80F5
DSE_EOF

echo "--------------------- Test 17 ---------------------"
$DSE << DSE_EOF >& change.log
dump -fileheader
DSE_EOF

echo -n
$grep "Last record" change.log
$grep "Last Comp" change.log
$grep "Last Inc" change.log
$grep "Current tran " change.log

echo "--------------------- Test 18 ---------------------"
# change the key size and try to add a bigger key
# also test that crit is not held by dse after issuing the GVSUBOFLOW error

$DSE << DSE_EOF
crit -all
change -fileheader -key_max_size=20
add -reco=2 -key="^aglobal(""abcdefghijklmnop"")" -data="dont add" -block=27
add -reco=2 -key="^aglobal(""abcdefgh"")" -data="add it" -block=27
remove  -reco=2 -block=27
crit -all
DSE_EOF

echo "--------------------- Test 19 ---------------------"
# reduce the size of the maximum record size field, try adding a bigger record
# also test that crit IS held by dse after issuing the REC2BIG error because of the crit -seize

$DSE << DSE_EOF
crit -all
crit -seize
change -fileheader -record_max_size=22
add -block=27 -reco=2 -key="^aglobal(""abcdefghi"")" -data="too big a record to fit"
crit -all
DSE_EOF

echo "--------------------- Test 20 ---------------------"
# restore the above values to default, and test it again
# restore the database by removing the record added above

$DSE << DSE_EOF

change -fileheader -key_m=64
change -fileheader -reco=256

add -block=27 -reco=2 -key="^aglobal(""abcdefghij"",""klmnopqrstuvwxyz"")" -data="record big enough to hold this data abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijlmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"
dump -block=27 -reco=2 -hea
remove  -reco=2 -block=27

DSE_EOF

if (("MM" != $acc_meth) || (1 == $gtm_platform_mmfile_ext)) then

	echo "--------------------- Test 21 ---------------------"
	# change the total number of blocks to values less than and greater than
	# the actual number of blocks and  try accessing a data block
	# restore the value back

	$DSE << DSE_EOF

	change -fileheader -total_blks=10
	dump -bloc=27 -reco=E -hea
	change -bl=11 -level=2

	change -fileheader -tota=230
	dump -bloc=27 -reco=E -hea

	change -fileheader -tota=65
	dump -bloc=27 -reco=E -hea

DSE_EOF
endif

echo "--------------------- Test 22 ---------------------"
# flush time field checked below
# try making this field, zero
# -flush_time with missing value should reset it to default
# give an invalid value for flush_time
# try setting it to zero
# try setting it to more than an hour, say 2 hours (720000 deci seconds)

$DSE << DSE_EOF
change -fileheader -flush_time=0
change -fileheader -flush_time=2
DSE_EOF

echo "--------------------- Test 23 ---------------------"
$DSE << DSE_EOF >& change.log
dump -fileheader
DSE_EOF

echo -n
$grep "Flush timer" change.log

echo "--------------------- Test 24 ---------------------"
$DSE << DSE_EOF
change -fileheader -flush_time=1:0
DSE_EOF

echo "--------------------- Test 25 ---------------------"
$DSE << DSE_EOF >& change.log
dump -fileheader
DSE_EOF

echo -n
$grep "Flush timer" change.log

echo "--------------------- Test 26 ---------------------"
$DSE << DSE_EOF
change -fileheader -flush_time
DSE_EOF

echo "--------------------- Test 27 ---------------------"
$DSE << DSE_EOF >& change.log
dump -fileheader
DSE_EOF

echo -n
$grep "Flush timer" change.log

echo "--------------------- Test 28 ---------------------"
$DSE << DSE_EOF
change -fileheader -flush_time=1:0:0:0
DSE_EOF

echo "--------------------- Test 29 ---------------------"
$DSE << DSE_EOF >& change.log
dump -fileheader
DSE_EOF

echo -n
$grep "Flush timer" change.log


echo "--------------------- Test 30 ---------------------"
$DSE << DSE_EOF
change -fileheader -flush_time=2.3
DSE_EOF

echo "--------------------- Test 31 ---------------------"
$DSE << DSE_EOF >& change.log
dump -fileheader
DSE_EOF

echo -n
$grep "Flush timer" change.log

echo "--------------------- Test 32 ---------------------"
$DSE << DSE_EOF >& change.log
dump -fileheader
DSE_EOF

echo "--------------------- Test 33 ---------------------"
$DSE << DSE_EOF
change -fileheader -flush_time=720000
DSE_EOF

echo "--------------------- Test 34 ---------------------"
$DSE << DSE_EOF >>& change.log
dump -fileheader
DSE_EOF

echo -n
$grep "Flush timer" change.log

echo "--------------------- Test 35 ---------------------"
# Test writes per flush and trigger flush qualifiers

$DSE << DSE_EOF
change -fileheader -write=10
change -fileheader -trig=2048
DSE_EOF

echo "--------------------- Test 36 ---------------------"
$DSE << DSE_EOF >& change.log
dump -fi
DSE_EOF

echo -n
$grep "Flush trigger" change.log

echo "--------------------- Test 37 ---------------------"
$DSE << DSE_EOF
change -fileheader -write=9
change -fileheader -trig=1024
DSE_EOF

echo "--------------------- Test 38 ---------------------"
$DSE << DSE_EOF >& change.log
dump -fi
DSE_EOF

echo -n
$grep "Flush trigger" change.log

# test for FREEZE included in crit.csh < process specific output >
# test for NULL_SUBSCRIPTS included in add.csh

# YET TO BE TESTED : TIMERS_PENDING

echo "--------------------- Test 39 ---------------------"
echo "# Test that MUPIP JOURNAL EXTRACT shows the DSE commands as AIMG records"
# Extracting from mumps.mjl and a.mjl
if ($?test_replic == 1) then
	foreach mjl( *.mjl )
		$ydb_dist/mupip journal -extract -detail -forward $mjl >>& extr_report.txt
		cat $mjl:r.mjf | grep "AIMG" | awk -F\\ '{print "AIMG "$11}'
	end
endif
$gtm_tst/com/dbcheck.csh

