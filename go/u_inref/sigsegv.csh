#################################################################
#								#
# Copyright (c) 2020-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# This test verifies a Go main can catch/recover from a SIGSEGV signal/panic once the YottaDB environment"
echo "# has been initialized. Prior to YDB r1.30 and Go wrapper v1.1.0, this was not possible."
#
# Set up the golang environment and sets up our repo
#
source $gtm_tst/com/setupgoenv.csh # Do our Go setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $go_repo)
set status1 = $status
if ($status1) then
	echo "[source $gtm_tst/com/setupgoenv.csh] failed with status [$status1]. Exiting..."
	exit 1
endif

cd go/src
mkdir sigsegv
cd sigsegv
ln -s $gtm_tst/$tst/inref/sigsegv.go .
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to soft link sigsegv.go to current directory ($PWD)"
    exit 1
endif
# Build our routine (must be built due to use of cgo).
echo "# Building sigsegv"
$gobuild >& go_build.log
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to build sigsegv.go. go_build.log output follows."
    cat go_build.log
    exit 1
endif
#
# Run it..
#
echo "# Running sigsegv"
`pwd`/sigsegv
# No DBs used so no final checks needed here
