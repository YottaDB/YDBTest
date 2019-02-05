#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This test/demo drives the golang flavor of the 3n+1 routine
#
# Create database simpleapithreeenp1f needs:
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
source $gtm_tst/$tst/u_inref/setupgoenv.csh # Do our golang setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $go_repo)
if ($status) then
	echo "[source $gtm_tst/$tst/u_inref/setupgoenv.csh] failed with status [$status]. Exiting..."
	exit 1
endif

cd go/src
mkdir simpleapithreeenp1f
cd simpleapithreeenp1f
ln -s $gtm_tst/$tst/inref/simpleapithreeenp1f.go .
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to soft link simpleapithreeenp1f.go to current directory ($PWD)"
    exit 1
endif
# Build our routine (must be built due to use of cgo).
echo "# Building simpleapithreeenp1f"
go build
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to build simpleapithreeenp1f.go"
    exit 1
endif
#
# Run it with one range
#
# Note: We need to set the global directory to an absolute path because we are operating in a subdirectory
# ($tstpath/go/src/simpleapithreeenp1f) where the default test framework assignment of ydb_gbldir
# to a relative path (i.e. mumps.gld) is no longer relevant.
setenv ydb_gbldir $tstpath/mumps.gld
if ($?test_replic) then
	# In case of replication tests, set replication instance env var too just like we did the gld above
	setenv ydb_repl_instance $tstpath/mumps.repl
endif
#
# Run simpleapithreeenp1f with one range
#
`pwd`/simpleapithreeenp1f << EOF
150000
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
