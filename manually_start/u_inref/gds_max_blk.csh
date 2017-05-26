#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
# Without defer allocate the space needed would be 512 times this i.e. 20Tb which is definitely not available. So force defer allocate
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
echo "################ TEST CASE 1 ################"
echo "# Create a data base with 992M blocks"
setenv gtm_test_disable_randomdbtn 1
# Create data base with allocation of 1M
$gtm_tst/com/dbcreate.csh mumps 1 . . 512 1048576 . . . . . $acc_meth

set regions = "DEFAULT"

# In 992M (i.e. 1040187392)  blocks database,
# Total blocks including local bit map blocks     = 1040187392
# total local bit map blocks                      = 2031616     (1040187392 / 512)
# total blocks(excluding local bitmap blocks) 	  = 1038155776  (1040187392 - 2031616)

# Extend database by 2M blocks for each iteration until it will create 889M blocks(1037041664 blocks).
echo "# extend database blocks to 992M"
set max=495
set i = 1
while ( $i != $max)
	foreach reg ($regions)
		$MUPIP extend $reg -block=2097152 >>& extend_992.log
	end
	@ i = $i + 1
end

# Room for more blocks   = Total blocks without bitmap - Total created blocks by extension in above while loop
#			 = 1038155776 - (Extension count in while loop * no. of loop iterations + Initial Allocation)
#			 = 1038155776 - (2097152 * 494 + 1048576)
#			 = 1038155776 - 1037041664
#			 = 1114112

foreach reg ($regions)
	$MUPIP extend $reg -block=1114112 >>& extend_992.log
end
echo "# Check the integrity of the database"
$MUPIP integ -region "*"

echo "# Do an update"
$gtm_exe/mumps -run %XCMD 'set ^x=50'

echo "# Check the integrity of the database"
$MUPIP integ -region "*"

# Total blocks = 1040187392
# last local bit map block = (1038155776 - 512) = 1040186880 = 0x3DFFFE00
echo "# Dump the last local bitmap block"
$DSE <<EOF
find -reg=DEFAULT
dump -bl=3DFFFE00
EOF

echo "################ TEST CASE 2 ################"
echo "# Try to extend data base to greater than 992M value and expect it to error out"

echo "# extend database blocks to 992M + 1 blocks"
foreach reg ($regions)
	$MUPIP extend $reg -block=1
end

$gtm_tst/com/dbcheck.csh
