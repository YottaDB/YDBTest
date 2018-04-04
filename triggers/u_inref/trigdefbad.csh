#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Test various incarnations of YDB-E-TRIGDEFBAD. The error is issued whenever the integrity of the trigger global is in suspect
# Some instances are: If the ^#t exists, but #TRIGNAME is missing. This is unexpected since, we expect MUPIP TRIGGER to have
# properly filled the #TRIGNAME.

# Some aliases for easy operation
alias reload_db 'cp mumps.bak mumps.dat'

# this test intentionally hits TRIGDEFBAD, use WB test case to avoid the assert failure
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 31

# NOTE: The below dse command relies on the fact the leaf block of ^#t is 3.
alias dse_corrupt '$DSE overwrite -block=3 -offset=\!:1 -data=\!:2'
$gtm_tst/com/dbcreate.csh mumps 1

$gtm_exe/mumps -run init^trigdefbad

# Save a copy of the database. We use DSE to corrupt some of the ^#t fields. Instead of repairing the corruption,
# we will just copy the original database.
cp mumps.dat mumps.bak

$DSE dump -block=3 >&! dse_dump_bl3.out
$echoline
echo "Test 1: #LABEL incorrect. Expect YDB-E-TRIGDEFBAD"
$echoline
# Corrupt the 1-byte value field of the ^#t("a","#LABEL") node.
# The DSE DUMP of block 3 will display something like the below
#	Rec:E  Blk 3  Off FF  Size C  Cmpc 8  Key ^#t("a","#LABEL")
# In this case, we want to add 0xFF and 0xC and subtract 1 to get the offset of the value field.
# And then use that to do the corruption.
set corruptoffset = `$tst_awk '/#LABEL/ {a=strtonum("0x"$5)+strtonum("0x"$7)-1} END{ printf "%X\n", a}' dse_dump_bl3.out`
dse_corrupt $corruptoffset "X"
$gtm_exe/mumps -run trigdefbad

echo ""
echo ""

reload_db
$echoline
echo "Test 2:  #CYCLE missing. Expect YDB-E-TRIGDEFBAD"
$echoline
# Corrupt the key field of ^#t("a","#CYCLE") so it effectively becomes missing.
# The DSE DUMP of block 3 will display something like the below
#	Rec:E  Blk 3  Off 105  Size B  Cmpc 9  Key ^#t("a","#CYCLE")
# In this case, we want to add 0x105 and 0xB and subtract 2 to get the offset of the second key terminating 0 byte
# And then corrupt it so the key does not null terminate at that offset anymore.
set corruptoffset = `$tst_awk '/#CYCLE/ {a=strtonum("0x"$5)+strtonum("0x"$7)-2} END{ printf "%X\n", a}' dse_dump_bl3.out`
dse_corrupt $corruptoffset "3"
$gtm_exe/mumps -run trigdefbad

echo ""
echo ""

reload_db
$echoline
echo "Test 3: #CYCLE = 0. Expect YDB-E-TRIGDEFBAD"
$echoline
set corruptoffset = `echo "obase=16; ibase=16; $corruptoffset+1" | bc `
dse_corrupt $corruptoffset "0"
$gtm_exe/mumps -run trigdefbad

echo ""
echo ""

reload_db
$echoline
echo "Test 4: #COUNT missing. Expect YDB-E-TRIGDEFBAD"
$echoline
# Corrupt the key field of ^#t("a","#COUNT") so it effectively becomes missing.
# The DSE DUMP of block 3 will display something like the below
#	Rec:D  Blk 3  Off F7  Size E  Cmpc 6  Key ^#t("a","#COUNT")
# In this case, we want to add 0xF7 and 0xE and subtract 3 to get the offset of the first key terminating 0 byte
# And then corrupt it so the key does not null terminate at that offset anymore.
set corruptoffset = `$tst_awk '/#COUNT/ {a=strtonum("0x"$5)+strtonum("0x"$7)-3} END{ printf "%X\n", a}' dse_dump_bl3.out`
dse_corrupt $corruptoffset "3"
$gtm_exe/mumps -run trigdefbad

echo ""
echo ""

reload_db
$echoline
echo "Test 5: #COUNT = 0. Expect YDB-E-TRIGDEFBAD"
$echoline
set corruptoffset = `echo "obase=16; ibase=16; $corruptoffset+2" | bc `
dse_corrupt $corruptoffset "0"
$gtm_exe/mumps -run trigdefbad

echo ""
echo ""

reload_db
$echoline
echo "Test 6: #TRIGNAME missing. Expect YDB-E-TRIGDEFBAD"
$echoline
# Corrupt the key field of ^#t("a",1,"TRIGNAME") so it effectively becomes missing.
# The DSE DUMP of block 3 will display something like the below
#	Rec:B  Blk 3  Off C2  Size 12  Cmpc A  Key ^#t("a",1,"TRIGNAME")
# In this case, we want to add 0xC2 and 0x4 (rec_hdr) to reach the TRIGNAME subscript and corrupt its first byte
set corruptoffset = `$tst_awk '/TRIGNAME/ {a=strtonum("0x"$5)+4} END{ printf "%X\n", a}' dse_dump_bl3.out`
dse_corrupt $corruptoffset "3"
$gtm_exe/mumps -run trigdefbad

echo ""
echo ""

reload_db
$echoline
echo "Test 7: #CMD missing. Expect YDB-E-TRIGDEFBAD"
$echoline
# Corrupt the key field of ^#t("a",1,"CMD") so it effectively becomes missing.
# The DSE DUMP of block 3 will display something like the below
#	Rec:8  Blk 3  Off 94  Size 9  Cmpc B  Key ^#t("a",1,"CMD")
# In this case, we want to add 0x94 and 0x4 (rec_hdr) to reach the CMD subscript and corrupt its first byte
set corruptoffset = `$tst_awk '/CMD/ {a=strtonum("0x"$5)+4} END{ printf "%X\n", a}' dse_dump_bl3.out`
dse_corrupt $corruptoffset "3"
$gtm_exe/mumps -run trigdefbad

echo ""
echo ""

reload_db
$echoline
echo "Test 8: #CHSET missing. Expect YDB-E-TRIGDEFBAD"
$echoline
# Corrupt the key field of ^#t("a",1,"CHSET") so it effectively becomes missing.
# The DSE DUMP of block 3 will display something like the below
#	Rec:7  Blk 3  Off 88  Size C  Cmpc A  Key ^#t("a",1,"CHSET")
# In this case, we want to add 0x88 and 0x4 (rec_hdr) to reach the CHSET subscript and corrupt its second byte
# Do not corrupt its first byte 'C' since it is used towards the compression for the next node CMD and we dont
# want an error message involving that subscript in this testcase.
set corruptoffset = `$tst_awk '/CHSET/ {a=strtonum("0x"$5)+5} END{ printf "%X\n", a}' dse_dump_bl3.out`
dse_corrupt $corruptoffset "3"
$gtm_exe/mumps -run trigdefbad

echo ""
echo ""

# the test below is PRO only, DBG will assert fail
if ("dbg" == "$tst_image") then
	$gtm_tst/com/dbcheck.csh
	exit
endif
reload_db
$echoline
echo "Test 9: Corrupt ^#t leaf block outside record boundries but inside block boundries. Expect TPFAIL error"
$echoline
# The below corruption will change the layout of block 3. PRO ONLY
# Corrupt the record-size field of ^#t("a","#CYCLE") so it effectively becomes a huge record whose size exceeds block size.
# The DSE DUMP of block 3 will display something like the below
#	Rec:E  Blk 3  Off 105  Size 330B  Cmpc 9  Key ^#t("a","#CYCLE")
# In this case, we want to add 0x105 and 0x1 to reach the most significant byte of the 2-byte size corrupt it.
set corruptoffset = `$tst_awk '/#CYCLE/ {a=strtonum("0x"$5)+1} END{ printf "%X\n", a}' dse_dump_bl3.out`
dse_corrupt $corruptoffset "3"
$gtm_exe/mumps -run trigdefbad >&! tpfail.log
$gtm_tst/com/check_error_exist.csh tpfail.log "TPFAIL"
set num_cores = `ls -l {,gtm}core* | wc -l`
if (0 == $num_cores) then
	echo "TEST-E-FAIL : No cores found. Test expects 1 core file"
else if ($num_cores > 1) then
	echo "TEST-E-FAIL : More than 1 core file found. Test expects ONLY 1 core file"
	ls -l {,gtm}core*
else
	# The test framework will conclude presence of cores as a test failure. Since, we expect cores
	# in this particular scenario, it's okay to move the file under a different name.
	if ( "os390" == $gtm_test_osname ) then
		mv gtmcore* tpfail_expected_core_file
	else
		mv core* tpfail_expected_core_file
	endif
endif

echo ""
echo ""
# Avoid needless INTEG error at the end of the test
reload_db
$gtm_tst/com/dbcheck.csh
