#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#--------------------------------------------------------------------------------------------------#"
echo "# [#1143] The SEARCH_INDEX_SIZE and SEARCH_INDEX_SLOTS global directory segment characteristics    #"
echo "#--------------------------------------------------------------------------------------------------#"
echo
echo "# 0 means two different things in a global directory, and getting them the wrong way round is the"
echo "# mistake this subtest exists to catch. SEARCH_INDEX_SIZE=0 means CHOOSE FOR ME, so a database made"
echo "# from it has search indexes ON at a quarter of the block size. SEARCH_INDEX_SLOTS=0 means OFF, since"
echo "# no slots is no search index. GDE SHOW displays the two as AUTO and OFF."
echo
echo "# This subtest drives GDE and MUPIP CREATE directly rather than through dbcreate.csh, because what is"
echo "# under test is the path from a global directory characteristic to a created file header."

source $gtm_tst/com/gtm_test_setbgaccess.csh
setenv gtm_test_use_V6_DBs 0
setenv test_reorg NON_REORG
setenv gtmgbldir $PWD/mumps.gld

# DSE prints the size and the slot count on ONE line, so a single grep shows both. The spacing is
# squeezed out so the reference file does not depend on column positions.
# Both aliases CHECK rather than display : each call names the pair it expects, so a wrong value
# reads as the word WRONG in the output instead of as a plausible number nobody questions.
alias check_idx '$gtm_tst/$tst/u_inref/search_index_check-ydb1143.csh DEFAULT'
alias check_gde '$gtm_tst/$tst/u_inref/search_index_gdecheck-ydb1143.csh'

echo "# 1. GDE defaults : SIDX unspecified and SISL 1024, shown as AUTO and 1024"
rm -f mumps.gld mumps.dat
echo "# change -segment DEFAULT -block_size=4096 -file=mumps.dat"
$ydb_dist/mumps -run GDE <<GDE1 >& gde1.out
change -segment DEFAULT -block_size=4096 -file=mumps.dat
GDE1
check_gde AUTO 1024
echo "# mupip create >& create1.out"
$ydb_dist/mupip create >& create1.out
check_idx 1024 1024
echo

echo "# and the created database is ON, sized at a quarter of the 4096 byte block size"
echo

echo "# 2. SEARCH_INDEX_SLOTS=0 turns it OFF. GDE shows OFF, and the created file header reads 0 and 0."
echo "# The size named alongside it is deliberately non-zero, to show the slot count is what decides."
rm -f mumps.gld mumps.dat
echo "# change -segment DEFAULT -block_size=4096 -search_index_size=2048 -search_index_slots=0 -file=mumps.dat"
$ydb_dist/mumps -run GDE <<GDE2 >& gde2.out
change -segment DEFAULT -block_size=4096 -search_index_size=2048 -search_index_slots=0 -file=mumps.dat
GDE2
check_gde 2048 OFF
echo "# mupip create >& create2.out"
$ydb_dist/mupip create >& create2.out
check_idx 0 0
echo

echo "# 3. A named size and slot count both come through, with the count rounded up to a power of two"
rm -f mumps.gld mumps.dat
echo "# change -segment DEFAULT -block_size=4096 -search_index_size=2048 -search_index_slots=5000 -file=mumps.dat"
$ydb_dist/mumps -run GDE <<GDE3 >& gde3.out
change -segment DEFAULT -block_size=4096 -search_index_size=2048 -search_index_slots=5000 -file=mumps.dat
GDE3
check_gde 2048 5000
echo "# mupip create >& create3.out"
$ydb_dist/mupip create >& create3.out
check_idx 2048 8192
echo

echo "# 4. A size below the minimum is raised to it, and one above this block size's ceiling is clamped,"
echo "# so a created database can never hold a value MUPIP SET would go on to refuse"
rm -f mumps.gld mumps.dat
echo "# change -segment DEFAULT -block_size=4096 -search_index_size=8 -file=mumps.dat"
$ydb_dist/mumps -run GDE <<GDE4 >& gde4.out
change -segment DEFAULT -block_size=4096 -search_index_size=8 -file=mumps.dat
GDE4
echo "# mupip create >& create4.out"
$ydb_dist/mupip create >& create4.out
check_idx 128 1024
rm -f mumps.gld mumps.dat
echo "# change -segment DEFAULT -block_size=4096 -search_index_size=8192 -file=mumps.dat"
$ydb_dist/mumps -run GDE <<GDE5 >& gde5.out
change -segment DEFAULT -block_size=4096 -search_index_size=8192 -file=mumps.dat
GDE5
echo "# mupip create >& create5.out"
$ydb_dist/mupip create >& create5.out
check_idx 4088 1024
echo

echo "# 5. GDE refuses a negative count, which is why 0 has to carry the OFF meaning : GDE cannot"
echo "# emit a negative that its own SHOW -COMMAND output would parse back, so there is no second"
echo "# sentinel available alongside AUTO."
echo "# change -segment DEFAULT -search_index_slots=-1"
$ydb_dist/mumps -run GDE <<GDE6 >& gde6.out
change -segment DEFAULT -search_index_slots=-1
GDE6
$gtm_tst/com/check_error_exist.csh gde6.out VALUEBAD
echo

echo "# 6. The global directory format label moves because the segment gained these two characteristics."
echo "# A global directory written by a random prior release carries a format below 016; opening it with"
echo "# this release and exiting converts it to 016 or above. The exact numbers depend on which release"
echo "# the test picked, so only the two sides of 16 are checked."
$gtm_tst/com/random_ver.csh -type V7 >&! prior_ver_v7.txt
if (0 != $status) then
	echo "TEST-I-SKIP, No suitable prior V7 version available, skipping the label conversion check."
else
	set prior_ver = `cat prior_ver_v7.txt`
	source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
	source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image
	rm -f old.gld
	setenv gtmgbldir $PWD/old.gld
	$gtm_exe/mumps -run GDE <<GDE7 >& gde7.out
change -segment DEFAULT -block_size=4096 -file=old.dat
GDE7
	# The label is the first 12 bytes of the file. Characters 10 through 12 are the format, whose
	# leading digit is the 64 bit flag, so the format number proper is the last two.
	set oldlab = `head -c 12 old.gld`
	set oldnum = `echo $oldlab | cut -c11-12`
	source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo "# mumps -run GDE exit >& gde8.out"
	$ydb_dist/mumps -run GDE exit >& gde8.out
	set newlab = `head -c 12 old.gld`
	set newnum = `echo $newlab | cut -c11-12`
	if (($oldnum < 16) && ($newnum >= 16)) then
		echo "global directory format moved from below 016 to 016 or above, as expected"
	else
		echo "TEST-E-FAIL : format went from $oldlab to $newlab, wanted below 016 then 016 or above"
	endif
endif
echo

echo "# 7. -NOSEARCH_INDEX is the readable way to say the same thing as SEARCH_INDEX_SLOTS=0, and"
echo "# -SEARCH_INDEX turns it back on. Neither is stored : both are translated into the slot count,"
echo "# so a global directory still holds only the two numbers and SHOW round-trips through them."
rm -f mumps.gld mumps.dat
echo "# change -segment DEFAULT -block_size=4096 -nosearch_index -file=mumps.dat"
$ydb_dist/mumps -run GDE <<GDE9 >& gde9.out
change -segment DEFAULT -block_size=4096 -nosearch_index -file=mumps.dat
GDE9
check_gde AUTO OFF
echo "# mupip create >& create9.out"
$ydb_dist/mupip create >& create9.out
check_idx 0 0
echo "# and back on, which restores the default count rather than inventing one, and gives a"
echo "# created database an enabled file header again, the mirror of the 0 and 0 just above"
echo "# change -segment DEFAULT -search_index"
$ydb_dist/mumps -run GDE <<GDE10 >& gde10.out
change -segment DEFAULT -search_index
GDE10
check_gde AUTO 1024
rm -f mumps.dat
echo "# mupip create >& create10.out"
$ydb_dist/mupip create >& create10.out
check_idx 1024 1024
echo

echo "# 8. -SEARCH_INDEX supplies the default count only when the command does not name one. This"
echo "# command names 4096, so the segment ends up with 4096 rather than the 1024 the stage above"
echo "# got, where -SEARCH_INDEX was the only thing named."
echo "# change -segment DEFAULT -search_index -search_index_slots=4096"
$ydb_dist/mumps -run GDE <<GDE11 >& gde11.out
change -segment DEFAULT -search_index -search_index_slots=4096
GDE11
check_gde AUTO 4096
echo

echo "# 9. -SEARCH_INDEX=0 is now REFUSED rather than silently meaning AUTO. Before the qualifier"
echo "# existed, -SEARCH_INDEX abbreviated to SEARCH_INDEX_SIZE and 0 there means choose-for-me, so"
echo "# the natural way to ask for off quietly did nothing at all."
echo "# change -segment DEFAULT -search_index=0"
$ydb_dist/mumps -run GDE <<GDE12 >& gde12.out
change -segment DEFAULT -search_index=0
GDE12
$gtm_tst/com/check_error_exist.csh gde12.out NOVALUE
echo

echo "# 10. The default size is a QUARTER OF THE BLOCK SIZE, not a fixed 1024. Every other stage here"
echo "# uses a 4096 byte block, where a quarter happens to be 1024, so on its own that proves nothing."
echo "# These block sizes each have a different quarter."
foreach bs (1024 2048 8192 16384)
	rm -f mumps.gld mumps.dat
echo "# change -segment DEFAULT -block_size=$bs -file=mumps.dat"
	$ydb_dist/mumps -run GDE <<GDEBS >& gde.bs$bs.out
change -segment DEFAULT -block_size=$bs -file=mumps.dat
GDEBS
echo "# mupip create >& create.bs$bs.out"
	$ydb_dist/mupip create >& create.bs$bs.out
	echo -n "block size $bs : "
	# A quarter, computed here rather than written out, so the stage re-derives the rule it checks
	@ expsize = $bs / 4
	check_idx $expsize 4096
end
echo "# 1024/4=256, 2048/4=512, 8192/4=2048, 16384/4=4096, each rounded up to a multiple of 8 and"
echo "# held within the 128 minimum and the ceiling of 8192 or 8 less than the block size."
echo

echo "# YDB1143 SEARCH INDEX GDE TEST DONE"
