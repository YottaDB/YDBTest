#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Disable use of V6 DB mode by using a random V6 version to create the DBs to prevent warning coming out of
# MUPIP CREATE that causes problems for this test (GTM-W-MUNOSTRMBKUP).
setenv gtm_test_use_V6_DBs 0

source $gtm_tst/com/set_random_limits.csh

# Ensure that the record size is large enough to cause block spans.
if ($RAND_RECORD_SIZE < $RAND_BLOCK_SIZE) then
    @ RAND_RECORD_SIZE = $RAND_BLOCK_SIZE
endif

# Ensure that the key size is large enough to accommodate a single-character variable with a single-character subscript.
if ($RAND_KEY_SIZE < 8) then
    @ RAND_KEY_SIZE = 8
endif

$gtm_tst/com/dbcreate.csh mumps 1 $RAND_KEY_SIZE $RAND_RECORD_SIZE $RAND_BLOCK_SIZE 1024 $RAND_GLOBAL_BUFFER_COUNT >&! dbcreate.outx
$grep "YDB-W-MUNOSTRMBKUP" dbcreate.out >&! test.debug
if ( 0 == $status ) then
	mv dbcreate.out dbcreate.out_bkup
endif

echo "Flags status, after database is created"
$DSE dump -f |& $grep "Spanning Node Absent" |& $tst_awk '{print $4}'
$DSE dump -f |& $grep "Maximum Key Size Assured" |& $tst_awk '{print $9}'
echo

$GTM <<EOF
set ^x=1
EOF

echo "Flags status, after adding normal node"
$DSE dump -f |& $grep "Spanning Node Absent" |& $tst_awk '{print $4}'
$DSE dump -f |& $grep "Maximum Key Size Assured" |& $tst_awk '{print $9}'
echo

$GTM <<EOF
set ^y=\$j(" ",$RAND_RECORD_SIZE)
EOF

echo "Flags status, after adding spanning node"
$DSE dump -f |& $grep "Spanning Node Absent" |& $tst_awk '{print $4}'
$DSE dump -f |& $grep "Maximum Key Size Assured" |& $tst_awk '{print $9}'
echo

@ sub_range = $RAND_KEY_SIZE - 7
@ sublen = `$gtm_exe/mumps -run rand $sub_range 1 3`

echo "Length of the subscript will be $sublen"
$GTM <<EOF
set tmp=\$\$^%RANDSTR($sublen)
set ^y(tmp)=\$j(" ",10)
EOF

echo "Flags status, after adding another node"
$DSE dump -f |& $grep "Spanning Node Absent" |& $tst_awk '{print $4}'
$DSE dump -f |& $grep "Maximum Key Size Assured" |& $tst_awk '{print $9}'
echo

$DSE change -fileheader -key_max_size=$sublen

echo "Flags status, after reducing keysize less than maximum of the lengths of keys present in the DB"
$DSE dump -f |& $grep "Spanning Node Absent" |& $tst_awk '{print $4}'
$DSE dump -f |& $grep "Maximum Key Size Assured" |& $tst_awk '{print $9}'
echo

$GTM <<EOF
kill ^x
kill ^y
EOF

$MUPIP integ -reg "*" -noonline >&! integ.outx
#Mupip integ should set the value of "Spanning Node Absent" and "Maximum Key Size Assured" flag correctly'
echo "Flags status, after MUPIP INTEG"
$DSE dump -f |& $grep "Spanning Node Absent" |& $tst_awk '{print $4}'
$DSE dump -f |& $grep "Maximum Key Size Assured" |& $tst_awk '{print $9}'
echo

$gtm_tst/com/dbcheck.csh
