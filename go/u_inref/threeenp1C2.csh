#################################################################
#								#
# Copyright (c) 2019-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This test/demo drives a golang flavor of the 3n+1 routine that operates similarly to threeenp1B2 but uses separate processes
# instead of goroutines as workers. Because both the workers and the main run the same program, it uses special arguments
# internally to tell the difference between the invocations.
#
# Create database threeenp1C2 needs:
#
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
#
# Set up the golang environment and sets up our repo
#
# Do our golang setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $ydbgo_url, $goflags)
source $gtm_tst/com/setupgoenv.csh >& setupgoenv.out || \
	echo "[source $gtm_tst/com/setupgoenv.csh] failed with status [$status]:" && cat setupgoenv.out && exit 1

# Build our routine (must be built due to use of cgo).
echo "# Building threeenp1C2"
$gobuild $gtm_tst/$tst/inref/threeenp1C2.go >& go_build.log || \
	echo "TEST-E-FAILED : Unable to build threeenp1C2.go. go_build.log output follows." && cat go_build.log && exit 1
#
# Run threeenp1C2 with one range
#
`pwd`/threeenp1C2 << EOF
100000
100000
EOF
#
# Validate DB
#
if ($?test_replic) then
	unsetenv ydb_repl_instance
endif
unsetenv ydb_gbldir
$gtm_tst/com/dbcheck.csh -extract
