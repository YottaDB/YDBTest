#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################

# Called by both gtmtest.csh and settest.csh to clear problematic ydb_* environment variables

# The test system currently sets/uses/modifies GT.M env vars (e.g. "gtmgbldir"), not YottaDB env vars (e.g. "ydb_gbldir"),
# because it must run some GTM tests. This means if the environment contains ydb_ env vars, they would override the
# test system's gtm_* env vars since YDB is designed to prefer ydb_* vars. Therefore, unset the ydb_* env vars that matter.
# Also unset corresponding GT.M env vars since the test will set them later anyway.
unsetenv ydb_boolean		gtm_boolean
unsetenv ydb_chset		gtm_chset
unsetenv ydb_ci			GTMCI
unsetenv ydb_etrap		gtm_etrap
unsetenv ydb_gbldir		gtmgbldir
unsetenv ydb_routines		gtmroutines
unsetenv ydb_side_effects	gtm_side_effects
unsetenv ydb_xc_ydbposix	GTMXC_ydbposix
unsetenv ydb_readline
unsetenv ydb_statshare		gtm_statshare
unsetenv ydb_statsdir		gtm_statsdir	# this is defined to $tst_working_dir later in submit_subtest.csh
unsetenv ydb_noundef		gtm_noundef
unsetenv ydb_repl_instance	gtm_repl_instance
unsetenv ydb_procstuckexec	gtm_procstuckexec
unsetenv ydb_tmp		gtm_tmp

# LD_LIBRARY_PATH could be set by "ydb_env_set" and could affect the test system so unset this too at the start of the test.
# (see https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1536#note_1193117974 for background)
unsetenv LD_LIBRARY_PATH
# Note that we do not do a blanket "unsetenv" of all "ydb_*" and "gtm*" env vars. This is because there are a few that
# the test framework still needs (e.g. "gtm_dist", "gtm_test_*", "gtm_tst_*") from the parent environment.
# See https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1536#note_1193225854 for more details.
