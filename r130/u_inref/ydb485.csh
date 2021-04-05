#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2019-2021 YottaDB LLC and/or its subsidiaries.  #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
# This tests $ZCONVERT with 3 arguments to ensure correct decimal to hexadecimal and vice versa conversion

echo '\nTesting $ZCONVERT conversion between DEC and HEX with valid input values'
$ydb_dist/yottadb -r zconvert

echo '\nTesting $ZCONVERT conversion of DEC to HEX and HEX to DEC for 64 bit and 32 bit MAX values'
$ydb_dist/yottadb -r mxvalinp^zconvert

echo '\nTesting $ZCONVERT HEX to DEC conversion of MAX input value'
echo "Input: FFFFFFFFFFFFFFFF"
$ydb_dist/yottadb -r ^%XCMD 'write $ZCONVERT("FFFFFFFFFFFFFFFF","HEX","DEC"),!'

echo '\nTesting $ZCONVERT DEC to HEX conversion of MAX input value which is 20 digit MAX unsigned 64bit value'
echo "Input: 18446744073709551615"
$ydb_dist/yottadb -r ^%XCMD 'write $ZCONVERT("18446744073709551615","DEC","HEX"),!'

echo '\nTesting $ZCONVERT DEC to HEX conversion of MAX -ve 64bit input value'
echo "Input: -9223372036854775808"
$ydb_dist/yottadb -r ^%XCMD 'write $ZCONVERT("-9223372036854775808","DEC","HEX"),!'

echo '\nTesting ability of $ZCONVERT HEX to DEC to handle case agnostic input with leading 0x'
echo "Input: 0xff"
$ydb_dist/yottadb -r ^%XCMD 'write $ZCONVERT("0xff","HEX","DEC"),!'
echo "Input: 0Xff"
$ydb_dist/yottadb -r ^%XCMD 'write $ZCONVERT("0Xff","HEX","DEC"),!'

echo '\nTesting ability of $ZCONVERT DEC to HEX conversion to ignore leading zeros for computation'
echo "Input: 000000000018446744073709551610"
$ydb_dist/yottadb -r ^%XCMD 'write $ZCONVERT("000000000018446744073709551610","DEC","HEX"),!'

echo '\nTesting ability of $ZCONVERT HEX to DEC conversion to ignore leading zeros for computation'
echo "Input: 0000000000FFFFFFFFFFFFFFFF"
$ydb_dist/yottadb -r ^%XCMD 'write $ZCONVERT("0000000000FFFFFFFFFFFFFFFF","HEX","DEC"),!'

echo '\nTesting ability of $ZCONVERT to handle case agnostic category input of DEC and HEX'
echo "Input: 15, Dec, hex"
$ydb_dist/yottadb -r ^%XCMD 'write $ZCONVERT("15","Dec","hex"),!'
echo "Input: F, HEX,dec"
$ydb_dist/yottadb -r ^%XCMD 'write $ZCONVERT("F","HEX","dec"),!'

echo '\nTesting mixed valued input on $ZCONVERT'
$ydb_dist/yottadb -r mixedvalinp^zconvert

echo '\nTesting $ZCONVERT for larger than acceptable HEX input'
echo "Input: 7FFFFFFFFFFFFFFFFFFFFFFFFFFFF"
$ydb_dist/yottadb -r ^%XCMD 'write $ZCONVERT("7FFFFFFFFFFFFFFFFFFFFFFFFFFFF","HEX","DEC"),!'

echo '\nTesting $ZCONVERT for larger than acceptable DEC input'
echo "Input: 18446744073709551616"
$ydb_dist/yottadb -r ^%XCMD 'write $ZCONVERT("18446744073709551616","DEC","HEX"),!'

echo '\nTesting $ZCONVERT for larger than acceptable -ve DEC input'
echo "Input: -9223372036854775809"
$ydb_dist/yottadb -r ^%XCMD 'write $ZCONVERT("-9223372036854775809","DEC","HEX"),!'

echo '\nTesting $ZCONVERT, %DH and %HD for signed input value'
$ydb_dist/yottadb -r signedvalinp^zconvert

echo '\nTesing larger than MAX $ZCONVERT supported value(>20 digits) conversion using %DH'
echo "Input: 184467440737095516155"
$ydb_dist/yottadb -r ^%XCMD 'write "Output: ",$$FUNC^%DH("184467440737095516155",10)'

echo '\nTesing larger than $ZCONVERT supported value conversion using %HD'
echo "Input: 7FFFFFFFFFFFFFFFFFFFFFFFFFFFF"
$ydb_dist/yottadb -r ^%XCMD 'write "Output: ",$$FUNC^%HD("7FFFFFFFFFFFFFFFFFFFFFFFFFFFF")'

if ("HOST_LINUX_ARMVXL" != $gtm_test_os_machtype) then
	# The performance checks are disabled on ARMV6L and ARMV7L to avoid occassional failures
	# due to the slowness of these machines. They previously passed consistently with 15 second
	# intervals but can occasionally fail at 5 seconds.
	echo '\nTesting performance of current %DH vs previous %DH'
	$ydb_dist/yottadb -r compdectohex^zconvert

	echo '\nTesting Performance of current %HD vs previous %HD'
	$ydb_dist/yottadb -r comphextodec^zconvert
endif

echo '\nTesting correctness of current %DH vs previous %DH'
$ydb_dist/yottadb -r correctnessdectohex^zconvert

echo '\nTesting correctness of current %HD vs previous %HD'
$ydb_dist/yottadb -r correctnesshextodec^zconvert

echo '\nTesting property of previous and current %HD to reject input starting with -ve sign and return null'
$ydb_dist/yottadb -r hdrejectsignedinput^zconvert

echo '\nTesting if current %DH defaults the length of its output to eight digits like old implementation'
$ydb_dist/yottadb -r defaultlenval^zconvert

echo '\nTesting invalid input expecting error as output from %DH and %HD'
$ydb_dist/yottadb -r ^%XCMD 'write $$FUNC^%DH(,10)'
$ydb_dist/yottadb -r ^%XCMD 'write $$FUNC^%HD()'

echo '\nTesting null input on %HD and %DH'
$ydb_dist/yottadb -r nullvalinp^zconvert

echo '\nTesting $ZCONVERT to not produce negative length result'
$ydb_dist/yottadb -r neglengthresult^zconvert

echo '\nTesting border cases in conversion'
$ydb_dist/yottadb -r ^%XCMD 'write "DEC to HEX Input:-9 ","Output: ",$ZCONVERT("-9","DEC","HEX"),!'
$ydb_dist/yottadb -r ^%XCMD 'write "DEC to HEX Input:-1 ","Output: ",$ZCONVERT("-1","DEC","HEX"),!'
$ydb_dist/yottadb -r ^%XCMD 'write "%DH Input:-9 ","Output: ",$$FUNC^%DH("-9"),!'
$ydb_dist/yottadb -r ^%XCMD 'write "%DH Input:-1 ","Output: ",$$FUNC^%DH("-1"),!'
$ydb_dist/yottadb -r ^%XCMD 'write "DEC to HEX Input:asdf ","Output: ",$ZCONVERT("asdf","DEC","HEX"),!'
$ydb_dist/yottadb -r ^%XCMD 'write "HEX to DEC Input:uiop ","Output: ",$ZCONVERT("uiop","HEX","DEC"),!'
$ydb_dist/yottadb -r ^%XCMD 'write "DEC to HEX Input:"""" ","Output: ",$ZCONVERT("","DEC","HEX"),!'
$ydb_dist/yottadb -r ^%XCMD 'write "HEX to DEC Input:"""" ","Output: ",$ZCONVERT("","HEX","DEC"),!'
$ydb_dist/yottadb -r ^%XCMD 'write "DEC to HEX Input:0 ","Output: ",$ZCONVERT("0","DEC","HEX"),!'
$ydb_dist/yottadb -r ^%XCMD 'write "HEX to DEC Input:0 ","Output: ",$ZCONVERT("0","HEX","DEC"),!'
$ydb_dist/yottadb -r ^%XCMD 'write "%DH Input:0 ","Output: ",$$FUNC^%DH("0"),!'
$ydb_dist/yottadb -r ^%XCMD 'write "%HD Input:0 ","Output: ",$$FUNC^%HD("0"),!'


echo '\nTesting $ZCONVERT for invalid category input in non-utf mode\n'
setenv gtm_test_unicode "FALSE"
$switch_chset "M"
$ydb_dist/yottadb -r ^%XCMD 'write "DEC to DEC Input:-9 ","Output: ",$ZCONVERT("-9","DEC","DEC"),!'
$ydb_dist/yottadb -r ^%XCMD 'write "HEX to HEX Input:-9 ","Output: ",$ZCONVERT("-9","HEX","HEX"),!'
$ydb_dist/yottadb -r ^%XCMD 'write "UTF-8 to HEX Input:-9 ","Output: ",$ZCONVERT("-9","UTF-8","HEX"),!'

echo '\nTesting $ZCONVERT for invalid category input in utf mode\n'
setenv gtm_test_unicode "TRUE"
$switch_chset "UTF-8"
$ydb_dist/yottadb -r ^%XCMD 'write "DEC to DEC Input:-9 ","Output: ",$ZCONVERT("-9","DEC","DEC"),!'
$ydb_dist/yottadb -r ^%XCMD 'write "HEX to HEX Input:-9 ","Output: ",$ZCONVERT("-9","HEX","HEX"),!'
$ydb_dist/yottadb -r ^%XCMD 'write "UTF-8 to HEX Input:-9 ","Output: ",$ZCONVERT("-9","UTF-8","HEX"),!'

