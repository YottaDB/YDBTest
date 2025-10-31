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
echo "# Building threeenp1B1"
$gobuild $gtm_tst/$tst/inref/threeenp1B1.go >& go_build.log || \
	echo "TEST-E-FAILED : Unable to build threeenp1B1.go. go_build.log output follows." && cat go_build.log && exit 1
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
if ($?test_replic) then
	unsetenv ydb_repl_instance
endif
unsetenv ydb_gbldir
$gtm_tst/com/dbcheck.csh -extract
