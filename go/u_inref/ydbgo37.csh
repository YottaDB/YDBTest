#################################################################
#								#
# Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Simplistic test to initialize YottaDB, then shutdown the YDB engine timing how long it takes to do so. If
# the duration is longer than 5 seconds then we are hanging up on shutdown (5 second timer in shutdownSignalRoutines()
# in init.go can hang for up to 5 seconds waiting for goroutines to shutdown.
#
# Set up the golang environment and sets up our repo
#
echo "# Setting up go environment"
source $gtm_tst/com/setupgoenv.csh # Do our golang setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $go_repo)
set status1 = $status
if ($status1) then
	echo "[source $gtm_tst/$tst/u_inref/setupgoenv.csh] failed with status [$status1]. Exiting..."
	exit 1
endif

cd go/src
mkdir ydbgo37
cd ydbgo37
ln -s $gtm_tst/$tst/inref/ydbgo37.go .
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to soft link ydbgo37.go to current directory ($PWD)"
    exit 1
endif
# Build our routine (must be built due to use of cgo).
echo "# Building ydbgo37"
$gobuild >& go_build.log
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to build ydbgo37.go. go_build.log output follows"
    cat go_build.log
    exit 1
endif
$echoline
echo "# Driving ydbgo37"
`pwd`/ydbgo37
$echoline
