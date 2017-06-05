#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------
#
# recursive	[connellb]		Test recursive relink.
# setzroutines	[connellb]		Test autorelink after SET $ZROUTINES.
# zrupdate	[connellb]		Test that $ZRUPDATE() initiates concurrent autorelinks.
# barrage	[sopini]		Test the comprehensive functionality of autorelink.
# relinksrch	[nars,sopini]		Test populating relink-control files to supported limits.
# basic		[sopini]		Survey of basic autorelink functionality.
# bigrctl	[sopini]		Do 1M of ZRUPDATEs followed by VIEW "RCTLDUMP".
# concur	[nars,sopini]		Test concurrent relinkctl file and shared memory updates.
# zbreak	[sopini]		Test various ZBREAK functionality.
# shmalloc	[nars,sopini]		Test rtnobj shared memory allocations and expansions.
# memleak	[sopini]		Ensure that we are not leaking memory with autorelink operations.
# zlink		[maimoneb]		Test ZLINK functionality.
# rundown	[sopini]		Test MUPIP and MUMPS relink control file rundown functionality.
# errors	[sopini]		Exercise various error code paths.
# rctlupdate	[sopini]		Test various ZRUPDATE functionality.
# truncate	[sopini]		Test proper recognition and reporting of truncated object files.
# trigger	[sopini]		Test ZRUPDATEs with trigger propagation on secondary.
# memleak2	[nars,sopini]		Test for memory leaks in recursive relink operations.
# labelunknown	[nars,sopini]		Verify that LABELUNKNOWN and LABELMISSING errors are not issued
# 					incorrectly with recursive relink.
# relinkctlfull	[nars,sopini]		Test for memory and file descriptor leaks on RELINKCTLFULL error.
# keeprtn 	[kishoreh] 		Test correct behavior of $gtm_autorelink_keeprtn
#

echo "relink test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "recursive setzroutines zrupdate barrage relinksrch basic bigrctl concur zbreak"
setenv subtest_list_non_replic "$subtest_list_non_replic shmalloc memleak zlink rundown errors rctlupdate truncate"
setenv subtest_list_non_replic "$subtest_list_non_replic memleak2 labelunknown relinkctlfull keeprtn"
setenv subtest_list_replic     "trigger"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Filter out certain subtests for some servers.
set hostn = $HOST:r:r:r

# The relinksrch test uses white-box setup, so disable it in pro.
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list relinksrch relinkctlfull"
	if ("Linux" == $HOSTOS) then
		setenv subtest_exclude_list "$subtest_exclude_list errors"
	endif
endif

# The following boxes have ext3 filesystems for /testarea1, so comparing file timestamps is troublesome.
if ("tuatara" == "$hostn") then
	setenv subtest_exclude_list "$subtest_exclude_list barrage zlink zbreak"
endif

# There are issues with timestamp separation on pfloyd that causes the zbreak test to fail (see
# <GTM_8160_relink_zbreak_missing_breakpoint_pfloyd> for details).
if ("pfloyd" == "$hostn") then
	setenv subtest_exclude_list "$subtest_exclude_list zbreak"
endif

# Only Linux boxes are capable of handling the bigrctl test in a timely manner.
if (("Linux" != $HOSTOS) || ("L" == $LFE)) then
	setenv subtest_exclude_list "$subtest_exclude_list bigrctl"
endif

# If IGS is not available, filter out subtests that need it
if ($?gtm_test_noIGS) then
	setenv subtest_exclude_list "$subtest_exclude_list bigrctl"
endif

# The following boxes cannot cope with large memory allocations exercised in the shmalloc test.
if ("atlst2000" == "$hostn") then
	setenv subtest_exclude_list "$subtest_exclude_list shmalloc"
endif

if ($?gtm_test_temporary_disable) then
	setenv subtest_exclude_list "$subtest_exclude_list trigger"
endif

# This suite's subtests make their own choices about autorelink-enabled directories.
unsetenv gtm_test_autorelink_always

# Compile a shared library with useful functions for in-process use.
cp $gtm_src/mmrhash.c .
$gt_cc_compiler $gt_cc_shl_options $gt_cc_option_debug -I$gtm_dist $gt_cc_option_I $gtm_tst/$tst/inref/relink.c -o relink.o
$gt_cc_compiler $gt_cc_shl_options $gt_cc_option_debug -I$gtm_dist $gt_cc_option_I mmrhash.c -o mmrhash.o
$gt_ld_shl_linker ${gt_ld_option_output}librelink${gt_ld_shl_suffix} $gt_ld_shl_options relink.o mmrhash.o $gt_ld_sysrtns $gt_ld_syslibs > ld.out

setenv GTMXC_relink $PWD/relink.xc
cat > $GTMXC_relink <<EOF
$PWD/librelink${gt_ld_shl_suffix}

chooseFileByIndex:	gtm_status_t choose_file_by_index(I:gtm_char_t*, I:gtm_int_t, O:gtm_char_t*[100])
renameFile:		gtm_status_t rename_file(I:gtm_char_t*, I:gtm_char_t*)
removeFile:		gtm_status_t remove_file(I:gtm_char_t*)
removeDirectory:	gtm_status_t remove_directory(I:gtm_char_t*)
matchFiles:		gtm_string_t* match_files(I:gtm_char_t*)
murmurHash:		gtm_string_t* murmur_hash(I:gtm_char_t*)
chShmMod:		gtm_status_t ch_shm_mod(I:gtm_int_t, I:gtm_int_t)
truncateFile:		gtm_status_t truncate_file(I:gtm_char_t*, I:gtm_int_t)
EOF

# Find out the minimum shared memory allocation based on huge page setting.
@ huge_page_alloc_mb = 0
if ((-e /usr/lib64/libhugetlbfs.so) || (-e /usr/lib/libhugetlbfs.so)) then
	if ("Linux" == $HOSTOS) then
		set huge_page_size = `$grep Hugepagesize /proc/meminfo | $tst_awk '{print $2" "$3}'`
	else
		set huge_page_size = (0 kB)
	endif

	if (0 == $#huge_page_size) then
		@ huge_page_alloc_mb = 0
	else
		if ("kB" != $huge_page_size[2]) then
			echo "TEST-E-FAIL, Huge page size unit other than 'kB' is used: '$huge_page_size[2]'."
			exit 1
		else
			@ huge_page_alloc_mb = $huge_page_size[1] / 1024
		endif
	endif
endif
setenv min_shm_alloc_mb $huge_page_alloc_mb

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "relink test DONE."
