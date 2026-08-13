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
echo "# [#1143] The MM search index: a bounded set of slots that a block number picks from               #"
echo "#--------------------------------------------------------------------------------------------------#"
echo

# BG gives every global buffer a search index of its own, so a block that is in a buffer always has one.
# MM has no global buffers, so it gets a fixed number of slots instead and a block number picks one with
# a mask. Two index blocks can therefore land on the same slot and displace each other, which BG never
# does. That collision path is what this subtest is for, so it needs MM rather than whichever access
# method the test system randomly chose.
setenv gtm_test_db_format "NO_CHANGE"	# switching the db format does not go with MM
setenv acc_meth MM
setenv test_encryption NON_ENCRYPT	# nor does encryption
source $gtm_tst/com/mm_nobefore.csh	# nor does BEFORE image journaling
setenv gtm_test_asyncio 0		# nor does ASYNCIO
# This subtest compares the file header fields and MUPIP SET output exactly, so keep the test system
# from changing the database underneath it.
setenv gtm_test_use_V6_DBs 0
setenv test_reorg NON_REORG

# Reports both fields the way DSE shows them, with the spacing squeezed out so the reference file does
# not depend on column positions.
alias show_size 'echo "dump -fileheader" | $ydb_dist/dse |& grep -i "Search Index Size" | sed "s/  */ /g"'
# MUPIP SET names the database file in its confirmation, and that path varies by test run.
alias strip_path 'sed "s;Database file .* now has;Database file now has;"'

$gtm_tst/com/dbcreate.csh mumps 1 250 1024 4096

echo "# The database really is MM, so the slot path below is the one being exercised. DSE shows the"
echo "# access method next to the global buffer count, which the test system randomizes, so take the"
echo "# access method alone."
echo "dump -fileheader" | $ydb_dist/dse |& grep -i "Access method" > accmeth.out
$tst_awk '{print $1, $2, $3}' accmeth.out
echo

echo "# MUPIP CREATE enables search indexes for MM too: a quarter of the 4096 byte block size, and"
echo "# the default slot count."
show_size
echo

echo "# Turn them off to record the baseline, so the answers below come from a database that is"
echo "# definitely not using a search index."
echo "# mupip set -nosearch_index -region DEFAULT"
$ydb_dist/mupip set -nosearch_index -region DEFAULT |& strip_path
show_size
echo

echo "# Populate and record the answers with NO search index. Everything below has to match these."
$ydb_dist/yottadb -run build^ydb1143
$ydb_dist/yottadb -run verify^ydb1143 > answers.off.out
$ydb_dist/yottadb -run edges^ydb1143 >> answers.off.out
cat answers.off.out
echo

echo "# A size on its own gets the default slot count rather than nothing, the same on MM as on BG,"
echo "# since without slots there would be no array at all and the commonest form of the command would"
echo "# silently allocate nothing."
echo "# mupip set -search_index_size=1024 -region DEFAULT"
$ydb_dist/mupip set -search_index_size=1024 -region DEFAULT |& strip_path
show_size
$ydb_dist/yottadb -run verify^ydb1143 > answers.defslots.out
$ydb_dist/yottadb -run edges^ydb1143 >> answers.defslots.out
diff answers.off.out answers.defslots.out > /dev/null
if ($status) then
	echo "TEST-E-FAIL : answers differ with the default slot count"
	diff answers.off.out answers.defslots.out
else
	echo "answers with the default slot count match answers without a search index"
endif
echo

echo "# Naming the slot count explicitly gets exactly that count. The answers must still be identical."
echo "# mupip set -search_index_size=1024,4096 -region DEFAULT"
$ydb_dist/mupip set -search_index_size=1024,4096 -region DEFAULT |& strip_path
show_size
$ydb_dist/yottadb -run verify^ydb1143 > answers.on.out
$ydb_dist/yottadb -run edges^ydb1143 >> answers.on.out
diff answers.off.out answers.on.out > /dev/null
if ($status) then
	echo "TEST-E-FAIL : answers differ with the MM search index enabled"
	diff answers.off.out answers.on.out
else
	echo "answers with the MM search index match answers without it"
endif
echo

echo "# Rebuild the database WITH the slots in place, so the blocks are written by a process that has"
echo "# search indexes, then check the answers again"
$ydb_dist/yottadb -run build^ydb1143
$ydb_dist/yottadb -run verify^ydb1143 > answers.rebuilt.out
$ydb_dist/yottadb -run edges^ydb1143 >> answers.rebuilt.out
diff answers.off.out answers.rebuilt.out > /dev/null
if ($status) then
	echo "TEST-E-FAIL : answers differ after rebuilding with the MM search index enabled"
	diff answers.off.out answers.rebuilt.out
else
	echo "answers after rebuilding with the MM search index match"
endif
echo

echo "# A block number picks its slot with a mask, so a slot count that is not a power of two is"
echo "# rounded up to one"
echo "# mupip set -search_index_size=1024,1000 -region DEFAULT"
$ydb_dist/mupip set -search_index_size=1024,1000 -region DEFAULT |& strip_path
show_size
echo "# mupip set -search_index_size=1024,3 -region DEFAULT"
$ydb_dist/mupip set -search_index_size=1024,3 -region DEFAULT |& strip_path
show_size
echo

echo "# but a slot count above the maximum is refused, and both fields are left as they were"
echo "# mupip set -search_index_size=1024,1048577 -region DEFAULT >& toomany.out"
$ydb_dist/mupip set -search_index_size=1024,1048577 -region DEFAULT >& toomany.out
$gtm_tst/com/check_error_exist.csh toomany.out MUPIPSET2BIG WCWRNNOTCHG
show_size
echo

echo "# One slot for the whole database is legal, and is the worst case for the slot scheme: every"
echo "# index block maps to slot 0, so each one displaces the last. A search whose slot holds another"
echo "# block's index recognizes that from the block number in the stamp and walks the block the"
echo "# ordinary way, so the answers must be identical here too."
echo "# mupip set -search_index_size=1024,1 -region DEFAULT"
$ydb_dist/mupip set -search_index_size=1024,1 -region DEFAULT |& strip_path
show_size
$ydb_dist/yottadb -run verify^ydb1143 > answers.oneslot.out
$ydb_dist/yottadb -run edges^ydb1143 >> answers.oneslot.out
diff answers.off.out answers.oneslot.out > /dev/null
if ($status) then
	echo "TEST-E-FAIL : answers differ with a single search index slot"
	diff answers.off.out answers.oneslot.out
else
	echo "answers with a single slot match answers without any search index"
endif
echo

echo "# Still on one slot: keys of mixed length in one global, so an index block holds both keys short"
echo "# enough to be sampled and keys longer than the cap, which are not"
$ydb_dist/yottadb -run mix^ydb1143
echo

echo "# and long keys throughout, where few records fit in an index block, still with every block"
echo "# competing for the same slot"
$ydb_dist/yottadb -run %XCMD 'do build^ydb1143(200)'
$ydb_dist/yottadb -run %XCMD 'do verify^ydb1143(200)'
$ydb_dist/yottadb -run %XCMD 'do edges^ydb1143(200)'
echo

echo "# 0 turns the search index off and takes the slot count with it, since slots with no index to"
echo "# put in them would allocate shared memory for nothing"
echo "# mupip set -nosearch_index -region DEFAULT"
$ydb_dist/mupip set -nosearch_index -region DEFAULT |& strip_path
show_size
echo

echo "# With it off, the answers are still the same"
$ydb_dist/yottadb -run %XCMD 'do build^ydb1143(11)' >& /dev/null
$ydb_dist/yottadb -run verify^ydb1143 > answers.final.out
$ydb_dist/yottadb -run edges^ydb1143 >> answers.final.out
diff answers.off.out answers.final.out > /dev/null
if ($status) then
	echo "TEST-E-FAIL : answers differ after disabling the MM search index"
	diff answers.off.out answers.final.out
else
	echo "answers with the MM search index disabled again match"
endif
echo

$gtm_tst/com/dbcheck.csh
echo "# YDB1143 MM SEARCH INDEX TEST DONE"
