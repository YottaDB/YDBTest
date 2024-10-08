#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Script to switch version
if ( "$1" == "" ) then
	echo "Current version: $verno ${gtm_dist:t}"
	echo 'Sets build/test environment variables to reference a database-binaries directory under $gtm_root'
	echo "Usage: ver <verno> [<image>]"
	echo "  where <verno> is Vxxx_Rxyz (YDB) or Vxxxxx (GT.M)"
	echo "        <image> is dbg|pro|bta to select debug (default) or production images"
	echo "Available versions: "
	foreach verdir (`ls -1d /usr/library/V*`)
		set ver = $verdir:t
		foreach dbgpro ("dbg" "pro")
			if ( -e /usr/library/$ver/$dbgpro ) printf "\t%-13s%-3s\n" $ver	$dbgpro
		end
	end
	exit
endif

set __save_ver=`alias ver`
source $gtm_tst/com/set_active_version.csh $1 $2

# set_active_version is (maybe) buggy. It keeps gtmroutines from previous version: bad... can cause lots of problems.
setenv gtmroutines ". $gtm_dist"

if ( -f $gtm_tools/gtm_env.csh ) then
	setenv HOSTOS `uname -s`
	source $gtm_tools/gtm_env.csh
	unalias vers versi versio version
endif
alias ver "$__save_ver"
unset __save_ver

echo "        \$gtm_dist set to $gtm_dist"
