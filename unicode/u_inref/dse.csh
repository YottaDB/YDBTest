#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
#=====================================================================
# This subtest will be called from instream when the test is not submitted with replication (and also when the test is
# submitted with -unicode, in which case it can be the only subtest). i.e. even if the test was not submitted with
# -unicode, this subtest will turn it on. This way, we will not have to add a new entry in the SUITE, and still have unicode testing.
#
# The test relies on dse dump of a block. So disable randon tn setting
setenv gtm_test_disable_randomdbtn 1
# override gtm_chset for this test
$switch_chset "UTF-8"
setenv gtm_badchar NO
# determine the endianness of the machine, to match the appropriate reference file
if ("BIG_ENDIAN" == "$gtm_endian") then
	set endian="big"
else
	set endian="little"
endif
#################
### SECTION 1 ###
#################
$echoline
echo "#- Block layouts and block splits."
#  When a block split happens, the split point (i.e. the key in the index block) is the mid-point of the two sides of
#  the split. This is a byte-based calculation, and will not change. Therefore, the split points (i.e. the keys in the
#  index blocks) might not be valid Unicode characters.
#  Let's test that the index block contents are analogous to the current behavior:
$gtm_tst/com/dbcreate.csh mumps -rec=256 -bl=512
$gtm_exe/mumps -run testblsplit
#
#  - verify the index blocks contents for all index blocks. Print the index blocks in the reference file.
# 	- for valid Unicode characters in the index blocks and data blocks, the characters should show correctly in
#	  the summary line (instead of dots: Rec:1  Blk 9  Off 10  Size F4  Cmpc 0  Key ^b("..."))
#	- for invalid characters, dots should be used.
$DSE dump -block=0 >&! dse_dump_block_0.out
set blkcnt=`$tst_awk -F"|" '/\|  X/ {i=i+gsub("X","X",$2)} END {print i}' dse_dump_block_0.out`
@ i = 1
while ( $i <= $blkcnt )
	set num=`$DSE eval -n=$i -d | & $tst_awk '/Hex:/{print $2}'`
	$DSE dump -block=$num >&! dump_$num.out
	$grep "Level 1" dump_$num.out >/dev/null
	if !($status) cat dump_$num.out >>&! dse_dump_level1.outx
	@ i = $i + 1
end
$tst_awk -f $gtm_tst/com/dse_filter_header.awk dse_dump_level1.outx >&!  dse_dump_level1.out
diff dse_dump_level1.out $gtm_tst/$tst/outref/dse_dump_level1_${endian}.txt
if ($status) then
	echo "TEST-E-ERROR, DSE dump of level 1 blocks incorrect"
else
	echo "TEST-I-PASS, DSE dump of level 1 blocks is correct"
endif

$gtm_tst/com/dbcheck.csh
mkdir section1
mv mumps.* section1/
#
$echoline
#################
### SECTION 2 ###
#################
echo "#- DSE DUMP"

$gtm_tst/com/dbcreate.csh mumps -bl=512
# comple unicodedbdata and filter out the %GTM-W-LITNONGRAPH, warnings
$gtm_exe/mumps -run unicodedbdata >&! unicodedbdata_with_warns.outx
$tst_awk -f $gtm_tst/com/filter_litnongraph.awk unicodedbdata_with_warns.outx

# move this script from 64bittn/u_inref to /com and take care of reverse impacts
source $gtm_tst/com/get_blks_to_upgrade.csh "" "default"
foreach chset("M" "UTF-8")
	setenv gtm_chset $chset
	# C9G10-002805 DSE DUMP -BLOCK -COUNT=2 does not work correctly for second block
	# Fix the below refernce files once the above TR is fixed.
	$DSE dump -block=1 -count=$calculated >&! dseunicode_dump_$chset.outx
	# The second line of the above ouput has database file name which is a variable, let's just chop it off and diff it.
	# Also the 1 byte filler in the record header structure (rec_hdr) on UNIX platform in uninitialized.
	# Due to this, the dse dump output will not be the same everytime.  Remove this filter and recreate the reference file once it is fixed
	$tst_awk -f $gtm_tst/com/dse_filter_header.awk dseunicode_dump_$chset.outx >&! dseunicode_dump_$chset.out
	# ICU 59.1 had fixes to the way a few unicode codepoints were displayed in a DSE DUMP -FILE output. An example diff follows.
	#
	#       ... : | .. .. .. .. 73 61 6D 70 6C 65 67 62 6C  0 FF E2 99 88 E2 99|
	# -           |  .  .  . ..  s  a  m  p  l  e  g  b  l  .  .        ♈      |	<-- Pre-ICU59.1
	# +           |  .  .  . ..  s  a  m  p  l  e  g  b  l  .  .       ♈      |	<-- ICU59.1 and onwards
	#        24 : | 89 E2 99 8A E2 99 8B E2 99 8C E2 99 8D E2 99 8E E2 99 8F E2|
	#
	# To work with systems which have ICU versions before and after 59.1, we maintain 2 reference files.
	# For example, in case of a little-endian machine, we maintain the below files
	#	dseunicode_dump_UTF-8_little.txt		--> For ICU versions >= 59.1
	#	dseunicode_dump_UTF-8_little_pre_ICU_59.txt	--> For ICU versions <  59.1
	# And choose the appropriate reference file based on the ICU version.
	#
	set reference_file = $gtm_tst/$tst/outref/dseunicode_dump_${chset}_${endian}.txt
	if (("UTF-8" == $chset) && (1 == `echo "if ($gtm_icu_version < 59.1) 1" | bc`)) then
		set reference_file = $gtm_tst/$tst/outref/dseunicode_dump_${chset}_${endian}_pre_ICU_59.txt
	endif
	$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/outref.awk dseunicode_dump_$chset.out $reference_file >&! dseunicode_dump_${chset}_${endian}.cmp
	diff dseunicode_dump_${chset}_${endian}.cmp dseunicode_dump_$chset.out
	if ($status) then
		echo "TEST-E-ERROR, DSE dump behavior on gtm_chset $chset incorrect"
	else
		echo "TEST-I-PASS, DSE dump behavior on gtm_chset $chset is correct"
	endif
	# Blocks with single record : 5,D
	# Few Index blocks : 4,25,27,29
	# Some interesting leaf blocks : 19, 1C,30
	$DSE << DSE_EOF >&! dse_dump_select_$chset.outx
		dump -block=5
		dump -block=E

		dump -block=4
		dump -block=25
		dump -block=27
		dump -block=29

		dump -block=19
		dump -block=22
		dump -block=6

		dump -block=2B -record=2 -count=6
		dump -block=29 -record=3
		dump -block=17 -offset=14B
		dump -block=12 -offset=24
DSE_EOF

	$tst_awk -f $gtm_tst/com/dse_filter_header.awk dse_dump_select_$chset.outx >&! dse_dump_select_$chset.out
	$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/outref.awk dse_dump_select_$chset.out $gtm_tst/$tst/outref/dse_dump_select_${chset}_${endian}.txt >&! dse_dump_select_${chset}_${endian}.cmp
	diff dse_dump_select_${chset}_${endian}.cmp  dse_dump_select_$chset.out
	if ($status) then
		echo "TEST-E-ERROR, DSE dump behavior for selected blocks/records on gtm_chset $chset incorrect"
	else
		echo "TEST-I-PASS, DSE dump behavior for selected blocks/records on gtm_chset $chset is correct"
	endif
end
#
$echoline
#################
### SECTION 3 ###
#################
echo "#- DSE OPEN"
$DSE << dse_eof
open -file=ｄｕｍｐ1.out
dump -block=22 -zwr
dump -block=6 -zwr
close
quit
dse_eof
#
echo "# Contents of ｄｕｍｐ1.out i.e dump of blocks 22 and 6 in zwr format"
cat ｄｕｍｐ1.out
#
$echoline
#################
### SECTION 4 ###
#################
echo "#- DSE OPEN and OCHSET"
#
echo "Error expected for the below DSE dump"
$DSE << dse_eof
dump -block=0 -zwr
open -file=ｄｕｍｐ3.out
dump -block=29 -zwr
dump -block=25 -zwr
close
dump -block=0 -glo
dse_eof
#
echo ""
if ("Linux" == $HOSTOS) then
	foreach chset ( M UTF-8 UTF-16 UTF-16LE UTF-16BE )
		# remove the "-" from utf strings for regualr MUPIP processing inside the scripts.
		set tmpch=`echo $chset|sed 's/-//'`
		foreach format ( ZWR )
			$gtm_tst/$tst/u_inref/dse_dump_zwr_glo.csh -format $format -outfile $tmpch"_"$format.out -dumpfile $tmpch"_"$format.dump -ochset $chset
		end
	end
endif
$echoline
#################
### SECTION 5 ###
#################
echo "#- DSE OVERWRITE"
echo "^testgbl before OVERWITE"
$GTM << eof
zwrite ^testgbl
eof

# In the global ^testgbl("０１２３４５_１"), change the 3rd byte of the "１" (efbc91 in utf8) character to 92, to make the character "２" (efbc92 in utf8):
# In the global set ^testgbl("1"), change the second byte of the character "ａ" (efbd81 in utf8) to bc to make the character a "！"
echo 'changing single byte on globals ^testgbl("０１２３４５_１") , ^testgbl(1)'
$DSE << eof
overwrite -block=2E -data="\92" -offset=FB
overwrite -block=2E -data="\bc" -offset=32
eof

echo ""
# In the global ^testgbl("０１２３４５_５"), change the 2nd & 3rd bytes of the last "５" (efbc95 in utf8) to bd8a to turn it into a "ｊ" (efbd8a in utf8)
echo 'changing two bytes on global ^testgbl("０１２３４５_５")'
$DSE << eof
overwrite -block=2E -data="\bd\8a" -offset=162
eof
#
# In the global ^testgbl("two byte chars")="ŞİŞLİ", change the first "İ", to "AA", to make it "ŞAAŞLİ" Change the second "Ş" to a "İ" to make it "ŞAAİLİ"
# In the global set ^testgbl("three byte chars"), correct the wrong spelling ("Ｘ*" to "ＦＵ")
# In the global ^testgbl("four byte char1"), change the four byte char U+E0100 to two two-byte chars "ŞŞ"
#
echo ""
echo 'changing a complete multi byte character ^testgbl("two byte chars")'
$DSE << eof
overwrite -block=2E -data="AA" -offset=CA
overwrite -block=2E -data="İ" -offset=CC
overwrite -block=2E -data="Ｆu" -offset=A4
overwrite -block=2E -data="ŞŞ" -offset=66
eof
#
echo ""
# In the global ^testgbl("four byte char2"), change the first two bytes of the 4 byte character to "av" and see the DUMP and ZWRITE outputs to validate
# (dots should be used in DUMP output, and $ZCHAR should be used in ZWRITE output)
#
echo "changing four byte character to something invalid"
$DSE << eof
overwrite -block=2E -data="av" -offset=73
dump -block=2E -record=3
eof
#
echo ""
echo 'changing the whole data completely for ^testgbl("０１２３４５_３")'
# A space in the data="" gives %GTM-E-CLIERR, Too many parameters. So use \20 instead
$DSE << eof
overwrite -block=2E -data="ａ\20ｎｅｗ\20ｄａｔａ\20\ef\bd\96ａｌ" -offset=11B
eof
#
echo ""
echo "^testgbl after OVERWITE"
$GTM << eof
zwrite ^testgbl
eof
#
$MUPIP integ -reg "*"
#
$echoline
#################
### SECTION 6 ###
#################
echo "#- DSE ADD"

$DSE << eof
add -block=2E -record=8 -key="^testgbl(""０１２３４５_４"",\$ZCHAR(251,12,200,198))" -data="data_444: ｄａｔａ＿４\ef\bc\94\ef\bc\94\ef\ef\ef\ef\bc\94"
add -bl=2E -rec=9 -key="^testgbl(""０１２３４５_４４４"",\$ZCHAR(239,188,148,239,188,148,239,188,148),\$CHAR(65345,65345))" -data="aaa  -- ａａａ"
eof
#
$MUPIP integ -reg "*"
set key='^testgbl(""０１２３４５_４４４"",""ａｂｃ"")'
$DSE << eof >&! dse_add_key.outx
add -block=2E -key="$key" -data="1234567" -record=A
dump -block=2E
eof
$tst_awk -f $gtm_tst/com/dse_filter_header.awk dse_add_key.outx >&! dse_add_key.out
diff dse_add_key.out $gtm_tst/$tst/outref/dse_add_key_${endian}.txt
if ($status) then
	echo "TEST-E-ERROR, DSE add key failed"
else
	echo "TEST-I-PASS, DSE add key passed"
endif
#
$GTM << eof
zwrite ^testgbl
eof
#
$MUPIP integ -reg "*"
#
$echoline
#################
### SECTION 7 ###
#################
echo "#- DSE FIND"
$DSE << eof
find -key="^testgbl(""０１２３４５_３"")"
find -key="^testgbl(""０１２３４５_４"",\$ZCHAR(251,12,200,198))"
find -key="^testgbl(""０１２３４５_４４４"",\$ZCHAR(239,188,148,239,188,148,239,188,148),\$CHAR(65345,65345))"
find -key="$key"
eof
#
echo ""
$echoline
#################
### SECTION 8 ###
#################
echo "#- DSE RANGE"
$DSE << eof
range -lower="^samplegbl(""ΒΑΕΖ"")" -upper="^samplegbl(""Τ"")"
range -lower="^samplegbl(""我"")" -upper="^samplegbl(""中"")"
range -lower="^samplegbl(\$CHAR(115))"
range -lower="^samplegbl(""yığ"")" -upper="^samplegbl(""yığın"")"
range -lower="^samplegbl(""чащах"")" -upper="^samplegbl(""цитрус"")"
range -lower="^samplegbl(-1)" -upper="^samplegbl(1)"
eof
#
# wrap up
echo ""
$gtm_tst/com/dbcheck.csh
#/media/sda3/testarea1/bahirs/V986/tst_V986_dbg_33_110130_170623/unicode_0/dse
