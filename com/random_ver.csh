#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# the script picks a random version to test from a list of available set of versions.
# The script is called with one or more arguments that will say which list of versions to be picked up.
# The -type qualifier, if specified, can be followed by one of the following choices
#	"ms"         - pick up any of the available prior multisite versions that are supported with the current version
#	"any"        - pick up any of all available prior versions
# If -ck (checkonly) is specified, exit with 0 status even if version is not available
#
# To force the prior version to always be one version at test start-up, either doall.csh or
# gtmtest.csh, add -env gtm_force_prior_ver=VERSION to the command.
#

if ( 0 == $#argv ) then
	echo "Usage: \$gtm_tst/com/random_ver.csh [-gt|-gte] <version> ||  [-lt|-lte] <version> || -type <version> [ -ck true] "
	echo "Sample usage:"
	echo "\$gtm_tst/com/random_ver.csh -type V6"
	echo "\$gtm_tst/com/random_ver.csh -gte V62000 -lt V63014"
	echo "\$gtm_tst/com/random_ver.csh -gte V63014"
	echo "\$gtm_tst/com/random_ver.csh -gte V62000 -lt V63014 -ck true"
	exit 1
endif

setenv test_no_ipv6_ver	1
if !($?gtm_tst) then
	setenv gtm_tst $gtm_test/T990
	source $gtm_tst/com/set_specific.csh
endif

if ($?gtm_force_prior_ver) then
	echo $gtm_force_prior_ver >& priorver.txt
	cat priorver.txt
	exit 0
endif

set opt_array      = ("\-gt"  "\-lt"  "\-gte"  "\-lte"  "\-type"  "\-rh" "\-ck")
set opt_name_array = ("vergt" "verlt" "vergte" "verlte" "vertype" "remotehosts" "checkonly")
source $gtm_tst/com/getargs.csh $argv
if !($?checkonly) then
	set checkonly = 0
endif

# First list out all versions available in the server. Skip V3 and V9 versions
# A production version is identified as having a GT.M version # followed by an optional YottaDB release #
# i.e. V63001A, V63002_R110 etc. Also note that a production YottaDB release always has an even number at the end
# hence the "[02468]" usage below.
set localallverlist = `\ls $gtm_root/ | $grep -E '^V[4-8][0-9][0-9][0-9][0-9][A-Z]?(_R[1-9][0-9][02468])?$'`
set allverlist = ""
foreach ver ($localallverlist)
	# Even though the version directory exists, it is possible the specific image subdirectory
	# does not exist. e.g. Builds before V63000 on non-gg boxes only have pro builds setup,
	# not the dbg builds. In that case, skip this version from the list of available versions.
	if (-e $gtm_root/$ver/$tst_image) then
		set allverlist = "$allverlist $ver"
	endif
end

if (! $?remotehosts) set remotehosts = ""
foreach host ($remotehosts)
	set vers = `$ssh $host "\ls $gtm_root/" | $grep -E '^V[4-8][0-9][0-9][0-9][0-9][A-Z]?(_R[1-9][0-9][02468])?$'`
	set newlist = ""
	foreach ver ($vers)
		if ( "$allverlist " =~ "*$ver *") then
			set newlist = "$newlist $ver"
		endif
	end
	set allverlist = "$newlist"
end

set allverlist = `echo $allverlist`
@ numvers = $#allverlist
@ cnt = 1
set actualverlist = ""
# Ensure actualverlist never contains any version > gtm_verno
# In case "$gtm_curpro" env var is defined, ensure actualverlist never contains any version > that.
if ($?gtm_curpro) then
	set maxver = "$gtm_curpro"
else
	set maxver = "$gtm_verno"
endif
while ($cnt <= $numvers)
	if (`expr "$allverlist[$cnt]" "<=" "$maxver"`) then
		set actualverlist = `echo $actualverlist $allverlist[$cnt]`
	endif
	@ cnt = $cnt + 1
end
@ numvers = $#actualverlist
if (0 == $numvers) then
	if (0 != $checkonly) then
		echo "RANDOMVER-E-CANNOTRUN"
	else
		echo "RANDOMVER-E-CANNOTRUN : Could not determine previous versions. Check random_ver_err.txt"
		echo "localallverlist : $localallverlist"	>> random_ver_err.txt
		echo "remotehosts  : $remotehosts"		>> random_ver_err.txt
		echo "allverslist : $allverlist"		>> random_ver_err.txt
		exit -1
	endif
endif

# Check for the upper and lower end of the versions required
if ($?vergt) then
	set minimum = $vergt
	set isgt    = ">"
endif
if ($?vergte) then
	set minimum = $vergte
	set isgt    = ">="
endif
if ($?verlt) then
	set maximum = $verlt
	set islt    = "<"
endif
if ($?verlte) then
	set maximum = $verlte
	set islt    = "<="
endif

if ($?vertype) then
	# The oldest version we have in a YottaDB environment is V62000. Use this as default minimum old version.
	set oldver = "V62000"  # V62000 is the earliest version to test against
	switch ($vertype)
	case "V6":
		set minimum = $oldver
		set isgt    = ">="
		set maximum = "V70000"
		set islt    = "<"
	breaksw
	case "V7":
		set minimum = "V70000"
		set isgt    = ">="
		set maximum = "V80000"  # A version above the most recently merged upstream GT.M version
		if (`expr $tst_ver "<" $maximum`) then
			set maximum = $tst_ver  # A version before the current version
		endif
		set islt    = "<"
	breaksw
	case "ms":
	case "any":
		set minimum = $oldver # V62000 is the earliest multisite version to test against
		set isgt    = ">="
		set maximum = "$tst_ver" # A version before the current version
		set islt    = "<"
	breaksw
	case "shlib_mismatch":
		# First 64 bit supported versions on these platforms which will work with the current versions
		if ("HOST_LINUX_X86_64" == $gtm_test_os_machtype) then
			# The oldest version we have in a YottaDB environment is V62000. Therefore set V62000 (i.e. $oldver)
			# as the minimum 64-bit build as that works fine across all flavors.
			set minimum = "$oldver"
		endif
		set isgt    = ">="
		source $gtm_tst/com/get_max_ver_dynamically.csh "shlib_mismatch"
		set islt    = "<="
	breaksw
	case "gld_mismatch":
		set minimum = "$oldver"
		set isgt    = ">="
		source $gtm_tst/com/get_max_ver_dynamically.csh "gld_mismatch"
		set islt    = "<="
	breaksw
	case "obj_mismatch":
		set minimum = "$oldver"
		set isgt    = ">="
		source $gtm_tst/com/get_max_ver_dynamically.csh "obj_mismatch"
		set islt    = "<="
	breaksw
	case "dbminver_mismatch":
		set minimum = "$oldver"
		set isgt    = ">="
		source $gtm_tst/com/get_max_ver_dynamically.csh "dbminver_mismatch"
		set islt    = "<="
	breaksw
	endsw
endif

# On non-gg boxes, V63000 is minimum version that has dbg builds. Account for that below.
if ("dbg" == $tst_image) then
	if (! $?minimum) then
		set minimum = "V63000"
	else
		if (`expr $minimum "<" "V63000"`) then
			set minimum = "V63000"
		endif
	endif
endif

if !($?islt) then
	# The maximum version is not specified. Hence take the test version as the maximum (excuding it)
	set maximum = "$tst_ver" # A version before the current version
	set islt    = "<"
endif

if !($?isgt) then
	# The minimum version is not specified. Hence take the oldest tested version as the minimum (taken from type -any)
	set minimum = "V62000" # V62000 is the min tested version
	set isgt    = ">="
endif

# filter out versions based on the minimum and maximum

set filteredlist = ""
foreach ver ($actualverlist)
	if ((`expr $ver $isgt $minimum`) && (`expr $ver $islt $maximum`)) then
		set filteredlist = ($filteredlist $ver)
	endif
end

# Disable gtmcompile, including the -dynamic_literals qualifer, since prior versions complain. See comment in switch_gtm_version.csh
unsetenv gtmcompile

set filteredcount = $#filteredlist
if ("" == "$filteredlist") then
	if (0 != $checkonly) then
		echo "RANDOMVER-E-CANNOTRUN"
	else
		echo "RANDOMVER-E-CANNOTRUN : Could not determine previous version matching the given criteria - ${argv}. Exiting..."
		exit -1
	endif
endif
set randno = `$gtm_exe/mumps -run rand $filteredcount`
# The list starts from 1 to $numvers, the random number generated is 0 to $numvers-1
@ randno = $randno + 1
set prior_ver = $filteredlist[$randno]

if ($?vertype) then
	# This script is called to pickup an old version and follow it up with switching it to it and execute some portion of test
	# priorver.txt mechanism ensures those randomly picked versions in the reference file gets filtered.
	# This file can be created by the individual tests. But it will also not harm if we create it here,
	# right at the point where we pick up a version.
	echo $prior_ver >& priorver.txt
endif
# The below echo command returns the version name and should be used by the caller.
echo $prior_ver

