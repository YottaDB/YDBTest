#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

echo '\nTesting %DO, %OD, %HO and %OH conversion between DEC and OCT or HEX and OCT with valid input values'
$ydb_dist/yottadb -r gtm9115

echo '\nTesting %DO, %OD, %HO and %OH conversion for 64 bit and 32 bit MAX values'
$ydb_dist/yottadb -r mxvalinp^gtm9115

echo '\nTesting HEX to OCT conversion of MAX input value'
echo "Input: FFFFFFFFFFFFFFFF"
$ydb_dist/yottadb -r ^%XCMD 'set %HO="FFFFFFFFFFFFFFFF" do ^%HO write %HO,!'

echo '\nTesting OCT to HEX conversion of MAX input value'
echo "Input: 1777777777777777777777"
$ydb_dist/yottadb -r ^%XCMD 'set %OH="1777777777777777777777" do ^%OH write %OH,!'

echo '\nTesting OCT to DEC conversion of MAX input value'
echo "Input: 1777777777777777777777"
$ydb_dist/yottadb -r ^%XCMD 'set %OD="1777777777777777777777" do ^%OD write %OD,!'

echo '\nTesting DEC to OCT conversion of MAX input value which is 20 digit MAX unsigned 64bit value'
echo "Input: 18446744073709551615"
$ydb_dist/yottadb -r ^%XCMD 'set %DO="18446744073709551615" do ^%DO write %DO,!'

echo '\nTesting DEC to OCT conversion of MAX negative 64bit input value'
echo "Input: -9223372036854775808"
$ydb_dist/yottadb -r ^%XCMD 'set %DO="-9223372036854775808" do ^%DO write %DO,!'

echo '\nTesting ability of HEX to OCT conversion to handle case agnostic input with leading 0x'
echo "Input: 0xff"
$ydb_dist/yottadb -r ^%XCMD 'set %HO="0xff" do ^%HO write %HO,!'
echo "Input: 0Xff"
$ydb_dist/yottadb -r ^%XCMD 'set %HO="0Xff" do ^%HO write %HO,!'

echo '\nTesting ability of DEC to OCT conversion to ignore leading zeros for computation'
echo "Input: 000000000018446744073709551615"
$ydb_dist/yottadb -r ^%XCMD 'set %DO="000000000018446744073709551615" do ^%DO write %DO,!'

echo '\nTesting ability of HEX to OCT conversion to ignore leading zeros for computation'
echo "Input: 0000000000FFFFFFFFFFFFFFFF"
$ydb_dist/yottadb -r ^%XCMD 'set %HO="0000000000FFFFFFFFFFFFFFFF" do ^%HO write %HO,!'

echo '\nTesting ability of OCT to DEC conversion to ignore leading zeros for computation'
echo "Input: 000000000001777777777777777777777"
$ydb_dist/yottadb -r ^%XCMD 'set %OD="000000000001777777777777777777777" do ^%OD write %OD,!'

echo '\nTesting ability of OCT to HEX conversion to ignore leading zeros for computation'
echo "Input: 000000000001777777777777777777777"
$ydb_dist/yottadb -r ^%XCMD 'set %OH="000000000001777777777777777777777" do ^%OH write %OH,!'

echo '\nTesting mixed valued input (part of YDB#685 portion of test)'
$ydb_dist/yottadb -r mixedvalinp^gtm9115

echo '\nTesting that invalid characters at end of input are handled correctly (YDB#685),!'
echo "%OD Input: 778"
$ydb_dist/yottadb -r ^%XCMD 'write $$FUNC^%OD(778),!'
echo "%OD Input: 77A"
$ydb_dist/yottadb -r ^%XCMD 'write $$FUNC^%OD("77A"),!'
echo "%OH Input: 778"
$ydb_dist/yottadb -r ^%XCMD 'write $$FUNC^%OH(778),!'
echo "%OH Input: 77A"
$ydb_dist/yottadb -r ^%XCMD 'write $$FUNC^%OH("77A"),!'
echo "%DO Input: 512k"
$ydb_dist/yottadb -r ^%XCMD 'write $$FUNC^%DO("512k"),!'
echo "%DH Input: 512k"
$ydb_dist/yottadb -r ^%XCMD 'write $$FUNC^%DH("512k"),!'
echo "%HD Input: FFk"
$ydb_dist/yottadb -r ^%XCMD 'write $$FUNC^%HD("FFk"),!'
echo "%HO Input: FFk"
$ydb_dist/yottadb -r ^%XCMD 'write $$FUNC^%HO("FFk"),!'

echo '\nTesting %HO for very large HEX input'
echo "Input: 7FFFFFFFFFFFFFFFFFFFFFFFFFFFF"
$ydb_dist/yottadb -r ^%XCMD 'set %HO="7FFFFFFFFFFFFFFFFFFFFFFFFFFFF" do ^%HO write %HO,!'

echo '\nTesting %DO for very large DEC input'
echo "Input: 18446744073709551616"
$ydb_dist/yottadb -r ^%XCMD 'set %DO="18446744073709551616" do ^%DO write %DO,!'

echo '\nTesting %DO for very large negative DEC input'
echo "Input: -9223372036854775809"
$ydb_dist/yottadb -r ^%XCMD 'set %DO="-9223372036854775809" do ^%DO write %DO,!'

echo '\nTesting %OH for very large OCT input'
echo "Input: 77777777777777777777777777777777"
$ydb_dist/yottadb -r ^%XCMD 'set %OH="77777777777777777777777777777777" do ^%OH write %OH,!'

echo '\nTesting %OD for very large OCT input'
echo "Input: 77777777777777777777777777777777"
$ydb_dist/yottadb -r ^%XCMD 'set %OD="77777777777777777777777777777777" do ^%OD write %OD,!'

echo '\nTesting %DO and %OD for signed input value'
$ydb_dist/yottadb -r signedvalinp^gtm9115

echo '\nTesting correctness of current %DO vs previous %DO'
$ydb_dist/yottadb -r correctnessdectooct^gtm9115

echo '\nTesting correctness of current %OD vs previous %OD'
$ydb_dist/yottadb -r correctnessocttodec^gtm9115

echo '\nTesting correctness of current %HO vs previous %HO'
$ydb_dist/yottadb -r correctnesshextooct^gtm9115

echo '\nTesting correctness of current %OH vs previous %OH'
$ydb_dist/yottadb -r correctnessocttohex^gtm9115

echo '\nTesting that %HO rejects input starting with negative sign and returns null'
$ydb_dist/yottadb -r horejectsignedinput^gtm9115

echo '\nTesting if default length of output for current %DO is still twelve digits like the pre-V6.3-009 implementation'
$ydb_dist/yottadb -r defaultlenval^gtm9115

echo '\nTesting invalid input expecting error as output from %DO, %OD, %OH and %HO'
$ydb_dist/yottadb -r ^%XCMD 'write $$FUNC^%DO(,10)'
$ydb_dist/yottadb -r ^%XCMD 'write $$FUNC^%OD()'
$ydb_dist/yottadb -r ^%XCMD 'write $$FUNC^%OH()'
$ydb_dist/yottadb -r ^%XCMD 'write $$FUNC^%HO()'

echo '\nTesting null input on %HO, $OH, %OD and %DO'
$ydb_dist/yottadb -r nullvalinp^gtm9115
