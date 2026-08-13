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
echo "# [#1143] MUPIP SET -SEARCH_INDEX_SIZE=bytes keeps the slot count the database already has         #"
echo "#--------------------------------------------------------------------------------------------------#"
echo

# The slot count applies to BG and MM alike, so either access method would do. Force BG so that the
# reference file does not depend on which one the test system picked.
source $gtm_tst/com/gtm_test_setbgaccess.csh
# This subtest compares file header fields and MUPIP SET output exactly, so keep the test system from
# changing the database underneath it.
setenv gtm_test_use_V6_DBs 0
setenv test_reorg NON_REORG

# MUPIP SET names the database file in its confirmation, and that path varies by test run.
alias strip_path 'sed "s;Database file .* now has;Database file now has;"'
# Checks both fields for both regions against the pair each stage names. A script and not an alias
# because tcsh substitutes a loop variable before the loop ever runs, so the loop cannot live in an
# alias. Naming the expected pair is what makes the stage a check rather than a display : see the
# comment at the top of search_index_check-ydb1143.csh.
alias check_idx '$gtm_tst/$tst/u_inref/search_index_check-ydb1143.csh'

# Two regions, because the rounding is done per region: the size is bounded by that region's block
# size and the count by what that region already holds, so a count kept for one region must not
# become the count of the next.
$gtm_tst/com/dbcreate.csh mumps 2 250 1024 4096

echo "# MUPIP CREATE gives every region the same defaults : a quarter of the 4096 byte block size,"
echo "# and 1024 slots."
check_idx DEFAULT 1024 1024 AREG 1024 1024
echo

echo "# Give the two regions DIFFERENT non-default slot counts, naming both numbers."
echo "# mupip set -search_index_size=2048,8192 -region DEFAULT"
$ydb_dist/mupip set -search_index_size=2048,8192 -region DEFAULT |& strip_path
echo "# mupip set -search_index_size=512,256 -region AREG"
$ydb_dist/mupip set -search_index_size=512,256 -region AREG |& strip_path
check_idx DEFAULT 2048 8192 AREG 512 256
echo

echo "# THE POINT OF THIS SUBTEST. Change only the SIZE on DEFAULT, naming no slot count. The count"
echo "# stays 8192. Before this was fixed it silently reverted to the 1024 default, so an administrator"
echo "# who had chosen a count lost it by changing the size."
echo "# mupip set -search_index_size=1024 -region DEFAULT"
$ydb_dist/mupip set -search_index_size=1024 -region DEFAULT |& strip_path
check_idx DEFAULT 1024 8192 AREG 512 256
echo

echo "# The same thing across BOTH regions at once, still naming no count. Each region keeps its OWN"
echo "# count - 8192 and 256 - rather than one region's count being carried into the other. One"
echo "# command covering both regions is the case that matters here, because the count kept for one"
echo "# region must not become the count of the next. The confirmation lines are sorted because the"
echo "# order MUPIP works through the regions in is not the same from run to run."
echo '# mupip set -search_index_size=768 -region "*"'
$ydb_dist/mupip set -search_index_size=768 -region "*" |& strip_path | sort
check_idx DEFAULT 768 8192 AREG 768 256
echo

echo "# A count is only defaulted when the database has none. Turn AREG off, which zeroes both fields,"
echo "# and then set a size alone : there is no count to keep, so it takes the 1024 default."
echo "# mupip set -nosearch_index -region AREG"
$ydb_dist/mupip set -nosearch_index -region AREG |& strip_path
check_idx DEFAULT 768 8192 AREG 0 0
echo "# mupip set -search_index_size=1024 -region AREG"
$ydb_dist/mupip set -search_index_size=1024 -region AREG |& strip_path
check_idx DEFAULT 768 8192 AREG 1024 1024
echo

echo "# A count that is not a power of two is rounded up to one, since a block number picks its slot"
echo "# with a mask."
echo "# mupip set -search_index_size=1024,5000 -region AREG"
$ydb_dist/mupip set -search_index_size=1024,5000 -region AREG |& strip_path
check_idx DEFAULT 768 8192 AREG 1024 8192
echo

echo "# A count above the maximum is refused, and BOTH fields are left as they were. The maximum is"
echo "# 1048576 slots, so 1048577 is the first count refused."
echo "# mupip set -search_index_size=1024,1048577 -region AREG >& toomanyslots.out"
$ydb_dist/mupip set -search_index_size=1024,1048577 -region AREG >& toomanyslots.out
$gtm_tst/com/check_error_exist.csh toomanyslots.out MUPIPSET2BIG WCWRNNOTCHG
check_idx DEFAULT 768 8192 AREG 1024 8192
echo

echo "# -SEARCH_INDEX_SIZE=0 asks for the DEFAULT size, it does not disable. This is the one place"
echo "# MUPIP used to differ from GDE, and it no longer does."
echo "# mupip set -search_index_size=0 -region AREG"
$ydb_dist/mupip set -search_index_size=0 -region AREG |& strip_path
check_idx DEFAULT 768 8192 AREG 1024 8192
echo

echo "# -SEARCH_INDEX turns it back ON at the MUPIP level, the mirror of -NOSEARCH_INDEX and the same"
echo "# spelling GDE uses. It restores the default size and count on a region that has none."
echo "# mupip set -nosearch_index -region AREG"
$ydb_dist/mupip set -nosearch_index -region AREG |& strip_path
check_idx DEFAULT 768 8192 AREG 0 0
echo "# mupip set -search_index -region AREG"
$ydb_dist/mupip set -search_index -region AREG |& strip_path
check_idx DEFAULT 768 8192 AREG 1024 1024
echo

echo "# The same rule at the MUPIP prompt : -SEARCH_INDEX supplies defaults only for what the command"
echo "# does not name. This one names 2048,256, so the region ends up with 2048 and 256 rather than"
echo "# with the defaults the stage above restored."
echo "# mupip set -search_index -search_index_size=2048,256 -region AREG"
$ydb_dist/mupip set -search_index -search_index_size=2048,256 -region AREG |& strip_path
check_idx DEFAULT 768 8192 AREG 2048 256
echo

echo "# -NOSEARCH_INDEX zeroes the count as well as the size, on both regions"
echo '# mupip set -nosearch_index -region "*"'
$ydb_dist/mupip set -nosearch_index -region "*" |& strip_path
check_idx DEFAULT 0 0 AREG 0 0
echo

$gtm_tst/com/dbcheck.csh
echo "# YDB1143 SEARCH INDEX SLOT COUNT TEST DONE"
