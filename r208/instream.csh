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
# search_index_gde-ydb1143		[nars]	Test the SEARCH_INDEX_SIZE and SEARCH_INDEX_SLOTS global directory characteristics, the format label change and that segment templates survive a reopen
# search_index_misc-ydb1143		[nars]	Test MUPIP SET standalone access, MUPIP REORG with the feature on, and that a statsDB gets no search index
# ydbenv_mkdir_stderr-ydb1267		[nars]	Test %YDBENV reports the stderr of a failed "mkdir -p" in its CREATEFAIL error
# intrpt_readline-ydb1269		[nars]	Test MUPIP INTRPT at a readline direct mode prompt drives $ZINTERRUPT and restores the typed line
# pipe_stderr_writeonly-ydb1268		[nars]	Test the stderr= device of a PIPE is readable when the OPEN also specifies writeonly
# spsize_2gib-ydb1280			[nars]	Test $VIEW("SPSIZE") and $VIEW("SPSIZESORT") report sizes of 2GiB or more correctly
# stp_gcol_repeat-ydb1281		[nars]	Test VIEW "STP_GCOL" does not expand the stringpool when it reclaims no space
# revquery_ancestor-ydb1285		[nars]	Test reverse $QUERY() and ydb_node_previous_s() on a local variable return an ancestor that has a value but no descendants
# fork_deferred_timer-ydb1291		[nars]	Test a SimpleAPI process forked while a flush timer was deferred can make YottaDB calls in the child
# char_code_overflow-ydb1288		[nars]	Test $C()/$ZCH() arguments in a ZWRITE format string and trigger -pieces= values too large for an int are rejected, not wrapped around
# zwr2str_invalid-ydb1286		[nars]	Test $ZWRITE(str,1), ydb_zwr2str_s(), MUPIP LOAD and trigger -delim= reject a str that is not a complete ZWRITE format string without reading past its end
# mupip_load_ze-ydb1289			[nars]	Test MUPIP LOAD of a ZWR file with over 2.3 million $ze(...) records stays within its line buffer
# load_zwr_cut_key-ydb1287		[nars]	Test MUPIP LOAD does not read past the end of a ZWR record whose key is cut short, and a source or receiver server does not SIG-11 on a filter's $ze(...) key
# stp_gcol_free-ydb1284			[nars]	Test VIEW "STP_GCOL_FREE" returns the unused part of the stringpool to the operating system
# enospc_mupip_stop-ydb1300		[nars]	Test a MUPIP STOP of a process waiting for disk space does not make it exit holding the journal pool lock
# readline_lazy_load-ydb1294		[nars]	Test a process loads the readline history file only when it reads from a terminal through readline
# readline_truncate_fallback-ydb1295	[nars]	Test the readline history file is kept to 1000 entries even if history_truncate_file() fails
# pthread_exit_nomem-ydb1292		[nars]	Test a MUPIP JOURNAL worker thread that exits when no more memory can be mapped does not abort the process
# pipe_read_timer_pop-ydb1296		[nars]	Test a timed READ of a PIPE device returns when its timeout expires even if the timer pops between two read() calls
# fork_core_in_malloc-ydb1293		[nars]	Test a process sent a fatal signal while inside malloc() dies with a core instead of hanging
# lock_err_cleanup-ydb1302		[nars]	Test an error inside a LOCK does not make a later LOCK + report success without acquiring the lock, or the next simpleAPI lock call issue BADLOCKNEST
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
setenv subtest_list_non_replic	"$subtest_list_non_replic zsigproc_pid0-ydb1256"
setenv subtest_list_non_replic	"$subtest_list_non_replic jnl_horolog_time-ydb1258"
setenv subtest_list_non_replic	"$subtest_list_non_replic ydbenv_mkdir_stderr-ydb1267"
setenv subtest_list_non_replic	"$subtest_list_non_replic intrpt_readline-ydb1269"
setenv subtest_list_non_replic	"$subtest_list_non_replic pipe_stderr_writeonly-ydb1268"
setenv subtest_list_non_replic	"$subtest_list_non_replic spsize_2gib-ydb1280"
setenv subtest_list_non_replic	"$subtest_list_non_replic stp_gcol_repeat-ydb1281"
setenv subtest_list_non_replic	"$subtest_list_non_replic revquery_ancestor-ydb1285"
setenv subtest_list_non_replic	"$subtest_list_non_replic fork_deferred_timer-ydb1291"
setenv subtest_list_non_replic	"$subtest_list_non_replic char_code_overflow-ydb1288"
setenv subtest_list_non_replic	"$subtest_list_non_replic zwr2str_invalid-ydb1286"
setenv subtest_list_non_replic	"$subtest_list_non_replic mupip_load_ze-ydb1289"
setenv subtest_list_non_replic	"$subtest_list_non_replic load_zwr_cut_key-ydb1287"
setenv subtest_list_non_replic	"$subtest_list_non_replic stp_gcol_free-ydb1284"
setenv subtest_list_non_replic	"$subtest_list_non_replic readline_lazy_load-ydb1294"
setenv subtest_list_non_replic	"$subtest_list_non_replic readline_truncate_fallback-ydb1295"
setenv subtest_list_non_replic	"$subtest_list_non_replic pthread_exit_nomem-ydb1292"
setenv subtest_list_non_replic	"$subtest_list_non_replic pipe_read_timer_pop-ydb1296"
setenv subtest_list_non_replic	"$subtest_list_non_replic fork_core_in_malloc-ydb1293"
setenv subtest_list_non_replic	"$subtest_list_non_replic lock_err_cleanup-ydb1302"
setenv subtest_list_replic	""
setenv subtest_list_replic	"$subtest_list_replic enospc_mupip_stop-ydb1300"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

# spsize_2gib-ydb1280 fills the stringpool with 2100MiB of live strings and the process peaks at about 8GiB,
# so exclude it on systems with less than 16GiB of memory, where it would risk the out-of-memory killer.
set ramsize = `grep MemTotal /proc/meminfo | $tst_awk '{print int($2/1000000);}'`
if ($ramsize < 16) then
	setenv subtest_exclude_list "$subtest_exclude_list spsize_2gib-ydb1280"
endif

# stp_gcol_free-ydb1284 measures how much memory the C library returns to the operating system. With ASAN, YottaDB
# uses the ASAN allocator, which keeps freed memory in quarantine and is not affected by malloc_trim(), so exclude it.
source $gtm_tst/com/is_libyottadb_asan_enabled.csh	# detect asan build into $gtm_test_libyottadb_asan_enabled
if ($gtm_test_libyottadb_asan_enabled) then
	setenv subtest_exclude_list "$subtest_exclude_list stp_gcol_free-ydb1284"
	# pthread_exit_nomem-ydb1292 limits the address space of a MUPIP process to what it is using, which leaves the
	# ASAN allocator no room to map memory, so exclude it.
	setenv subtest_exclude_list "$subtest_exclude_list pthread_exit_nomem-ydb1292"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	# enospc_mupip_stop-ydb1300 uses gdb to turn on fake ENOSPC, which exists only in Debug builds
	setenv subtest_exclude_list "$subtest_exclude_list enospc_mupip_stop-ydb1300"
	# readline_truncate_fallback-ydb1295 needs a white box test case, which only a dbg build supports
	setenv subtest_exclude_list "$subtest_exclude_list readline_truncate_fallback-ydb1295"
	# pipe_read_timer_pop-ydb1296 needs white-box case 412, which only Debug builds have
	setenv subtest_exclude_list "$subtest_exclude_list pipe_read_timer_pop-ydb1296"
	# fork_core_in_malloc-ydb1293 needs a white box test case, which only a Debug build has
	setenv subtest_exclude_list "$subtest_exclude_list fork_core_in_malloc-ydb1293"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r208 test DONE."
