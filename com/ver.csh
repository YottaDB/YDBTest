###########################################################
#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
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
if (! -e $gtm_root/$verno/$image) then
	echo "VERSION-E-VERNOTEXIST : Directory $gtm_root/$verno/$image does not exist. Exiting..."
	exit -1
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

# Go-related switches
setenv PKG_CONFIG_PATH $ydb_dist
if (`which go` != "" && ! $?skip_go_clean) then
	go clean -testcache -cache >& /dev/null
endif

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
