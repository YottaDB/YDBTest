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

echo '# Test to ensure that $ZROUTINES allows glob patterns in file_names'

echo '# We want to run a compiled program that uses $ZROUTINES'
echo "# by setting it to a pattern with glob patterns that matches shared library files."
echo "# This test assumes that gt_ld_shl_suffix is .so, its actual value is currently $gt_ld_shl_suffix"
echo
# echo $gtmroutines

cp $gtm_tst/$tst/inref/ydb974la.m .
cp $gtm_tst/$tst/inref/ydb974lb.m .
cp $gtm_tst/$tst/inref/ydb974lc.m .
cp $gtm_tst/$tst/inref/ydb974ld.m .

$gtm_exe/mumps ydb974la.m
$gtm_exe/mumps ydb974lb.m
$gtm_exe/mumps ydb974lc.m
$gtm_exe/mumps ydb974ld.m
echo "# So, we will now create 2 shared library files, ydb974la.so and ydb974lb.so"
$gt_ld_m_shl_linker ${gt_ld_option_output} ydb974la$gt_ld_shl_suffix ydb974la.o ${gt_ld_m_shl_options} >& link_ld.outx
$gt_ld_m_shl_linker ${gt_ld_option_output} ydb974lb$gt_ld_shl_suffix ydb974lb.o ${gt_ld_m_shl_options} >& link_ld2.outx
echo "# Also a 3rd one with a very long name for ydb974h.m"
$gt_ld_m_shl_linker ${gt_ld_option_output} bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb.so ydb974lc.o ${gt_ld_m_shl_options} >& link_ld3.outx
echo "# And a 4th one with an * in the filename for ydb974p.m"
$gt_ld_m_shl_linker ${gt_ld_option_output} 'ydb9*74la.so' ydb974lb.o ${gt_ld_m_shl_options} >& link_ld5.outx
echo "# we will also check that non-shared library files are not picked up, so we create one to check with."
echo "" > fakeLibraryFile.so
echo "# We create a file named ydb974la.so.golf to ensure that it will not be included, as that would be incorrect."
echo "# for the patterns in the tests to pick up that filename."
$gt_ld_m_shl_linker ${gt_ld_option_output} ydb974la.so.golf ydb974lb.o ${gt_ld_m_shl_options} >& link_ld6.outx
echo
echo "# creating a directory that we do not have read permission on to test "
echo "# a permission denied error when running ydb974m.m"
mkdir temp
chmod u-r temp
echo "# Also creating a directory with too many wildcard matches to test that error."
mkdir manyMatches
set j=1
while($j < 5000)
	cp ydb974la$gt_ld_shl_suffix manyMatches/ydb974la$j$gt_ld_shl_suffix
	@ j++
end
mkdir 20Matches
set k=1
while($k < 20)
	cp ydb974la$gt_ld_shl_suffix 20Matches/ydb974la$k$gt_ld_shl_suffix
	@ k++
end

setenv dirPathEnv 'many[M]atches'
setenv fileparseErr 'one/two/three/four/five.so'

set i=0
while ($i < 25) #currently tests are indexed with numbers and tests a through x exist.
	@ i++
	set letter=`echo $i | awk '{printf "%c", 96+$1}'`
	if ($letter != "n") then # Test n needs to happen last as it creates a new file
		echo             # This interferes with other tests.
		$gtm_dist/mumps -run ydb974$letter
	endif
end
echo
echo "# Restore read permission for test environment."
chmod u+r temp
echo

echo "# Creating a C shared library"
set file=""$gtm_tst/$tst/inref/ydb974Ccode.c""
set exefile = $file:r
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $exefile.c
$gt_ld_m_shl_linker ${gt_ld_option_output} ydb974Ccode$gt_ld_shl_suffix ydb974Ccode.o ${gt_ld_m_shl_options} >& link_ld4.outx
$gtm_dist/mumps -run ydb974n

echo
echo '# Now test that an error within $ZROUTINES followed by an error outside $ZROUTINES.'
echo "# This test is motivated by the fact that it used to try to free memory twice in the above case."
echo "# as described https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1817#note_3098461826"
echo "# A failed test would give an assert failure in sr_unix/zro_load.c or sr_port/gtm_malloc_src.h"
echo "# This test will now be expected to just give the 2 different errors."
echo "# First a 'glob pattern must end in .so' error, then 'Either a space or an end-of-line was expected' error"
$gtm_dist/mumps -dir << EOF
set \$ZROUTINES="*.m"
write "noEnd
EOF
