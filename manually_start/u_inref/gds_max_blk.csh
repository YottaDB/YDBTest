#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries.	#
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
setenv gtm_test_defer_allocate 1
# Disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

# Disable unicode if ICU >= 4.4 is detected, since support for it started with V54002 and this test require an older version.
if (($?gtm_chset) && ($?gtm_icu_version)) then
	if (("UTF-8" == $gtm_chset) && (1 == `echo "if ($gtm_icu_version >= 4.4) 1" | bc`)) then
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
echo "# extend database blocks to 992M"

set max=495
# Calculate in which iteration the memory will reach 88%, add 2 because \1 rounds down, and needs to add 1 for $random
set thres=`$gtm_exe/mumps -run %XCMD "write $max*0.88+2\1"`

# Calculate iteration that will result in a LOWSPC warning for MUPIP EXTEND
# Choose random value between 88% and 100% (non including)
set over_thres=`$gtm_exe/mumps -run %XCMD 'write $random(11)+89'`
set rand_over=`$gtm_exe/mumps -run %XCMD "write $max*0.$over_thres\1"`

set i = 1
set rand_under=`$gtm_exe/mumps -run %XCMD "set ^y="'$random'"($thres)  write ^y"`
echo "Over 88%: $rand_over\nUnder 88%:$rand_under\n" > random.out
echo "# gtm7960: After 88% memory reached, MUPIP EXTEND will issue a LOWSPC Warning every 1% and"
echo "# 	   MUPIP INTEG and MUPIP SIZE will issue a LOWSPC Warning on each command call"
echo ""
while ( $i != $max)
	if ( $i == $rand_over ) then
		echo "# Run MUPIP INTEG and MUPIP SIZE during a random iteration after 88% memory is reached"
		echo "# This should generate a LOWSPC Warning"
		echo ""
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
		echo "# Run MUPIP INTEG and MUPIP SIZE during a random iteration before 88% memory is reached"
		echo "# This should not generate any LOWSPC Warnings"
		echo ""
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

echo "# Check if LOWSPC Warning message is generated by MUPIP INTEG before 88% memory is reached"
$grep "\[$pid2integ\]" test_syslog.txt | $grep "LOWSPC" | cut -d']' -f 2
echo "# Check if LOWSPC Warning message is generated by MUPIP INTEG after 88% memory is reached"
$grep "\[$pid1integ\]" test_syslog.txt | $grep "LOWSPC" | cut -d']' -f 2

echo ""
echo "# Check if LOWSPC Warning mesage is generated by MUPIP SIZE before 88% memory is reached"
$grep "\[$pid2size\]" test_syslog.txt | $grep "LOWSPC" | cut -d']' -f 2
echo "# Check if LOWSPC Warning mesage is generated by MUPIP SIZE after 88% memory is reached"
$grep "\[$pid1size\]" test_syslog.txt | $grep "LOWSPC" | cut -d']' -f 2

echo ""
echo "# Check if LOWSPC Warning message is generated by MUPIP EXTEND before 88% memory is reached"
$grep "\[$pid2extend\]" test_syslog.txt | $grep "LOWSPC" | cut -d']' -f 2
echo "# Check if LOWSPC Warning message is generated by MUPIP EXTEND after 88% memory is reached"
$grep "\[$pid1extend\]" test_syslog.txt | $grep "LOWSPC" | cut -d']' -f 2

echo ""

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

foreach reg ($regions)
	$MUPIP extend $reg -block=1197998 >& extend_${reg}_992.log
end

echo "# Check the integrity of the database"
$MUPIP integ -region "*" |& tee integ1.log

echo "# Do an update"
$gtm_exe/mumps -run %XCMD 'set ^x=50' |& tee update.log

echo "# Check the integrity of the database"
$MUPIP integ -region "*" |& tee integ2.log

# Total blocks = 1040187392
# last local bit map block = (1038155776 - 512) = 1040186880 = 0x3DFFFE00
echo "# Dump the last local bitmap block"
$DSE << EOF |& tee dse.log
find -reg=DEFAULT
dump -bl=3DFFFE00
EOF


echo "################ TEST CASE 2 ################"
echo "# Try to extend data base to greater than 992M value and expect it to error out"

echo "# extend database blocks to 992M + 1 blocks"
foreach reg ($regions)
	# Use .logx (not .log) below to avoid MUNOACTION error from being caught by test framework later
	$MUPIP extend $reg -block=1 |& tee extend_${reg}_test2.logx
end


$gtm_tst/com/dbcheck.csh >& dbcheck.out
