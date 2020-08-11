#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Test to purposely create a deadlock by creating a TP transaction and then inside it doing a GET type call"
echo "# but using yottadb.NOTTP as the tptoken instead of the tptoken created for us and passed into the callback"
echo "# routine. Prior to a late fix to YDB#561, this was working anyway so this test is to make sure that does NOT"
echo "# happen anymore. In the future, when we add a deadlock detector, this test should morph into a test for that"
echo "# support."
$gtm_tst/com/dbcreate.csh mumps -gld_has_db_fullpath >>& dbcreate.out
if ($status) then
        echo "# dbcreate failed. Output of dbcreate.out follows"
        cat dbcreate.out
endif
#
# Set up the golang environment and sets up our repo
#
source $gtm_tst/com/setupgoenv.csh # Do our Go setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $go_repo)
set status1 = $status
if ($status1) then
	echo "[source $gtm_tst/$tst/u_inref/setupgoenv.csh] failed with status [$status1]. Exiting..."
	exit 1
endif

cd go/src
mkdir deadlock
cd deadlock
ln -s $gtm_tst/$tst/inref/deadlock.go .
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to soft link deadlock.go to current directory ($PWD)"
    exit 1
endif
# Build our routine (must be built due to use of cgo).
echo "# Building deadlock"
$gobuild >& go_build.log
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to build deadlock.go. go_build.log output follows."
    cat go_build.log
    exit 1
endif
#
# Note: We need to set the global directory to an absolute path because we are operating in a subdirectory
# ($tstpath/go/src/deadlock) where the default test framework assignment of ydb_gbldir
# to a relative path (i.e. mumps.gld) is no longer relevant.
setenv ydb_gbldir $tstpath/mumps.gld
#
# Run it in the background..
echo "# Running deadlock"
(`pwd`/deadlock < /dev/null > deadlock.out & ; echo $! >&! deadlock.pid) >& deadlock.err
set bgpid = `cat deadlock.pid`
# Wait a bit longer than the 1 second C tests wait - this is Go so wait 10 seconds..
$gtm_tst/com/wait_for_proc_to_die.csh $bgpid 10 >& wait_for_proc.deadlock.outx
if (! $status) then
    echo " --> Process terminated but was not expected to"
else
    echo " --> Process did not terminate just like it was expected to"
endif
echo "# Sending : [kill -9] to backgrounded SimpleAPI application to terminate it"
kill -9 $bgpid
set sleeptime = 60
$gtm_tst/com/wait_for_proc_to_die.csh $bgpid $sleeptime
echo ""
#
# The kill -9 probably left stuff behind - clean it up.
$MUPIP rundown -reg "*"
#
$gtm_tst/com/dbcheck.csh -extract >>& dbcheck.out
if ($status) then
        echo "# dbcheck failed. Output of dbcheck.out follows"
        cat dbcheck.out
endif
echo "# Done!"
