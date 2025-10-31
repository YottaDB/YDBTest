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
# Test of simulated banking transactions using threaded tp calls
#

echo "# Test of simulated banking transactions using Go Simple API with 10 goroutines in ONE process"

$gtm_tst/com/dbcreate.csh mumps -gld_has_db_fullpath >>& dbcreate.out || \
	echo "# dbcreate failed. Output of dbcreate.out follows" && cat dbcreate.out
#
# Set up the golang environment and sets up our repo
#
# Do our golang setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $ydbgo_url, $goflags)
source $gtm_tst/com/setupgoenv.csh >& setupgoenv.out || \
	echo "[source $gtm_tst/com/setupgoenv.csh] failed with status [$status]:" && cat setupgoenv.out && exit 1

# class files
mkdir dataObject
ln -s $gtm_tst/$tst/inref/pseudoBank_*.go dataObject/ || \
	echo "TEST-E-FAILED : Unable to soft link class files to directoy ($PWD/dataObject)" && exit 1
cd dataObject
go mod init dataObject >& go_mod.out && $goget >>& go_mod.out || \
	echo "TEST-E-FAILED : Unable to run 'go mod init dataObject && $goget':" && cat go_mod.out && exit 1
cd ..

# init go work if not already initialized by setupgoenv.csh but ignore result as it may already exist
go work init >>& go_work.out
go work use dataObject >>& go_work.out || \
	echo "TEST-E-FAILED : Unable to setup go work:" && cat go_work.out && exit 1

# Build our routine (must be built due to use of cgo).
echo "# Building pseudoBank"
$gobuild $gtm_tst/$tst/inref/pseudoBank.go >& go_build.log || \
	echo "TEST-E-FAILED : Unable to build pseudoBank.go. go_build.log output follows." && cat go_build.log && exit 1
#
# Run pseudoBank
#
#
# Run pseudoBank with our standard input and save the output
#
echo "# Running pseudoBank"
`pwd`/pseudoBank

#
# Validate DB
#
cp $gtm_tst/com/pseudoBankDisp.m .
$gtm_dist/mumps -r pseudoBankDisp
unsetenv ydb_gbldir
$gtm_tst/com/dbcheck.csh
