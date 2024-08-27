#################################################################
#								#
# Copyright (c) 2019-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This script is meant to be source'd by golang tests to both setup the golang environment and
# fetch the yottadb package into it before building/running the specific golang test.
#
set tstpath = `pwd`
setenv PKG_CONFIG_PATH $ydb_dist
setenv GOPATH $tstpath/go/
setenv GOPROXY https://proxy.golang.org/cached-only
setenv GO111MODULE on	# Need this for "go get" to work. Starting "go 1.22", go get fails to work if GO111MODULE=off
set go_repo="lang.yottadb.com/go/yottadb"
mkdir go

# Now that "go get" is only supported inside of a module, create a go.mod file first.
# This step was not needed until "go 1.21" as long as "GO111MODULE" env var was set to "off".
# But starting "go 1.22", that did not work (see YDBTest#387 for more details).
go mod init gitlab.com/YottaDB/Lang/YDBGo >& go_mod.out

# Retrieve yottadb package from the repository using "go get".
set cmdtorunprefix = "go get"
set cmdtorunsuffix = "-d -v -x -t $go_repo"
set cmdtorun = "$cmdtorunprefix $cmdtorunsuffix"
echo "# Running : $cmdtorun"
# Occasionally we have seen "TLS handshake timeout" or "i/o timeout" failures on slow boxes if the "go get" takes
# approximately more than 15 seconds to finish (which can happen on the slow ARMV6L boxes or over less than ideal
# internet connections). That timeout does not seem to be user configurable either so we handle that by retrying
# the "go get" for a few times before signaling failure.
set retry = 0
set maxretry = 5
while ($retry < $maxretry)
	$cmdtorun |& $tst_awk '{print strftime("%T"),":",$0}' >& go_get.log
	set status1 = $status
	mv go_get.log go_get_$retry.log
	if (! $status1) then
		# "go get" succeeded. Break out of retry loop.
		break
	endif
	$grep -q -e "net/http: TLS handshake timeout" go_get_$retry.log
	if (! $status) then
		# It was a TLS handshake timeout error. Try with "-insecure" to see if that helps.
		# This has been seen to really make a difference at least on 1-CPU systems that are otherwise loaded.
		set cmdtorun = "$cmdtorunprefix -insecure $cmdtorunsuffix"
	else
		# It was some other error (e.g. "i/o timeout" or "The requested URL returned error: 500")
		# We retry on all types of errors.
		set cmdtorun = "$cmdtorunprefix $cmdtorunsuffix"
	endif
	@ retry = $retry + 1
end
if ($status1) then
	echo "TEST-E-FAILED : [$cmdtorun] returned failure status of $status1. Total of $retry retries. Output in go_get*.log"
	foreach file (go_get*.log)
		echo " --> Output of $file"
		cat $file
	end
	exit 1
endif

# go/pkg directory contains subdirectories with read-only permissions after a "go get" so give read-write permissions
# as later the test framework would try to gzip the files in case of a test failure and that would require creating a
# new file and fail with a "Permission denied" error.
chmod -R +w go/pkg

# go get with GO111MODULE=on no longer downloads the git repository. But later parts of this script and the caller test
# rely on that directory existing. So download the git repo using "git clone".
mkdir -p go/src/lang.yottadb.com/go/yottadb/
git clone https://gitlab.com/YottaDB/Lang/YDBGo go/src/lang.yottadb.com/go/yottadb >& gitclone.log

cd go/src/$go_repo
if ($?ydb_test_go_repo_dir) then
	# If env var "ydb_test_go_repo_dir" is defined, use this as the path of the go repo instead of the go repo on gitlab.
	git remote add tmp $ydb_test_go_repo_dir
	set status1 = $status
	if ($status1) then
		echo "TEST-E-FAILED : [git remote add tmp $ydb_test_go_repo_dir] returned failure status of $status1"
		exit 1
	endif
	git fetch tmp >& git_fetch.log
	set status1 = $status
	if ($status1) then
		echo "TEST-E-FAILED : [git fetch tmp] returned failure status of $status1. Output below and in git_fetch.log"
		cat git_fetch.log
		exit 1
	endif
	if ($?ydb_test_go_repo_branch) then
		# If env var "ydb_test_go_repo_branch" is defined, use that as the branch
		git checkout -b tmp tmp/$ydb_test_go_repo_branch >& git_checkout.log
		set status1 = $status
		if ($status1) then
			echo "TEST-E-FAILED : [git checkout -b tmp tmp/$ydb_test_go_repo_branch] returned failure status of $status1. Output below and in git_checkout.log"
			cat git_checkout.log
			exit 1
		endif
	else
		# Else use "develop" branch as the default ("master" branch is latest released code, not latest developed code)
		git checkout -b tmp tmp/develop >& git_checkout.log
		set status1 = $status
		if ($status1) then
			echo "TEST-E-FAILED : [git checkout -b tmp tmp/develop] returned failure status of $status1. Output below and in git_checkout.log"
			cat git_checkout.log
			exit 1
		endif
	endif
else
	# We used the go repo on gitlab. By default, "go get" would checkout the "master" branch.
	# But we want to checkout the "develop" branch.
	git checkout develop >& git_checkout.log
	set status1 = $status
	if ($status1) then
		echo "TEST-E-FAILED : [git checkout develop] returned failure status of $status1. Output below and in git_checkout.log"
		cat git_checkout.log
		exit 1
	endif
endif
cd -

# When using a pure Go application, one can do 'go run xxx.go' and it will do that. This does not work when cgo is involved -
# which is 100% of our Go applications currently since they all test the Go wrapper.
set gobuild = "go build"
setenv GO111MODULE off	# Keep this off as we rely on this for "go build" commands to work with GOPATH programs in YDBTest
			# like com/imptpgo.go and com/impjobgo.go. Note that starting go 1.22, "go get" runs as if
			# GO111MODULE=on irrespective of the env var setting but we handle that separately later.
set gotest = "go test"

# If ASAN enabled and Go version < 1.18, using go build flag `-fsanitize=address`
# But if ASAN enabled and Go version >= 1.18, using `-asan` flag instead
source $gtm_tst/com/is_libyottadb_asan_enabled.csh
if ($gtm_test_libyottadb_asan_enabled) then
	# libyottadb.so was built with asan enabled. Do the same with the go executables.
	if ($ydb_test_gover_lt_118) then
		set asanflags = "'-fsanitize=address'"
	else
		set asanflags = "-asan"
	endif
	set gobuild = "$gobuild $asanflags"
	set gotest = "$gotest $asanflags"
endif

# Random Go environment settings
# ydb_go_race_detector - determines if the go -race flag should be used
# GOGC - The rate Go does garbage collection; a smaller value increases frequency; default is 100
if (! $?gtm_test_replay) then
	echo "# Go environment variables" >> settings.csh
	setenv ydb_go_race_detector_on `$gtm_tst/com/genrandnumbers.csh 1 0 1`
	if (("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype) || ("HOST_LINUX_AARCH64" == $gtm_test_os_machtype)) then
		# -race is not supported in "go" on the ARM platform. So disable the random choice there.
		setenv ydb_go_race_detector_on 0
	endif
	if ($gtm_test_libyottadb_asan_enabled) then
		echo "# Go race detector is disabled because address sanitizer is enabled in libyottadb.so" >> settings.csh
		echo "# See https://groups.google.com/g/golang-nuts/c/OF2-5hVRouA/m/iwDx7GtGBwAJ for details." >> settings.csh
		setenv ydb_go_race_detector_on 0
	endif
	echo "setenv ydb_go_race_detector_on $ydb_go_race_detector_on" >> settings.csh
	# GOGC is either 1 or the default (100)
	if(1 == `$gtm_tst/com/genrandnumbers.csh 1 0 1`) then
		setenv GOGC 1
		echo "setenv GOGC $GOGC" >> settings.csh
	endif
endif

if ($ydb_go_race_detector_on) then
	# Randomly enable go race detector
	set gobuild = "$gobuild -race"
	set gotest = "$gotest -race"
endif
# Capture random setting in file for later analysis in case of test failures
set | $grep ^go >& govars.txt
exit 0
