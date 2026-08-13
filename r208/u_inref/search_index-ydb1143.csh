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
echo "# [#1143] MUPIP SET -SEARCH_INDEX_SIZE, and searches that use the index it enables                 #"
echo "#--------------------------------------------------------------------------------------------------#"
echo

# BG and MM now address search index slots the same way, but they allocate them from different parts
# of the shared segment, so force BG to keep this subtest exercising one of the two. See the note
# about MM at the end.
source $gtm_tst/com/gtm_test_setbgaccess.csh
# This subtest compares the file header field and MUPIP SET output exactly, so keep the test system
# from changing the database underneath it.
setenv gtm_test_use_V6_DBs 0
setenv test_reorg NON_REORG

# Reports the field the way DSE shows it, with the spacing squeezed out so the reference file does not
# depend on column positions.
alias show_size 'echo "dump -fileheader" | $ydb_dist/dse |& grep -i "Search Index Size" | sed "s/  */ /g"'
# MUPIP SET names the database file in its confirmation, and that path varies by test run.
alias strip_path 'sed "s;Database file .* now has;Database file now has;"'

$gtm_tst/com/dbcreate.csh mumps 1 250 1024 4096

echo "# MUPIP CREATE enables search indexes: a quarter of the 4096 byte block size, and the default"
echo "# slot count. Nothing below had to ask for them."
show_size
echo

echo "# Turn them off to record the baseline. Everything below has to match these answers, so they"
echo "# have to come from a database that is definitely not using a search index."
echo "# mupip set -nosearch_index -region DEFAULT"
$ydb_dist/mupip set -nosearch_index -region DEFAULT |& strip_path
echo "# mumps -run %XCMD, do peek^ydb1143 : the baseline must really have NO index, otherwise"
echo "# every later comparison is against another indexed run and proves nothing"
$ydb_dist/mumps -run %XCMD 'set ^a=1 do peek^ydb1143("DEFAULT",0)'
show_size
echo

echo "# Populate and record the answers with NO search index. Everything below has to match these."
$ydb_dist/yottadb -run build^ydb1143
$ydb_dist/yottadb -run verify^ydb1143 > answers.off.out
$ydb_dist/yottadb -run edges^ydb1143 >> answers.off.out
cat answers.off.out
echo

echo "# Turn it back on. This needs standalone access, unlike the reserved-bytes qualifiers, because"
echo "# the size decides how large the shared segment is and so cannot change under attached processes."
echo "# mupip set -search_index_size=1024 -region DEFAULT"
$ydb_dist/mupip set -search_index_size=1024 -region DEFAULT |& strip_path
echo "# mumps -run %XCMD, do peek^ydb1143 : and with it enabled the index really is present"
$ydb_dist/mumps -run %XCMD 'set ^a=1 do peek^ydb1143("DEFAULT",1)'
show_size
echo

echo "# Same database, same data, now searched using the index: the answers must be identical"
$ydb_dist/yottadb -run verify^ydb1143 > answers.on.out
$ydb_dist/yottadb -run edges^ydb1143 >> answers.on.out
diff answers.off.out answers.on.out > /dev/null
if ($status) then
	echo "TEST-E-FAIL : answers differ with the search index enabled"
	diff answers.off.out answers.on.out
else
	echo "answers with the index match answers without it"
endif
echo

echo "# Rebuild the database WITH the index enabled, so the blocks are written by a process that has"
echo "# one, then check the answers again"
$ydb_dist/yottadb -run build^ydb1143
$ydb_dist/yottadb -run verify^ydb1143 > answers.rebuilt.out
$ydb_dist/yottadb -run edges^ydb1143 >> answers.rebuilt.out
diff answers.off.out answers.rebuilt.out > /dev/null
if ($status) then
	echo "TEST-E-FAIL : answers differ after rebuilding with the search index enabled"
	diff answers.off.out answers.rebuilt.out
else
	echo "answers after rebuilding with the index match"
endif
echo

echo "# Keys of mixed length in one global. Keys longer than the cap are not sampled, so an index"
echo "# block can hold a mixture of sampled and unsampled records; both must still be found."
$ydb_dist/yottadb -run mix^ydb1143
echo

echo "# Long keys throughout, where few records fit in an index block"
$ydb_dist/yottadb -run %XCMD 'do build^ydb1143(200)'
$ydb_dist/yottadb -run %XCMD 'do verify^ydb1143(200)'
$ydb_dist/yottadb -run %XCMD 'do edges^ydb1143(200)'
echo

echo "# Values are rounded up to a multiple of 8"
echo "# mupip set -search_index_size=1001 -region DEFAULT"
$ydb_dist/mupip set -search_index_size=1001 -region DEFAULT |& strip_path
show_size
echo

echo "# and anything below the minimum is raised to it"
echo "# mupip set -search_index_size=8 -region DEFAULT"
$ydb_dist/mupip set -search_index_size=8 -region DEFAULT |& strip_path
show_size
echo

echo "# but a value above the maximum is refused, and the field is left as it was. 8192 is the largest"
echo "# search index any database may have, and the 4096 byte blocks here cap it lower still, so even"
echo "# that absolute maximum is refused, with the ceiling this block size imposes, 4088, quoted. The"
echo "# last stage of this subtest reaches 8192 on a database whose blocks are large enough for it."
echo "# mupip set -search_index_size=8192 -region DEFAULT >& toobig.out"
$ydb_dist/mupip set -search_index_size=8192 -region DEFAULT >& toobig.out
$gtm_tst/com/check_error_exist.csh toobig.out MUPIPSET2BIG WCWRNNOTCHG
show_size
echo

echo "# The block size is a ceiling of its own. An index at least as large as the block it summarizes"
echo "# only samples the keys of that block, so it cannot pay for itself and is refused too, with the"
echo "# same 4088 quoted."
echo "# mupip set -search_index_size=4096 -region DEFAULT >& toobigforblk.out"
$ydb_dist/mupip set -search_index_size=4096 -region DEFAULT >& toobigforblk.out
$gtm_tst/com/check_error_exist.csh toobigforblk.out MUPIPSET2BIG WCWRNNOTCHG
show_size
echo

echo "# A negative size, and a negative slot count, are refused before any database file is opened,"
echo "# and neither field changes. The qualifier is a string rather than a number so that it can hold"
echo "# the comma, which puts it outside the non-negative check the CLI applies to numeric qualifiers,"
echo "# so MUPIP SET checks the sign of both numbers itself."
echo "# mupip set -search_index_size=-1 -region DEFAULT >& negsize.out"
$ydb_dist/mupip set -search_index_size=-1 -region DEFAULT >& negsize.out
$gtm_tst/com/check_error_exist.csh negsize.out SETQUALPROB WCERRNOTCHG
echo "# mupip set -search_index_size=1024,-1 -region DEFAULT >& negslots.out"
$ydb_dist/mupip set -search_index_size=1024,-1 -region DEFAULT >& negslots.out
$gtm_tst/com/check_error_exist.csh negslots.out SETQUALPROB WCERRNOTCHG
show_size
echo

echo "# 8 below the block size is the largest that is accepted. That size samples an index block far more"
echo "# densely than 1024 does, so the answers have to hold there too."
echo "# mupip set -search_index_size=4088 -region DEFAULT"
$ydb_dist/mupip set -search_index_size=4088 -region DEFAULT |& strip_path
show_size
$ydb_dist/yottadb -run %XCMD 'do build^ydb1143(11)' >& /dev/null
$ydb_dist/yottadb -run verify^ydb1143 > answers.max.out
$ydb_dist/yottadb -run edges^ydb1143 >> answers.max.out
diff answers.off.out answers.max.out > /dev/null
if ($status) then
	echo "TEST-E-FAIL : answers differ at the largest search index size this block size allows"
	diff answers.off.out answers.max.out
else
	echo "answers at the largest allowed size match"
endif
echo

echo "# One slot for the whole database is legal, and is the worst case for the slot scheme: every"
echo "# index block maps to slot 0, so each one displaces the last. A search whose slot holds another"
echo "# block's index recognizes that from the block number in the stamp and walks the block the"
echo "# ordinary way, so the answers must be identical here too. The MM subtest covers the same case"
echo "# for MM, and this is its BG counterpart : the two access methods reach their slots by the same"
echo "# mask, so a fault in that arithmetic would show on either, but only BG displaces a slot from"
echo "# phase 2 of commit, outside crit, which MM never does."
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

echo "# -NOSEARCH_INDEX turns it off again and frees the space. Note that -SEARCH_INDEX_SIZE=0 does"
echo "# NOT do this : 0 asks for the default size, the same as it does in a global directory."
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
	echo "TEST-E-FAIL : answers differ after disabling the search index"
	diff answers.off.out answers.final.out
else
	echo "answers with the index disabled again match"
endif
echo

# NO MM STAGE HERE, deliberately. MM is covered by search_index_mm-ydb1143 instead, as its own
# subtest rather than a stage of this one. Converting the database this subtest builds cannot work,
# because MM coexists with neither ASYNCIO nor BEFORE image journaling and the test system randomizes
# both, and a second database created here inherits the same randomized settings, so it could not be
# an MM one either. A separate subtest gets to settle those before it creates anything.

# The main database is checked HERE rather than at the end of the subtest, because the second
# database created below moves every .dat file in the directory aside before it creates its own -
# see "move" in com/dbcreate_multi.awk - which leaves the region of this one with no file to check.
$gtm_tst/com/dbcheck.csh
echo

echo "# 8192 is the ceiling every database shares, and it only binds on a database whose blocks are"
echo "# larger than that. The database above cannot reach it, so here is a second one with 16384 byte"
echo "# blocks : 8 below its block size is 16376, so 8192 is what caps a search index there, and it is"
echo "# accepted rather than refused."
setenv gtmgbldir big.gld
$gtm_tst/com/dbcreate.csh big 1 250 1024 16384 >&! big-dbcreate.out
echo "# MUPIP CREATE gives it a quarter of its 16384 byte block size, as it does at any block size"
show_size
echo

echo "# 8192, the largest search index any database may have, is accepted here"
echo "# mupip set -search_index_size=8192 -region DEFAULT"
$ydb_dist/mupip set -search_index_size=8192 -region DEFAULT |& strip_path
show_size
echo

echo "# and 8193, the first size above that ceiling, is refused with 8192 quoted rather than the"
echo "# 16376 this block size would otherwise allow"
echo "# mupip set -search_index_size=8193 -region DEFAULT >& bigtoobig.out"
$ydb_dist/mupip set -search_index_size=8193 -region DEFAULT >& bigtoobig.out
$gtm_tst/com/check_error_exist.csh bigtoobig.out MUPIPSET2BIG WCWRNNOTCHG
show_size
echo

$gtm_tst/com/dbcheck.csh >&! big-dbcheck.out
setenv gtmgbldir mumps.gld

echo "# YDB1143 SEARCH INDEX TEST DONE"
