#################################################################
#								#
# Copyright (c) 2019-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This test/demo drives the golang flavor of the 3n+1 routine that uses fully embedded (closure) functions thus sharing
# keys and such. This differs from threeenp1B2 which has separate routines and uses a block of storage to share things.
#
# Create database threeenp1B1 needs:
#
# Use -gld_has_db_fullpath to ensure gld is created with full paths pointing to the database file
# (see comment before "setenv ydb_gbldir" done below for why).
if ($?test_replic) then
	# Need to use MSR framework whenever -gld_has_db_fullpath is in use (non-MSR replication does not work currently)
	$MULTISITE_REPLIC_PREPARE 2	# Create two instances INST1 (primary side) and INST2 (secondary side)
endif
$gtm_tst/com/dbcreate.csh mumps -gld_has_db_fullpath >>& dbcreate.out
if ($status) then
        echo "# dbcreate failed. Output of dbcreate.out follows"
        cat dbcreate.out
endif
if ($?test_replic) then
    $MSR START INST1 INST2 # Start replication servers
endif
#
# Set up the golang environment and sets up our repo
#
source $gtm_tst/com/setupgoenv.csh # Do our golang setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $go_repo)
set status1 = $status
if ($status1) then
	echo "[source $gtm_tst/com/setupgoenv.csh] failed with status [$status1]. Exiting..."
	exit 1
endif

cd go/src
mkdir threeenp1B1
cd threeenp1B1
ln -s $gtm_tst/$tst/inref/threeenp1B1.go .
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to soft link threeenp1B1.go to current directory ($PWD)"
    exit 1
endif
# Build our routine (must be built due to use of cgo).
echo "# Building threeenp1B1"
$gobuild >& go_build.log
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to build threeenp1B1.go. go_build.log output follows."
    cat go_build.log
    exit 1
endif
#
# Run it with one range
#
# Note: We need to set the global directory to an absolute path because we are operating in a subdirectory
# ($tstpath/go/src/threeenp1B1) where the default test framework assignment of ydb_gbldir
# to a relative path (i.e. mumps.gld) is no longer relevant.
setenv ydb_gbldir $tstpath/mumps.gld
if ($?test_replic) then
	# In case of replication tests, set replication instance env var too just like we did the gld above
	setenv ydb_repl_instance $tstpath/mumps.repl
endif
#
# Run threeenp1B1 with one range
#
`pwd`/threeenp1B1 << EOF
100000
100000
EOF
#
# Validate DB
#
cd ../../..
if ($?test_replic) then
	unsetenv ydb_repl_instance
endif
unsetenv ydb_gbldir
$gtm_tst/com/dbcheck.csh -extract
