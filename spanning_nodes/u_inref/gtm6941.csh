#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################

# Test that the maximum record size is 1048576 and the key size can be larger than 255
# Encryption cannot support access method MM, so explicitly running the test with NON_ENCRYPT when acc_meth is MM

if ("MM" == $acc_meth) then
       setenv test_encryption NON_ENCRYPT
endif

echo "# Test 1: Test for max-record-size change. The maximum record size can reach 1048576, but not more"
$echoline
setenv gtmgbldir rsize.gld >& log0.log
$GDE << GDE_EXIT
	change -r default -r=1048576
	change -r default -r=1048577
    exit
GDE_EXIT
echo "============Test1 ends=========="

echo " "
cat << EOF
# Test 2: Test for key-size change
# The key size should be smaller than:
# block_size-reserved_bytes-block_header(16)-record_header(4)-min_value_size(4)-bstar_record(8)-hidden_subscript(8)
# In this test, block_size= 512, reserved_bytes=6, so key size should be smaller than 512-6-40=466
EOF
$echoline
$GDE << GDE_EXIT
	change -s default -bl=512
   	change -s default -r=6
	change -r default -k=467
	change -r default -k=466
	exit
GDE_EXIT
echo "============Test2 ends=========="

echo " "
cat << EOF
# Test 3: Test for reserved-bytes change
# Now key size is 466, we increase the reserved bytes to 8, verification failure expected
# Next we decrease the reserved bytes to 4, verification pass expected.
EOF
$echoline
$GDE << GDE_EXIT
    change -s default -r=8
    change -s default -r=4
	exit
GDE_EXIT
echo "============Test3 ends=========="

echo " "
cat << EOF
# Test 4: Test for maximum key size
#  Change the block size to maximum (65024), reduce the reserved bytes to minimum (0),
# so the maximum key can be min(65024-16-4-4-8-8=64988,1023)=1023
EOF
$echoline
$GDE << GDE_EXIT
    change -s default -bl=65024
    change -s default -r=0
    change -r default -k=1020
    change -r default -k=1019
	exit
GDE_EXIT
echo "============Test4 ends=========="

echo " "
cat << EOF
# Test 5: Test for block-size change
#  Change the key size to 467, change the block size to 1024, set the reserved bytes to 14,
#  Next change the block size to 512, the verification failure expected
EOF
$echoline
$GDE << GDE_EXIT
    change -r default -k=467
    change -s default -bl=1024
    change -s default -r=14
GDE_EXIT
$GDE << GDE_EXIT
    change -s default -bl=512
    change -s default -bl=1024
    exit
GDE_EXIT
echo "============Test5 ends=========="

echo " "
cat << EOF
# Test 6: Test for minimum record size, minimum key size
# Change the record size to -1, the verification failure expected
# Change the key size to 1, only the min key verfication failure appears
EOF
$echoline
$GDE << GDE_EXIT
    change -r default -r=-1
    change -r default -r=0
    change -r default -k=1
    exit
GDE_EXIT
echo "============Test6 ends=========="

echo ""
cat << EOF
# Test 7: Test for gde show output for large record size (more than 6 bits)
EOF
$echoline
$GDE << GDE_EXIT
    change -r default -r=100000
    show -r default
    change -r default -r=1000000
    show -r default
    change -r default -null=always
    show -r default
    template -r -r=100000
    show -t
    template -r -r=1000000
    show -t
    template -r -null=always
    show -t
    exit
GDE_EXIT
echo "============Test7 ends=========="
#==================================================================================================================================
