#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Verify that binary load handle various errors in the extract file

# Note: mkbasebinextracts.csh can be used to create the needed binary extracts.
# It needs to be run on two machines (one of each endianness). It will
# give instructions on how the base binary extracts it generates need to
# be changed.

$switch_chset "M"

if ("BIG_ENDIAN" == "$gtm_endian") then
        set endian="big"
else
        set endian="little"
endif

cp $gtm_tst/spanning_nodes/u_inref/*_${endian}.bin .

# These were the gde parameters that were used to create the extracts
$GDE << gde_exit
change -segment DEFAULT -block_size=512 -global_buffer_count=9000 -file=mumps.dat
change -region DEFAULT -null_subscripts=always -stdnull -rec=1048576
exit
gde_exit

$MUPIP create

# Error cases
# 1) First record in block
#   a) compression count is > 0
#   b) key does not terminate before end of record
# 2) For a record containing a global (either user-visible global or chunk of a spanning node)
#   a) rec_len points beyond top of block (btop)
#   b) while copying key from record (looking for end of key)
#     (1) key does not terminate before the end of the record (rp + rec_len)
#     (2) key length > max key len for region
#   c) while building a spanning node
#     (1) find a non-spanning record
#     (2) find a chunk from another spanning node
#     (3) expecting chunk x but record contains chunk y
#     (4) adding the next chunk makes that value larger than the expected value
#     (5) found the expected number of chunks but lengths don't add up to expected value
#     (6) extract file terminates before a spanning node's value has been completely reconstituted
#     (7) verify that the kill of the beacon node (when we encounter an incomplete spanning node)
#       does not remove any children. For example, have a child already in the database before
#       the load since the only way (due to the order of the keys) to have a child from the
#       load present is to have a std coll null (it would be between the beacon node and the
#       spanning node).
#   d) while not building a spanning node encounter a spanning node chunk

echo "Running binary load test cases"
echo ""
echo ""
echo "Test case 1a - Compression count > 0 on first record in a block"
$gtm_dist/mupip load -for=bin -onerror=proceed case1a_${endian}.bin >& case1a_${endian}.outx
diff $gtm_tst/$tst/outref/case1a_${endian}.txt case1a_${endian}.outx
if (! $status) echo "PASS"
echo ""
echo "Test case 1b - Key does not terminate before end of record"
rm mumps.dat
$gtm_dist/mupip create
$gtm_dist/mupip load -for=bin -onerror=proceed case1b_${endian}.bin >& case1b_${endian}.outx
diff $gtm_tst/$tst/outref/case1b_${endian}.txt case1b_${endian}.outx
if (! $status) echo "PASS"
echo ""
echo "Test case 2a - Record length points beyond top of block"
rm mumps.dat
$gtm_dist/mupip create
$gtm_dist/mupip load -for=bin -onerror=proceed case2a_${endian}.bin >& case2a_${endian}.outx
diff $gtm_tst/$tst/outref/case2a_${endian}.txt case2a_${endian}.outx
if (! $status) echo "PASS"
echo ""
echo "Test case 2b1 - Key does not terminate before end of record"
rm mumps.dat
$gtm_dist/mupip create
$gtm_dist/mupip load -for=bin -onerror=proceed case2b1_${endian}.bin >& case2b1_${endian}.outx
diff $gtm_tst/$tst/outref/case2b1_${endian}.txt case2b1_${endian}.outx
if (! $status) echo "PASS"
echo ""
echo ""
echo "Test case 2b2 - Key length > max key length for region"
rm mumps.dat
$gtm_dist/mupip create
$gtm_dist/mupip load -for=bin -onerror=proceed case2b2_${endian}.bin >& case2b2_${endian}.outx
diff $gtm_tst/$tst/outref/case2b2_${endian}.txt case2b2_${endian}.outx
if (! $status) echo "PASS"
echo ""
echo "Test case 2c1 - While building a spanning node find a non-spanning record"
rm mumps.dat
$gtm_dist/mupip create
$gtm_dist/mupip load -for=bin -onerror=proceed case2c1_${endian}.bin >& case2c1_${endian}.outx
diff $gtm_tst/$tst/outref/case2c1_${endian}.txt case2c1_${endian}.outx
if (! $status) echo "PASS"
$gtm_dist/mumps -direct << END
w \$get(^a("nospan"))
h
END
echo ""
echo "Test case 2c2 - While building a spanning node find a chunk from another spanning node"
rm mumps.dat
$gtm_dist/mupip create
$gtm_dist/mupip load -for=bin -onerror=proceed case2c2_${endian}.bin >& case2c2_${endian}.outx
diff $gtm_tst/$tst/outref/case2c2_${endian}.txt case2c2_${endian}.outx
if (! $status) echo "PASS"
echo ""
echo "Test case 2c3 - While building a spanning node expected chunk x but found chunk y"
rm mumps.dat
$gtm_dist/mupip create
$gtm_dist/mupip load -for=bin -onerror=proceed case2c3_${endian}.bin >& case2c3_${endian}.outx
diff $gtm_tst/$tst/outref/case2c3_${endian}.txt case2c3_${endian}.outx
if (! $status) echo "PASS"
echo ""
echo "Test case 2c4 - While building a spanning node adding the next chunk makes value longer than expected"
rm mumps.dat
$gtm_dist/mupip create
$gtm_dist/mupip load -for=bin -onerror=proceed case2c4_${endian}.bin >& case2c4_${endian}.outx
diff $gtm_tst/$tst/outref/case2c4_${endian}.txt case2c4_${endian}.outx
if (! $status) echo "PASS"
echo ""
echo "Test case 2c5 - While building a spanning node have all chunks but value is not expected length"
rm mumps.dat
$gtm_dist/mupip create
$gtm_dist/mupip load -for=bin -onerror=proceed case2c5_${endian}.bin >& case2c5_${endian}.outx
diff $gtm_tst/$tst/outref/case2c5_${endian}.txt case2c5_${endian}.outx
if (! $status) echo "PASS"
echo ""
echo "Test case 2c6 - While building a spanning node extract file terminates"
rm mumps.dat
$gtm_dist/mupip create
$gtm_dist/mupip load -for=bin -onerror=proceed case2c6_${endian}.bin >& case2c6_${endian}.outx
diff $gtm_tst/$tst/outref/case2c6_${endian}.txt case2c6_${endian}.outx
if (! $status) echo "PASS"
echo ""
echo "Test case 2c7 - Verify that a child of the beacon node is not deleted when an incomplete spanning node is found"
rm mumps.dat
$gtm_dist/mupip create
$gtm_dist/mumps -direct << END
s ^a(1)="hope I am still here!!!"
h
END
$gtm_dist/mupip load -for=bin -onerror=proceed case2c7_${endian}.bin >& case2c7_${endian}.outx
diff $gtm_tst/$tst/outref/case2c7_${endian}.txt case2c7_${endian}.outx
if (! $status) echo "PASS"
$gtm_dist/mumps -direct << END
w \$get(^a(1))
h
END
echo ""
echo "Test case 2d - Encounter an errant spanning node chunk while not building a spanning node"
rm mumps.dat
$gtm_dist/mupip create
$gtm_dist/mupip load -for=bin -onerror=proceed case2d_${endian}.bin >& case2d_${endian}.outx
diff $gtm_tst/$tst/outref/case2d_${endian}.txt case2d_${endian}.outx
if (! $status) echo "PASS"
