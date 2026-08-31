###########################################################
#
# Copyright (c) 2024-2026 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
###########################################################

# source this to set environment so that gtmtest invokes a different database version

if ( "$1" == "-q" || "$1" == "--quiet" ) then   # don't display version afterward
	set quiet
	shift
endif

if ( "$1" == "" ) then
	echo "Current version: $verno ${ydb_dist:t}               (-h for help)"
	exit
endif

if ( "$1" == "-h" || "$1" == "--help" ) then
	echo 'Sets build/test environment variables to reference a database-binaries directory under $gtm_root'
	echo "Usage: ver [-q|--quiet] <verno> [<image>]"
	echo "  where <verno> is Vxxx_Rxyz (YDB) or Vxxxxx (GT.M)"
	echo "        <image> is dbg|pro|bta to select debug (default) or production images"
	echo "  if --quiet or -q is specified, don't display the version setting"
	exit 1
endif

set verno = $1
set verno = $verno:au
if ($verno == "A") then
	set verno = $gtm_verno
endif
set image = $2:al
if (($image == "p") || ($image == "pro")) then
	set image = "pro"
else if (($image == "b") || ($image == "bta")) then
	set image = "bta"
else
	set image = "dbg"
endif
setenv gtm_verno $verno
setenv gtm_ver $gtm_root/$verno
setenv ydb_dist $gtm_root/$verno/$image
setenv gtm_dist $ydb_dist
setenv gtmroutines ". $gtm_dist"
setenv gtm_tools $gtm_root/$verno/tools
setenv gtm_inc $gtm_root/$verno/inc
setenv gtm_src $gtm_root/$verno/src
setenv gtm_log $gtm_root/$verno/log
setenv gtm_exe $gtm_dist
setenv GTM "$gtm_exe/mumps -direct"   # not strictly needed as settest sets this, but makes many scripts run without settest
unsetenv gtm_exe_realpath; if ( -e $gtm_exe/mumps ) setenv gtm_exe_realpath `realpath $gtm_exe`
setenv gtm_obj $gtm_exe/obj
setenv tst_image $image

# Go-related switches
setenv PKG_CONFIG_PATH $ydb_dist
# Note: a "go clean -testcache -cache" used to run here to keep a Go build done against a previously
# tested YottaDB build from being reused against this one. It has been removed. "go clean -cache"
# empties the entire build cache, not just the entries this test run created, and the cache it emptied
# was the default "$HOME/.cache/go-build" shared by every test run on the system. Since "com/ver.csh"
# is sourced by dozens of subtests that have nothing to do with Go, any one of them could delete the
# cache out from under a "go build" or "go test" running in a concurrent test run, which then failed
# with "could not import xxx (open .../go-build/...: no such file or directory)". See YDBTest#1042.
# "com/setupgoenv.csh" now sets a GOCACHE private to each gtmtest run. That cache starts out empty, so
# it holds nothing built against a previous YottaDB build and there is nothing here left to clean.

if ( ! $?quiet ) echo '   $gtm_dist set to '$gtm_dist

#
# Define compiler flags and such with the build's own gtm_env.csh
# Note: gtm_env.csh overrides ver alias so save/restore it, and remove other aliases it defines
#
set __save_ver=`alias ver`
	if ! ( $?gtm_linux_compiler ) setenv gtm_linux_compiler gcc   # needed to run GTM's gtm_env.csh which doesn't set it properly
	if ( -e $gtm_tools/gtm_env.csh ) source $gtm_tools/gtm_env.csh
	unalias vers versi versio   # remove unnecessary aliases defined by gtm_env.csh
alias ver "$__save_ver"
unset __save_ver

if (! -e $gtm_root/$verno/$image) then
	if ( ! $?quiet ) then
		echo "VERSION-E-VERNOTEXIST : Directory $gtm_root/$verno/$image does not exist. Exiting..."
	endif
	exit -1
endif
