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
# This script is meant to be source'd by golang tests to both setup the golang environment and
# fetch the yottadb package into it before building/running the specific golang test.
# However, set the following defaults so that the user can run it from the shell for testing purposes
if ! $?test_encryption setenv test_encryption "NON_ENCRYPT"
if ! $?test_awk setenv tst_awk awk
if ! $?grep setenv grep grep
if ! $?gtm_test_os_machtype source set_gtm_machtype.csh

set tstpath = `pwd`
setenv PKG_CONFIG_PATH $ydb_dist
# set a GOPATH outside current directory to avoid it being subsequently zipped. This prevents permission
# errors when zipping test results since GOPATH contains subdirectories with read-only permissions.
# This particular path makes it common to all subtests run this instance of gtmtest: avoids multiple downloads per gtmtest run.
if (-e $tst_dir/$gtm_tst_out) then
	# The above directory exists. That means this is a single host test run. Use that directory for GOPATH
	setenv GOPATH $tst_dir/$gtm_tst_out/gopath
else
	# The above directory does not exist. Possible in case this is a multi host test run where the current directory
	# is on a remote host ("$tst_dir" only exists on the originating host, not the current/remote host).
	# In that case, go up the parent levels until we find the file "primary_dir". That is the top level remote
	# host directory. Use that for GOPATH.
	# See https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2480#note_3024710451 for more details.
	set curdir = $PWD
	while (1)
		if (-e primary_dir) then
			break
		endif
		cd ..
		if ("/" == $PWD) then
			echo "[SETUPGOENV-E-GOPATH : $curdir does not have primary_dir in parent levels" && exit 1
		endif
	end
	setenv GOPATH $PWD/gopath
	cd $curdir
endif
# Ensure go toolchains are not downloaded by the test as this creates huge artifacts
# in GOPATH (up to gigabytes) every time imptp.csh is run.
# Ensure the machine has a Go version at least as recent as required in go.mod and by YDBGo's go.mod files.
setenv GOTOOLCHAIN local

# Set cannonical url of YDBGo when properly referenced by 'go get'
set ydbgo_url="lang.yottadb.com/go/yottadb"

# Now that "go get" is only supported inside of a module, create a go.mod file first.
# This step was not needed until "go 1.21" as long as "GO111MODULE" env var was set to "off".
# But starting "go 1.22", that did not work (see YDBTest#387 for more details).
cp $gtm_tst/com/go.{mod,sum} . >& go_mod.out || \
	echo "[cp $gtm_tst/com/go.{mod,sum} .] failed with status [$status]:" && cat go_mod.out && exit 1

# If $ydbgo_repo points to a URL, check out YDBGo from a git repo instead of using 'go get'.
# If $ydbgo_repo points to a local filesystem git repo, use that, including any uncommitted changes.
# If testing with docker, you can mount your local YDBGo repo as a docker volume and point to that.
# The first half of the if statement would work by itself, but the second 'go get' version to test what users will mostly do.
if ( $?ydbgo_repo ) then
	# If it's a pathname, convert it to file:// URL format
	set ydbgo_repo_path = "$ydbgo_repo"
	if ( "$ydbgo_repo" !~ "*://*" ) setenv ydbgo_repo "file://$ydbgo_repo"
	echo "# Cloning $ydbgo_repo to $tstpath/YDBGo"
	# clone -depth 1 gets only the latest version for testing (faster)
	rm $tstpath/YDBGo go.work -rf # remove first in case setupgoenv.csh gets run twice
	git clone -q --depth 1 $ydbgo_repo $tstpath/YDBGo >>& ydbgo_clone.out || \
		echo "[git clone --depth 1 $ydbgo_repo:q] failed with status [$status]:" && cat ydbgo_clone.out && exit 1
	# If it's a local file repository diff + apply includes any uncommitted working files from the local YDBGo
	if ( "$ydbgo_repo" =~ "file://*" ) git -C "$ydbgo_repo_path" diff | git -C $tstpath/YDBGo apply --allow-empty -
	# include '.' below for several tests that assume it's included
	go work init . $tstpath/YDBGo $tstpath/YDBGo/v2 |& tee go_work.out
	set goget = "true" # needn't download ydbgo since it's found via ../go.work (e.g. in pseudoBank.csh)
else
	# Retrieve yottadb package from the repository using "go get".
	set goget = "go get -x -t $ydbgo_url $ydbgo_url/v2"
	echo "# Running : $goget"
	# Occasionally we have seen "TLS handshake timeout" or "i/o timeout" failures on slow boxes if the "go get" takes
	# approximately more than 15 seconds to finish (which can happen on the slow ARMV6L boxes or over less than ideal
	# internet connections). That timeout does not seem to be user configurable either so we handle that by retrying
	# the "go get" for a few times before signaling failure.
	set retry = 0
	set maxretry = 5
	while ($retry < $maxretry)
		$goget |& $tst_awk '{print strftime("%T"),":",$0}' >& go_get.log
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
			setenv GOINSECURE $ydbgo_url
		endif
		@ retry = $retry + 1
	end
	if ($status1) then
		echo "TEST-E-FAILED : [$goget] returned failure status of $status1. Total of $retry retries. Output in go_get*.log"
		foreach file (go_get*.log)
			echo " --> Output of $file"
			cat $file
		end
		exit 1
	endif
endif

if ("ENCRYPT" == "$test_encryption" ) then
	# Set env var to absolute path (not relative path) since go processes will start from subdirectories
	setenv gtmcrypt_config `pwd`/gtmcrypt.cfg
endif

# Historically, `go run xxx.go` did not work with CGo, so we use go build
# -buildvcs=false prevents Go from trying to contact the git repository to get version information
set goflags = "-buildvcs=false"

# If ASAN enabled and Go version < 1.18, using go build flag `-fsanitize=address`
# But if ASAN enabled and Go version >= 1.18, using `-asan` flag instead
source $gtm_tst/com/is_libyottadb_asan_enabled.csh
if ($gtm_test_libyottadb_asan_enabled) then
	# libyottadb.so was built with asan enabled. Do the same with the go executables.
	set asanflags = "-asan"
	set goflags = "$goflags -asan"

	# ------------------------------------------------------------------------------------
	# The following comment and code is similar to that in sudo/u_inref/setinstalloptions.csh
	# ------------------------------------------------------------------------------------
	# If libyottadb.so has been built with CLANG + ASAN, we started seeing link time errors like the following
	# from a "go build" when run on a SUSE SLED SP7 system or a RHEL 9 system.
	#	undefined reference to `__sanitizer_internal_memcpy'
	# To avoid such errors, we set the compiler for the go build to be "clang" instead of the default "gcc".
	if ("clang" == $gtm_test_asan_compiler) then
		setenv CC "clang"
	endif
endif

# Random Go environment settings
# ydb_go_race_detector - determines if the go -race flag should be used
# GOGC is the rate at which Go does garbage collection; a smaller value increases frequency; default is 100
if (! $?gtm_test_replay || ! $?ydb_go_race_detector_on) then
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

# Randomly enable go race detector
if ($ydb_go_race_detector_on) set goflags = "$goflags -race"

# These may be useful but if user needs to use Go "-C" flag they will need to use $goflags directly since -C must be first flag
set gobuild = "go build $goflags"
set gotest = "go test $goflags"

# Capture random setting in file for later analysis in case of test failures
set | $grep ^go >& govars.txt
# prevent exit code of grep above from being the exit code of this script
exit 0
