#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test signal forwarding enable/disable.
#
# Turn off ydb_dbglvl/gtmdbglvl as certain settings can influence how this test runs.
#
unsetenv ydb_dbglvl
unsetenv gtmdbglvl
echo "-------------------------------------------------------------------------------------"
echo "ydb478: Tests that after the ydb_exit() call (via yottadb.Exit()), Go is still able"
echo "        to field signal interrupts. Tests each signal from 1-64 though some of these"
echo "        will fail since they are not handle-able or they create cores so some signals"
echo "        are bypassed."
#
# Create database we need. This DB is accessed but not really updated and just so the environment exists
# so we don't both with replication on this test.
#
$gtm_tst/com/dbcreate.csh mumps -gld_has_db_fullpath >>& dbcreate.out
if ($status) then
        echo "# dbcreate failed. Output of dbcreate.out follows"
        cat dbcreate.out
endif
#
# Set up the golang environment and sets up our repo
#
source $gtm_tst/com/setupgoenv.csh # Do our golang setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $go_repo)
set status1 = $status
if ($status1) then
	echo "[source $gtm_tst/$tst/u_inref/setupgoenv.csh] failed with status [$status1]. Exiting..."
	exit 1
endif
#
# Build executable
#
echo "** First build ydb478 executable to create a handler for a given signal and see"
echo "** if things work properly after the YDB environment is initialized and then gets"
echo "** shutdown."
echo
#
cd go/src
mkdir ydb478
cd ydb478
ln -s $gtm_tst/$tst/inref/ydb478.go .
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to soft link threeenp1B1.go to current directory ($PWD)"
    exit 1
endif
# Build our routine (must be built due to use of cgo).
echo "# Building ydb478"
$gobuild >& go_build.log
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to build ydb478.go. go_build.log output follows."
    cat go_build.log
    exit 1
endif
#
# Note: We need to set the global directory to an absolute path because we are operating in a subdirectory
# ($tstpath/go/src/threeenp1B1) where the default test framework assignment of ydb_gbldir
# to a relative path (i.e. mumps.gld) is no longer relevant.
setenv ydb_gbldir $tstpath/mumps.gld
#
# Drive ydb478.m which will drive our Go routine once for each signal type to see if it can be intercepted. Since this
# routine only currently runs with a PRO build (differences between PRO run and DBG run are significant due to how fatal signals
# are handled at this time), we should see the signal forwarded from all but the restricted signals. Some of those generate
# errors (i.e. SIGKILL and SIGSTOP are not catchable so generate runtime errors when we try to setup a handler for them). The
# others though will generate timeouts or suspend the process (temporarily - they resume very quickly).
$ydb_dist/yottadb -run ydb478
#
$gtm_tst/com/dbcheck.csh
