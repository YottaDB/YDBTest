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

# This script is used to create the base binary extracts that can be
# modified to be used by binloaderrors.csh. Once it has created
# the extracts it prints out the instructions for the required changes.
#
# This script has to be run on a machine of both endiannesses.
if ("BIG_ENDIAN" == "$gtm_endian") then
        set endian="big"
        set otherendian="little"
else
        set endian="little"
        set otherendian="big"
endif

$gtm_dist/mumps -r ^GDE << END >& m.log
change -segment DEFAULT -block_size=512 -global_buffer_count=9000 -file=mumps.dat
change -region DEFAULT -null_subscripts=always -stdnull -rec=1048576
END

$gtm_dist/mupip create >>& m.log

cat << END > base1.m
base1
	set ^a=1
	set ^b=2
	set ^c=3
	set ^d=4
	quit
END

$gtm_dist/mumps -r base1 >>& m.log

$gtm_dist/mupip extract -format=bin basecase1_${endian}.bin >>& m.log

cp basecase1_${endian}.bin case1a_${endian}.bin
cp basecase1_${endian}.bin case1b_${endian}.bin
cp basecase1_${endian}.bin case2a_${endian}.bin
cp basecase1_${endian}.bin case2b1_${endian}.bin

# start with a fresh database
rm mumps.dat
$gtm_dist/mupip create >>& m.log

# let us make a larger key which will give trouble when used with default value
$gtm_dist/dse ch -f -key=150 >>& m.log
cat << END > base2.m
base2
	set ^a("abcdefghij","abcdefghij","abcdefghij","abcdefghij","abcdefghij","abcdefghij","abcdefghij","abcdefghij")=1
	quit
END
$gtm_dist/mumps -r base2 >>& m.log
$gtm_dist/mupip extract -format=bin basecase2_${endian}.bin >>& m.log
cp basecase2_${endian}.bin case2b2_${endian}.bin

# start with a fresh database
rm mumps.dat >>& m.log
$gtm_dist/mupip create >>& m.log
cat << END > base3.m
base3
	set ^a="begin"_\$justify("end",2000)
	q
END
$gtm_dist/mumps -r base3 >>& m.log
$gtm_dist/mupip extract -format=bin basecase3_${endian}.bin >>& m.log
cp basecase3_${endian}.bin case2c1_${endian}.bin
cp basecase3_${endian}.bin case2c2_${endian}.bin
cp basecase3_${endian}.bin case2c3_${endian}.bin
cp basecase3_${endian}.bin case2c4_${endian}.bin
cp basecase3_${endian}.bin case2c5_${endian}.bin
cp basecase3_${endian}.bin case2c6_${endian}.bin
cp basecase3_${endian}.bin case2c7_${endian}.bin
cp basecase1_${endian}.bin case2d_${endian}.bin
cat << DONE
khexedit can be used to make the changes requested below

For case1a.bin:
Please make ^b's compression count = 5
by changing the short int at offset 0x80 to 5

For case1b.bin:
Please replace ^c's key terminator with "eg"
by changing the two bytes starting at 0x93 to "eg"

For case2a.bin:
Please make ^c's record length = 153
by changing the short int at offset 0x8e to 153

For case2b1.bin:
Please make ^b's record length = 108 (and the length of the block that contains ^b)
by changing the short ints at offset 0x7c and 0x7e to 108
Please add 25 copies of "abcd" to ^b's key
by changing by inserting "abcd" 25 times starting at offset 0x82

case2b2.bin is already to go.

For case2c1.bin:
Please change ^a(#SPAN3)'s key to ^a("nospan") and its value to "I am here!!"
by changing the bytes starting at offset 0x27f with 0xff "nospan" 0x0 0x0 "I am here!!"

For case2c2.bin:
Please change ^a(#SPAN3)'s key to ^b(#SPAN3)
by changing the byte at offset 0x27d to 'b'

For case2c3.bin:
Please change ^a(#SPAN3)'s key to ^a(#SPAN7)
by changing the byte at offset 0x281 to 7

For case2c4.bin:
Please change ^a(#SPAN1)'s expected number of payload chunks to two
by changing the short int at offset 0x7f to 2
Please change ^a(#SPAN1)'s expected size to 705
by changing the short int at offset 0x81 to 705
Please change ^a(#SPAN3)'s record size (and block size) to 247
by changing the short ints at offset 0x277 and 0x279 to 247
Please change the last bytes of ^a(#SPAN3) to "end"
by changing the three bytes starting at offset 0x36d to "end"
Please truncate the file to length 879

For case2c5.bin:"
Please change ^a(#SPAN1)'s expected number of payload chunks to two
by changing the short int at offset 0x7f to 2
Please change ^a(#SPAN1)'s expected size to 961
by changing the short int at offset 0x81 to 961
Please change ^a(#SPAN3)'s record size (and block size) to 247
by changing the short ints at offset 0x277 and 0x279 to 247
Please change the last bytes of ^a(#SPAN3) to "end"
by changing the three bytes starting at offset 0x36d to "end"
Please truncate the file to length 879

For case2c6.bin:
Please truncate the extract file to length 1966

For case2c7.bin:
Please change ^a(#SPAN3)'s key to ^a(#SPAN9)
by changing the byte at offset 0x473 to 9

For case2d.bin:
Please change ^c's record size (and block size) to 12
by changing the short ints at offset 0x8c and 0x8e to 12
Please change ^c's key to ^c(#SPAN48)
by adding, at offset 0x94, 0x02 0x01 0x30 0x00

Repeat on a ${otherendian} endian platform.
Thanks
DONE
