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
#
#----------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#----------------------------------------------------------------------------------------------------------------------------------
# iottresetterm_skipnopricio-ydb1227	[jon]	Test skip issuing NOPRINCIO error in iott_resetterm.c if exiting (fixes SIG-11)
# etc_mtab_eofline-ydb1228		[jon]	Test $ZEOF works correctly for files which are soft links to files in the /proc file system
# reorg_trunc_concurrent-ydb1245	[nars]	Test MUPIP REORG -TRUNCATE frees up space even in the presence of concurrent updates
# reorg_trunc_hidden_gbl-ydb1240	[nars]	Test MUPIP REORG -TRUNCATE processes globals in .dat files that are hidden by the .gld
# zwrite_alias_orphan-ydb1101		[sam]	Test ZWRITE of an orphaned alias container does not overflow its subscript work array
# pipe_parse_cmdlen-ydb1101		[sam]	Test PIPE OPEN with PARSE bounds the copy of an over-long unresolvable command word
# pipe_parse_longpath-ydb1101		[sam]	Test PIPE OPEN with PARSE does not read past the end of its $PATH buffer
# sigwinch_devparam-ydb1247		[nars]	Test the SIGWINCH deviceparameter refreshes WIDTH/LENGTH and XECUTEs its handler on a terminal window resize
# gde_sigwinch-ydb1247			[nars]	Test GDE uses the SIGWINCH deviceparameter to keep up with terminal window resizes
# sigwinch_readline-ydb1247		[nars]	Test the SIGWINCH deviceparameter at a readline direct mode prompt
# trigger_open_range-ydb1249		[nars]	Test a trigger subscript specification with an open ended range is read back from ^#t correctly
# statsdb_zpeek_nostats-ydbmr1891	[nars]	Test ZPEEK at the STATSDB region of a database whose base regions carry NOSTATS
# search_index-ydb1143			[nars]	Test MUPIP SET -SEARCH_INDEX_SIZE and that searches using the index find the same records
# search_index_mm-ydb1143		[nars]	Test the MM search index, where a block number picks one of a fixed number of slots
# search_index_upgrade-ydb1143		[nars]	Test that a database created by an older release picks up search index characteristics on upgrade
# search_index_slots-ydb1143		[nars]	Test MUPIP SET -SEARCH_INDEX_SIZE=bytes keeps the slot count the database already has
# search_index_gde-ydb1143		[nars]	Test the SEARCH_INDEX_SIZE and SEARCH_INDEX_SLOTS global directory characteristics and the format label change
# search_index_misc-ydb1143		[nars]	Test MUPIP SET standalone access, MUPIP REORG with the feature on, and that a statsDB gets no search index
#----------------------------------------------------------------------------------------------------------------------------------

echo "r208 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	""
setenv subtest_list_non_replic	"$subtest_list_non_replic iottresetterm_skipnopricio-ydb1227"
setenv subtest_list_non_replic	"$subtest_list_non_replic etc_mtab_eofline-ydb1228"
setenv subtest_list_non_replic	"$subtest_list_non_replic reorg_trunc_concurrent-ydb1245"
setenv subtest_list_non_replic	"$subtest_list_non_replic reorg_trunc_hidden_gbl-ydb1240"
setenv subtest_list_non_replic	"$subtest_list_non_replic zwrite_alias_orphan-ydb1101"
setenv subtest_list_non_replic	"$subtest_list_non_replic pipe_parse_cmdlen-ydb1101"
setenv subtest_list_non_replic	"$subtest_list_non_replic pipe_parse_longpath-ydb1101"
setenv subtest_list_non_replic	"$subtest_list_non_replic sigwinch_devparam-ydb1247"
setenv subtest_list_non_replic	"$subtest_list_non_replic gde_sigwinch-ydb1247"
setenv subtest_list_non_replic	"$subtest_list_non_replic sigwinch_readline-ydb1247"
setenv subtest_list_non_replic	"$subtest_list_non_replic trigger_open_range-ydb1249"
setenv subtest_list_non_replic	"$subtest_list_non_replic statsdb_zpeek_nostats-ydbmr1891"
setenv subtest_list_non_replic	"$subtest_list_non_replic search_index-ydb1143"
setenv subtest_list_non_replic	"$subtest_list_non_replic search_index_mm-ydb1143"
setenv subtest_list_non_replic	"$subtest_list_non_replic search_index_upgrade-ydb1143"
setenv subtest_list_non_replic	"$subtest_list_non_replic search_index_slots-ydb1143"
setenv subtest_list_non_replic	"$subtest_list_non_replic search_index_gde-ydb1143"
setenv subtest_list_non_replic	"$subtest_list_non_replic search_index_misc-ydb1143"
setenv subtest_list_replic	""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r208 test DONE."
