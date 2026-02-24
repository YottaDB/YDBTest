#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2018-2026 YottaDB LLC and/or its subsidiaries.  #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#

echo "# Run the Go wrapper unit tests; if there is a failure, additional output will cause the test to fail"

# Use -gld_has_db_fullpath to ensure gld is created with full paths pointing to the database file
# (see comment before "setenv ydb_gbldir" done below for why).
if ($?test_replic) then
	# Need to use MSR framework whenever -gld_has_db_fullpath is in use (non-MSR replication does not work currently)
	$MULTISITE_REPLIC_PREPARE 2	# Create two instances INST1 (primary side) and INST2 (secondary side)
endif

$gtm_tst/com/dbcreate.csh mumps -gld_has_db_fullpath >>& dbcreate.out || \
	echo "# dbcreate failed. Output of dbcreate.out follows" && cat dbcreate.out
if ($?test_replic) then
	$MSR START INST1 INST2 # Start replication servers
endif

# This script is invoked from the "go" test and the "timing" test.
# Since we do not want to maintain a duplicate copy in each test, we keep it in only the "go" test
# Do our golang setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $ydbgo_url, $goflags)
source $gtm_tst/com/setupgoenv.csh >& setupgoenv.out || \
	echo "[source $gtm_tst/com/setupgoenv.csh] failed with status [$status]:" && cat setupgoenv.out && exit 1

# Remove these (if created by setupgoenv.csh above) since it's simpler without them when using git checkout of YDBGo below
rm -f go.mod go.work

# By far the easiest way to test YDBGo is to get it from the git repository.
# Previous versions tried to test it using 'go get $ydbgo_url' but that fetch YDBGo into a location that:
#  - tends to have permissions problems, and
#  - does not have v2 in the v2 subdirectory like the unit tests need.
if ( ! -d YDBGo ) then
	# clone -depth 1 gets only the latest version for testing (faster)
	set ydbgo_repo = "https://gitlab.com/YottaDB/Lang/YDBGo.git"
	git clone -q --depth 1 $ydbgo_repo $tstpath/YDBGo >>& ydbgo_clone.out || \
		echo "[git clone --depth 1 $ydbgo_repo:q] failed with status [$status]:" && cat ydbgo_clone.out && exit 1
endif

# We need to set the global directory to an absolute path because "go test" operates in a subdirectory
# where the default test framework assignment of ydb_gbldir to a relative path (i.e. mumps.gld) is no longer relevant.
setenv ydb_gbldir $tstpath/mumps.gld

# For v1 test, set ydb_ci to the calltab for the Go routines, and ensure the ydb_routines
#  path includes the folder housing the helper routines used by some go tests
setenv ydb_ci "$PWD/YDBGo/calltab.ci"
if ($tst == "timing") then
	# We run the timing tests in this version.
	# So we do not set the YDB_GO_SKIP_TIMED_TESTS env var to "yes" like we do for the non-timing test case.
else
	# Skip timing tests
	setenv YDB_GO_SKIP_TIMED_TESTS "yes"
endif
# We use gtmroutines here since the test framework still uses it, rather than ydb_routines
setenv gtmroutines ".($tstpath/YDBGo/m_routines/) $gtmroutines"
if ($?test_replic) then
	# In case of replication tests, set replication instance env var too just like we did the gld above
	setenv ydb_repl_instance $tstpath/mumps.repl
endif

# Unit test YDBGo v1
echo "# Running : go test on YDBGo"
go test -C YDBGo $goflags >& $tstpath/go_test.log || \
	echo "TEST-E-FAILED : [go test -C YDBGo $goflags] failed for v1:" && cat $tstpath/go_test.log

# Unit test YDBGo v2
echo "# Running : go test on YDBGo v2"
go test -C YDBGo/v2 $goflags -testdb=$ydb_gbldir >& $tstpath/go_test2.log || \
	echo "TEST-E-FAILED : [go test -C YDBGo/v2 $goflags] failed for v2:" && cat $tstpath/go_test2.log

if ($?test_replic) then
	unsetenv ydb_repl_instance
endif
unsetenv ydb_gbldir

$gtm_tst/com/dbcheck.csh -extract >>& dbcheck.out || \
	echo "# dbcheck failed. Output of dbcheck.out follows" && cat dbcheck.out
