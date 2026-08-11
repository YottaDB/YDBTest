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
# tcsh does history expansion inside scripts, and inside double quotes, so the MR number below needs
# the backslash or "!1891" is taken as a history event and the subtest dies on its second line with
# "1891]: Event not found." The backslash is consumed, so the line printed is one character shorter
# than the line here. Same treatment as r206/u_inref/iottflush_assertfix-ydbmr1854.csh.
echo '# [YDB\!1891] ZPEEK at the STATSDB region of a database whose base regions carry NOSTATS            #'
echo "#--------------------------------------------------------------------------------------------------#"
echo

# A base database carrying NOSTATS has no statistics database, so a ZPEEK at the file header of its
# STATSDB region cannot be answered. What the process is told depends on whether it opted in to
# sharing statistics, and both answers are checked below:
#
#   statistics sharing OFF  "gvcst_init" issues DBFILERR with STATSDBFNERR itself. ZPEEK reaches it
#                           by "op_fnzpeek" -> "gv_init_reg" -> "gvcst_init", with no
#                           "gvcst_statsDB_open_ch" in between to catch the error and put it in the
#                           syslog the way an open driven by the base db would, so the user gets it.
#   statistics sharing ON   "gvcst_init" instead returns with the region unopened, and "op_fnzpeek"
#                           turns that into BADZPEEKARG after testing "reg->open".
#
# A pro build has always answered both ways. A debug build died instead, on one assert per path, each
# assuming a region always comes back open. "gvcst_init" asserted that the statsDB open condition
# handler was established, which only the first path makes true; YottaDB/DB/YDB!1891 removed it.
# "gv_init_reg" asserted the region was open on return, which the second path never makes true; the
# YDB MR this subtest is named for removed that one.
#
# The test system randomizes statistics sharing, so pin it rather than take whichever path the run
# happens to choose. Taking only one of them would leave one of the two asserts uncovered, and which
# one would vary from run to run. Both names for the setting are used, since the newer one wins if
# anything in the environment has set it.
#
# No explicit check that the process survived is needed. If either assert comes back the process
# cores, and the test framework fails any subtest that leaves core files behind.

# The huge db scheme puts -nostats on every region of a replication test. This is not one, so it
# would not apply, but turn it off anyway so that the -nostats below is the only thing that can be
# responsible for what the test sees.
setenv ydb_test_4g_db_blks 0

$gtm_tst/com/dbcreate.csh mumps -nostats

echo "# ZPEEK at a file header field of the STATSDB region belonging to the NOSTATS base region, with"
echo "# statistics sharing OFF. A STATSDB region is named for its base region in lower case, so"
echo "# DEFAULT gives default. gvcst_init issues the error itself and the user gets it."
setenv ydb_statshare 0
setenv gtm_statshare 0
$gtm_dist/mumps -run %XCMD 'write $$^%PEEKBYNAME("sgmnt_data.freeze_on_fail","default"),!' >& zpeek_nostatshare.out
$gtm_tst/com/check_error_exist.csh zpeek_nostatshare.out DBFILERR STATSDBFNERR
echo

echo "# The same ZPEEK with statistics sharing ON. gvcst_init returns with the region unopened and"
echo "# op_fnzpeek reports that instead."
setenv ydb_statshare 1
setenv gtm_statshare 1
$gtm_dist/mumps -run %XCMD 'write $$^%PEEKBYNAME("sgmnt_data.freeze_on_fail","default"),!' >& zpeek_statshare.out
$gtm_tst/com/check_error_exist.csh zpeek_statshare.out BADZPEEKARG
echo

echo "# The base region is still usable afterwards"
$gtm_dist/mumps -run %XCMD 'set ^x=1 write "^x=",^x,!'
echo

$gtm_tst/com/dbcheck.csh
echo "# YDBMR1891 STATSDB ZPEEK NOSTATS TEST DONE"
