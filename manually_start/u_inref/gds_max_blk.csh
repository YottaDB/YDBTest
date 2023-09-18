#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2016 Fidelity National Information		#
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
echo "# Enable WHITE BOX TESTING"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 24

# Avoid NOSPACECRE error so that sparse DB of big size can be created.
setenv gtmdbglvl 0x00100000
# With defer allocate, the space needed for the database file in the filesystem is 40Gb
# Without defer allocate the space needed would be 512 times this i.e. 20TB which is definitely not available. So force defer allocate
setenv save_gtm_test_defer_allocate $gtm_test_defer_allocate
setenv gtm_test_defer_allocate 1
# Disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

# Disable unicode if ICU >= 4.4 is detected, since support for it started with V54002 and this test require an older version.
if (($?gtm_chset) && ($?gtm_icu_version)) then
	if (("UTF-8" == $gtm_chset) && (1 == `echo "if ($gtm_tst_icu_numeric_version >= 44) 1" | bc`)) then
		set save_chset = $gtm_chset
		$switch_chset "M" >&! switch_chset1.out
	endif
endif

# Disable V4 format
setenv gtm_test_mupip_set_version "disable"

echo "################ TEST CASE 1 ################"
echo "# Create a data base with 992M blocks"
setenv gtm_test_disable_randomdbtn 1

if ( "HOST_LINUX_X86_64" != $gtm_test_os_machtype) then
	# Disable MM on 32-bit platforms (ARMV7L, ARMV6L) or 64-bit ARM (AARCH64) as an mmap of this 20TB sized database
	# would fail with a "%SYSTEM-E-ENO12, Cannot allocate memory" error.
	# With BG though, we don't have such issues since only a subset of the database is cached in the global buffers.
	setenv acc_meth BG
	echo "# override acc_meth in test to BG (since MM on 32-bit platforms for 20TB db will not work)" >>&! settings.csh
	echo "setenv acc_meth BG" >>&! settings.csh
endif
# Test case 1 is about testing for LOWSPC messages with V6 format databases. See Test Case #2 below for why we cannot do
# this for V7 format DBs. For this test case, flag that we need a V6 DB.
source $gtm_tst/com/enable_gtm_test_use_V6_DBs.csh # Force V6 DB mode
setenv ydb_test_4g_db_blks 0  	   	      	   # This must be off if gtm_test_use_V6_DBs is on

# Create data base with allocation of 1M
$gtm_tst/com/dbcreate.csh mumps 1 . . 512 1048576 . . . . . $acc_meth

set regions = "DEFAULT"

# In 992M (i.e. 1040187392)  blocks database,
# Total blocks including local bit map blocks     = 1040187392
# total local bit map blocks                      = 2031616     (1040187392 / 512)
# total blocks(excluding local bitmap blocks) 	  = 1038155776  (1040187392 - 2031616)

# Set start time for getoper.csh
set syslog_start = `date +"%b %e %H:%M:%S"`

# Extend database by 2M blocks for each iteration until it will create 889M blocks(1037041664 blocks).
echo
echo "# extend database blocks to 992M"
set max=495
# Calculate in which iteration the memory will reach 88%, add 1 for $random
# Note that "thres" is not a rounded integer (i.e. has a fractional part) but it is okay since it is used
# with $random() which anyways discards the fractional part. Hence no need to do "\1" to round down.
set thres=`$gtm_exe/mumps -run %XCMD "write ($max*0.88)+1"`

# Calculate iteration that will result in a LOWSPC warning for MUPIP EXTEND
# Choose random value between 88% and 100% (non including)
set over_thres=`$gtm_exe/mumps -run %XCMD 'write $random(11)+89'`
set rand_over=`$gtm_exe/mumps -run %XCMD "write $max*0.$over_thres\1"`

set i = 1
set rand_under=`$gtm_exe/mumps -run %XCMD "set ^y="'$random'"($thres-1)+1  write ^y"`
echo "Over 88%: $rand_over\nUnder 88%:$rand_under\n" > random.out
echo
echo "# gtm7960: After 88% memory reached, MUPIP EXTEND will issue a LOWSPC Warning every 1% and"
echo "# 	   MUPIP INTEG and MUPIP SIZE will issue a LOWSPC Warning on each command call"
while ( $i != $max)
	if ( $i == $rand_over ) then
		echo
		echo "# Run MUPIP INTEG and MUPIP SIZE during a random iteration after 88% memory is reached"
		echo "# This should generate a LOWSPC Warning"
		($MUPIP integ -region "*" >& integsyslog.out &; echo $! >& pid1_integ.out) >& bckg1_integ.out
		set pid1integ = `cat pid1_integ.out`
		# On slow systems (e.g. ARM platform), it is possible this huge database file takes more than the
		# default of 60 seconds to integ. So wait indefinitely using -1 as the second parameter below.
		$gtm_tst/com/wait_for_proc_to_die.csh $pid1integ -1

		($MUPIP size -region="*" >& sizesyslog.out &; echo $! >& pid1_size.out) >& bckg1_size.out
		set pid1size = `cat pid1_size.out`
		$gtm_tst/com/wait_for_proc_to_die.csh $pid1size -1

		($MUPIP extend $regions -block=10401874 >& extend_$i.log &; echo $! >& pid1_extend.out) >& bckg1_extend.out
		set pid1extend = `cat pid1_extend.out`
		$gtm_tst/com/wait_for_proc_to_die.csh $pid1extend -1

	else if ( $i == $rand_under ) then
		echo
		echo "# Run MUPIP INTEG and MUPIP SIZE during a random iteration before 88% memory is reached"
		echo "# This should not generate any LOWSPC Warnings"
		($MUPIP extend $regions -block=2097152 >& extend_$i.log &; echo $! >& pid2_extend.out) >& bckg2_extend.out
		set pid2extend = `cat pid2_extend.out`
		$gtm_tst/com/wait_for_proc_to_die.csh $pid2extend -1

		($MUPIP integ -region "*" >& integsyslog.out &; echo $! >& pid2_integ.out) >& bckg2_integ.out
		set pid2integ = `cat pid2_integ.out`
		$gtm_tst/com/wait_for_proc_to_die.csh $pid2integ -1

		($MUPIP size -region="*" >& sizesyslog.out &; echo $! >& pid2_size.out) >& bckg2_size.out
		set pid2size = `cat pid2_size.out`
		$gtm_tst/com/wait_for_proc_to_die.csh $pid2size -1
	else
		foreach reg($regions)
			$MUPIP extend $reg -block=2097152 >& extend_$i.logx
		end
	endif
	@ i = $i + 1
end

# End system logging
$gtm_tst/com/getoper.csh "$syslog_start" "" test_syslog.txt
echo
echo "# Check if LOWSPC Warning message is generated by MUPIP INTEG before 88% memory is reached"
$grep "\[$pid2integ\]" test_syslog.txt | $grep "LOWSPC" | cut -d']' -f 2
echo "# Check if LOWSPC Warning message is generated by MUPIP INTEG after 88% memory is reached"
$grep "\[$pid1integ\]" test_syslog.txt | $grep "LOWSPC" | cut -d']' -f 2

echo
echo "# Check if LOWSPC Warning mesage is generated by MUPIP SIZE before 88% memory is reached"
$grep "\[$pid2size\]" test_syslog.txt | $grep "LOWSPC" | cut -d']' -f 2
echo "# Check if LOWSPC Warning mesage is generated by MUPIP SIZE after 88% memory is reached"
$grep "\[$pid1size\]" test_syslog.txt | $grep "LOWSPC" | cut -d']' -f 2

echo
echo "# Check if LOWSPC Warning message is generated by MUPIP EXTEND before 88% memory is reached"
$grep "\[$pid2extend\]" test_syslog.txt | $grep "LOWSPC" | cut -d']' -f 2
echo "# Check if LOWSPC Warning message is generated by MUPIP EXTEND after 88% memory is reached"
$grep "\[$pid1extend\]" test_syslog.txt | $grep "LOWSPC" | cut -d']' -f 2

# From original gds_max_blk subtest
# Room for more blocks   = Total blocks without bitmap - Total created blocks by extension in above while loop
#			 = 1038155776 - (Extension count in while loop * no. of loop iterations + Initial Allocation)
#			 = 1038155776 - (2097152 * 494 + 1048576)
#			 = 1038155776 - 1037041664
#			 = 1114112

# Enhanced with gtm7960
# Room for more blocks 	 = Total blocks without bitmap - Total created blocks by extension in above while loop
#			 = 1038155776 - (Extension count in while loop * no. of loop iterations + Initial Allocation + Extension from MUPIP EXTEND LOWSPC check)
#			 = 1038155776 - (2097152 * 489 + 1048576 + 10401874)
#			 = 1038155776 - 1036957778
#			 = 1197998
echo
echo '# Extend database by 1197998 blocks which should be the maximum for this region'
$MUPIP extend DEFAULT -block=1197998 >& extend_DEFAULT_992.log
echo
echo '# Extend database by 1 more block which we expect to fail:'
$MUPIP extend DEFAULT -block=1
echo
echo "# Check the integrity of the database"
$MUPIP integ -region "*" |& tee integ1.log
echo
echo "# Do an update"
$gtm_exe/mumps -run %XCMD 'set ^x=50' |& tee update.log
echo
echo "# Check the integrity of the database"
$MUPIP integ -region "*" |& tee integ2.log

# Total blocks = 1040187392
# last local bit map block = (1038155776 - 512) = 1040186880 = 0x3DFFFE00
echo
echo '# Dump the last local bitmap block of this V6 DB (bit map expected to exist - i.e. not error out when dumped):'
$DSE << EOF |& tee dse.outx
dump -bl=3DFFFE00
EOF
echo
echo
echo '# Dump the "next" local bitmap block to verify it does not exist (expect error):'
$DSE << EOF |& tee -a dse.outx
dump -bl=3E000000
EOF
echo
echo
echo '# Validate database'
$gtm_tst/com/dbcheck.csh >& dbcheck.out
#
# Since this portion of the test uses $ydb_test_4g_db_blks, this part of the test requires a debug build so
# bypass if this is not a debug build.
#
if ("dbg" == "$tst_image") then
	#
	# Rename original V6 database so we can create a new V7 database for the next test
	#
	mv mumps.dat mumps_test1.dat
	mv mumps.gld mumps_test1.gld
	echo
	echo "################ TEST CASE 2 ################"
	echo "#"
	echo "# Recreate DB to max sized V7 DB to check that attempting to extend past the max size gives an error. Note"
	echo "# we are unable to do LOWSPC checking with a full sized V7 DB as it is 17 times larger than a max V6 DB."
	echo "# This is because we use $ydb_test_4g_db_blks to create a 'hole' in the database that contains nothing so"
	echo "# we can create the start of the DB, the hole and then a few blocks on the end in a giant sparse database"
	echo "# that takes up almost no room. But when this facility is active, LOWSPC and DBFILEXT messages are not"
	echo "# generated."
	echo "#"
	setenv gtm_test_defer_allocate $save_gtm_test_defer_allocate # Restore to what it was as it is not used in this test
	setenv gtm_test_use_V6_DBs 0   		# This test case requires V7 data blocks
	setenv ydb_test_4g_db_blks 0x1feffff	# This is the last local bit map in a maximum size DB
	echo
	echo '# Create new V7 format DB'
	$gtm_tst/com/dbcreate.csh mumps 1 -blk=512 -acc_meth=$acc_meth >& dbcreate_test2.out
	echo
	echo '# Extend the DB through all the blocks in the first local bit map and the last local bit map with everything'
	echo '# else part of the large DB hole (this is a very large but very sparse DB):'
	$MUPIP extend DEFAULT -blocks=922
	echo
	echo "# Do some updates to fill the first local bit map and then the bit map created above the DB 'hole'"
	$gtm_exe/mumps -run %XCMD 'for i=1:1:1963 set ^a($justify(i,20))=$justify(i,200)'
	echo
	echo '# Try one more extension (expecting the extension to fail for no space left):'
	$MUPIP extend $reg -block=1
	echo
	echo '# Try to add one more record (expecting it to fail with GBLOFLOW):'
	$gtm_exe/mumps -run %XCMD 'set ^z=$justify(42,240)'
	echo
	echo '# Dump the last local bitmap block of this V7 DB (bit map expected to exist and to be full):'
	$DSE << EOF |& tee dse_test2.outx
dump -bl=3FDFFFE00
EOF
	echo
	echo
	echo '# Dump the "next" local bitmap block to verify it does not exist (expect error):'
	$DSE << EOF |& tee -a dse_test2.outx
dump -bl=3FE000000
EOF
	echo
	echo
	echo '# Validate database'
	$gtm_tst/com/dbcheck.csh >>& dbcheck.out
endif
