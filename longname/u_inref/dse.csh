#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

# Since the reference file for this test has "SUSPEND_OUTPUT 4G_ABOVE_DB_BLKS" usage, it needs to fixate
# the value of the "ydb_test_4g_db_blks" env var in case it is randomly set by the test framework to a non-zero value.
if (0 != $ydb_test_4g_db_blks) then
	echo "# Setting ydb_test_4g_db_blks env var to a fixed value as reference file has 4G_ABOVE_DB_BLKS usages" >> settings.csh
	setenv ydb_test_4g_db_blks 8388608
endif

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

# this test has explicit mupip creates, so let's not do anything that will have to be repeated at every mupip create
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_use_V6_DBs 0	  		# Disable V6 DB mode due to differences in MUPIP INTEG and various DSE command outputs
setenv gtm_test_disable_randomdbtn
$gtm_tst/com/dbcreate.csh . -key=200
echo "Use basfill for dse add and dse find"
$GTM << EOF
write "do ^basfill",! do ^basfill
halt
EOF
#
@ i = 3
set key="^Aa"
while ($i < $maxlen)
	@ num = $i % 10
	set key="$key""$num"
	@ i = $i + 1
end
set key1="$key(0,2)"
set key2="$key(0,1,3)"
set key3="$key"'(""a"",2)'
set key4="$key"'(""efgh"",2)'
set key5="$key"'(""abcd"",2)'
set | $grep "^key"
# dse add
echo "DSE ADD"
$DSE add -block=6F -offset=35 -key="$key1" -data="firstnewadd"
$DSE add -block=6F -offset=35 -key="$key2" -data="secondnewadd"
# offset poition 69 & 7F are calculated based on the current offset position (prior to the set) + block size
$DSE << EOF
add -block=6F -offset=69 -key="$key3" -data="thirdnewadd"
add -block=6F -offset=7F -key="$key4" -data="fourthnewadd"
add -block=6F -offset=7F -key="$key5" -data="fifthnewadd"
dump -block=6F
EOF
$DSE integ -block=6F
$MUPIP integ -region "*"
echo "End DSE ADD"
#
# dse find
echo "DSE FIND"
@ i = 3
set key="^Ed"
while ($i < $maxlen)
	@ num = $i % 10
	set key="$key""$num"
	@ i = $i + 1
end
@ overlen = $maxlen + 1
@ num = $overlen % 10
set key0 = "$key""$num"
@ num = $maxlen % 10
set key="$key""$num"
set key1="$key""(1)"
set key2="$key""(1,2)"
set key4="$key""(2)"
set key5="$key""b"
set key6="$key""b(1)"
set key7="$key""b(1,2)"

set | $grep "^key"

set echo
set verbose

echo "Expected: Key not found, no root present"
$DSE find -key="^ZeVCj0Ho"
$DSE find -key="^EE6y0sUmOgIaC4wYqSkMeG8A2uWoQiK"
$DSE find -key="$key0"
echo "Expected: Key found in block ..."
$DSE find -key="$key"
$DSE find -key="$key1"
$DSE find -key="$key5"
$DSE find -key="$key6"
echo "Expected: Key not found, would be in block ..."
$DSE find -key="$key2"
$DSE find -key="$key4"
$DSE find -key="$key7"

#the following commands with a bad region/keys should not blow up
$DSE find -region=abcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcd
$DSE find -key="^AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"

unset echo
unset verbose

echo "End DSE FIND"
#
# dse dump
echo "DSE DUMP"
$DSE dump -block=3
$DSE dump -block=17
$DSE dump -block=214
echo "End DSE DUMP"
#
# use lotsvar.m for dse range
$GTM << EOF
  write "do set^lotsvar",! do set^lotsvar
  write "do ver^lotsvar",! do ver^lotsvar
  halt
EOF
echo "Start DSE RANGE"

$GTM << EOF
for i=1:1:1000 set ^ZZTESTGLOBALFORRANGECOMMAND8901(i)=i_\$JUSTIFY(i,i#200)_i
for i=1:1:1000 set ^ZZTESTGLO(i)=i_\$JUSTIFY(i,i#200)_i
halt
EOF
set echo

echo "nonexistent range"
$DSE range -lower="^abcdefgh" -upper="^abcdefghi"

echo "existing ranges"
$DSE range -lower="^Ee34567890123456789012345678901" -upper="^Ee345678a"
$DSE range -lower="^Ee345678" -upper="^Ee34567890123456789012345678901"
$DSE range -lower="^%w3A7EbIfMjQnUrYv2z6D" -upper="^A91TLDvnf7ZRJBtld5XPHzrjb3VNF"
set lower1 = '"^AkRoVsZw3A7EbIfMjQnUrYv2z6D(1,""AkRoVsZw3A7EbIfMjQnUrYv2z6D"",2,1298)"'
set upper1 = '"^AkmoqsuwyACEGIKMOQSUWY02468(1,""AkmoqsuwyACEGIKMOQSUWY02468"",2,337)"'
set lower2 = '"^AjTt3DdNnXx7HhRr1B(1,""AjTt3DdNnXx7HhRr1B"",2)"'
$DSE range -lower=$lower1 -upper=$upper1
$DSE range -lower=$lower2 -upper=$upper1

$DSE range -lower="^ZZTESTGLOBALFORRANGECOMMAND8901" -upper="^ZZTESTGLOBALFORRANGECOMMAND8901(100)" >& range_ZZ1.out
$DSE range -lower="^ZZTESTGLOBALFORRANGECOMMAND8901(51)" -upper="^ZZTESTGLOBALFORRANGECOMMAND8901(88)" >& range_ZZ2.out
$DSE range -lower="^ZZTESTGLOBALFORRANGECOMMAND8901(52)" -upper="^ZZTESTGLOBALFORRANGECOMMAND8901(87)" >& range_ZZ3.out
$DSE range -lower="^ZZTESTGLOBALFORRANGECOMMAND8901(53)" -upper="^ZZTESTGLOBALFORRANGECOMMAND8901(86)" >& range_ZZ4.out
#
# The hard coded values above ensures that we test the exact boundary conditions of the global variable.
# The block layout for the ranges above will be as
# range_ZZ1    ^ZZ  - ^ZZ(100)
#        2      51 -      88
#        3      52 -      87
#        4      53 -      86
#
cat range_ZZ1.out
cat range_ZZ2.out
cat range_ZZ3.out
cat range_ZZ4.out

unset echo

$DSE find -key="^ZZTESTGLOBALFORRANGECOMMAND8901"	>& ZZ.out

set blockZZ    = `$tail -n 1 ZZ.out | $tst_awk '{x=$NF; gsub(/:.*/,"",x); print x}'`

# foreach values below determines the env. variable names that gets set with the boundary range values.
# they are chosen based on the DSE range command values above. (51,52 especially)
foreach subs (3 34 35 51 52 66 77 87 100)
	$DSE find -key="^ZZTESTGLOBALFORRANGECOMMAND8901($subs)" >& ZZ$subs.out
	set blockZZ$subs = `$tail -n 1 ZZ$subs.out | $tst_awk '{x=$NF; gsub(/:.*/,"",x); print x}'`
end
set | $grep blockZZ

echo "Although a range specified might span certain blocks, because of the"
echo 'definition of range ("all blocks whose first key falls within the range"), some blocks will'
echo "not be listed in the output of DSE RANGE."

#check range_ZZ1
echo "All should be in ^ZZTESTGLOBALFORRANGECOMMAND8901 - ^ZZTESTGLOBALFORRANGECOMMAND8901(100) range"
foreach bl ($blockZZ $blockZZ3 $blockZZ34 $blockZZ35 $blockZZ52 $blockZZ66 $blockZZ77 $blockZZ87 $blockZZ100)
	$grep $bl range_ZZ1.out > /dev/null
	if ($status) echo "TEST-E-RANGE Block $bl not seen in range_ZZ1.out"
end

$gtm_tst/com/grepfile.csh "$blockZZ "    range_ZZ2.out 0
$gtm_tst/com/grepfile.csh "$blockZZ51 "  range_ZZ2.out 0
$gtm_tst/com/grepfile.csh "$blockZZ52 "  range_ZZ2.out 1
$gtm_tst/com/grepfile.csh "$blockZZ87 "  range_ZZ2.out 1
$gtm_tst/com/grepfile.csh "$blockZZ100 " range_ZZ2.out 0
#check range_ZZ3
$gtm_tst/com/grepfile.csh "$blockZZ "    range_ZZ3.out 0
$gtm_tst/com/grepfile.csh "$blockZZ51 "  range_ZZ3.out 0
$gtm_tst/com/grepfile.csh "$blockZZ52 "  range_ZZ3.out 1
$gtm_tst/com/grepfile.csh "$blockZZ87 "  range_ZZ3.out 1
$gtm_tst/com/grepfile.csh "$blockZZ100 " range_ZZ3.out 0
#check range_ZZ4
$gtm_tst/com/grepfile.csh "$blockZZ "    range_ZZ4.out 0
$gtm_tst/com/grepfile.csh "$blockZZ51 "  range_ZZ4.out 0
$gtm_tst/com/grepfile.csh "$blockZZ52 "  range_ZZ4.out 0
$gtm_tst/com/grepfile.csh "$blockZZ66 "  range_ZZ4.out 1
$gtm_tst/com/grepfile.csh "$blockZZ77 "  range_ZZ4.out 1
$gtm_tst/com/grepfile.csh "$blockZZ87 "  range_ZZ4.out 0
$gtm_tst/com/grepfile.csh "$blockZZ100 " range_ZZ4.out 0

###################
$gtm_tst/com/backup_dbjnl.csh bak "*.dat *.gld *.out" mv

$GDE << EOF
@$gtm_tst/$tst/inref/gdelong4.gde
EOF
if( "ENCRYPT" == $test_encryption ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
$MUPIP create
set echo
$DSE find -region=A234567890123456789012345678901
$DSE find -region=A23456789012345678901234567890
echo "there is no region A2345678901234567890123456789:"
$DSE find -region=A2345678901234567890123456789
$DSE find -region=A234567890123456
$DSE find -region=A2345678
$DSE find -region=A
unset echo
$gtm_tst/com/dbcheck.csh
