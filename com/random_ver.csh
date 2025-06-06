#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2025 YottaDB LLC and/or its subsidiaries.	#
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
#	"V4"         - pickup a random V4 version
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
	echo "\$gtm_tst/com/random_ver.csh -type V4"
	echo "\$gtm_tst/com/random_ver.csh -gte V44002 -lt V51000"
	echo "\$gtm_tst/com/random_ver.csh -gte V53003"
	echo "\$gtm_tst/com/random_ver.csh -gte V44002 -lt V51000 -ck true"
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
	set vers = `ssh -x $host "\ls $gtm_root/" | $grep -E '^V[4-8][0-9][0-9][0-9][0-9][A-Z]?(_R[1-9][0-9][02468])?$'`
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
	if ("" != $checkonly) then
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
	#This is added specifically for IA64 and s390(zOS) as we dont have V44004 there
	if ($?gtm_platform_no_V4) then
		if ("HOST_OS390_S390" == $gtm_test_os_machtype) then
			setenv oldver V53004A
		else
			setenv oldver V53000
		endif
	else
		setenv oldver V44004
	endif
	switch ($vertype)
	case "V4":
		set minimum = "V44002" # V44002 is the min supported version after triggers
		set isgt    = ">="
		set maximum = "V50000" # V50000 is the first V5 version. So anything before that
		set islt    = "<"
	breaksw
	case "V5":
		set minimum = "V50000"
		set isgt    = ">="
		set maximum = "V60000"
		set islt    = "<"
	breaksw
	case "V6":
		set minimum = "V60000"
		set isgt    = ">="
		set maximum = "V70000"
		set islt    = "<"
	breaksw
	case "ms":
		set minimum = "V60000"	# Starting r1.24, GT.M V6.0-000 is the earliest supported version for replication
		set isgt    = ">="
		set maximum = "$tst_ver" # A version before the current version
		set islt    = "<"
	breaksw
	case "any":
		set minimum = "V44002" # V44002 is the min supported version after triggers
		set isgt    = ">="
		set maximum = "$tst_ver" # A version before the current version
		set islt    = "<"
	breaksw
	case "shlib_mismatch":
		# First 64 bit supported versions on these platforms which will work with the current versions
		if ("HOST_LINUX_X86_64" == $gtm_test_os_machtype || "HOST_AIX_RS6000" == $gtm_test_os_machtype) then
			if (! $?ydb_environment_init) then
				set minimum = "V53001"
			else
				# The oldest version we have in a YottaDB environment is V54001. But V54001 and V54002B pro
				# fail with SIG-11 only on Ubuntu 17.04 when running a shared library created from M routines
				# (suspect is a regression in the Ubuntu 17.04 patch but not sure). Therefore set V62000
				# (the next available version) as the minimum 64-bit build as that works fine across all flavors.
				set minimum = "V62000"
			endif
		else if ("HOST_SUNOS_SPARC" == $gtm_test_os_machtype) then
			set minimum = "V53002"
		else if ("HOST_OS390_S390" == $gtm_test_os_machtype) then
			set minimum = "V54002"
		else
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
		# DB minor versions tracked only since V50000
		set minimum = "V50000"
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
	# The minimum version is not specified. Hence take the oldest supported version as the minimum (taken from type -any)
	set minimum = "V44002" # V44002 is the min supported version after triggers
	set isgt    = ">="
endif

# If access_method is MM, the minimum version supported is V53002
if ( ( "MM" == "$acc_meth") && (`expr $minimum "<" "V53002"`) ) then
	# Set the minimum without even checking the maximum which might result in no versions for say -type V4.
	# In that case the script will exit with "RANDOMVER-E-CANNOTRUN". The test calling random_ver.csh has to take care of it
	set minimum = "V53002"
endif

# Check if current chset is UTF-8. If so, we need to filter OUT prior versions that are < V53002 as they expect
# the ICU libraries (e.g. libicuio.so) to be soft linked to the 3.6 version (libicuio36.0.so) and that
# it was built with version specific symbol renaming. V53002 to < V53004, the builds work in UTF8 mode as long
# as libicuio36.0.so is available even though libicuio.so does not point to it. From V53004 onwards, libicuio.so
# is examined and whatever ICU version version it points to is used unconditionally. Also it expects the ICU
# to have been built WITHOUT symbol renaming. Therefore GT.M versions < V53002 which also support unicode
# (i.e. >= V52000) will NOT work in a UTF8 environment where V53004 and above work. Also, ICU 4.4 and later use a
# different symbol renaming scheme, with support for it introduced in V54002 (older versions don't support ICU 4.4
# and later built with symbol renaming).
#
# CHSET  Versions                  Symbol Renamed  ICU Version     Symlink Required        gtm_icu_version
# M      all                       Don't need Unicode, use all versions
# UTF-8            $VER <  V52000  Don't support Unicode
#        V52000 <= $VER <  V53002  YES             3.6             to 3.6                  NO              requires custom 3.6 ICU as default
#        V53002 <= $VER <  V53004  YES             3.6             NO                      NO
#        V53004 <= $VER <  V54002  ANY             3.6 - 4.2       Any version             YES             limited by icu_new_naming_scheme
#                                                                                                          Using AIX 7's default ICU is limited
#                                                                                                          to V54001+ due to thread lib conflict
#        V54002 <= $VER            ANY             3.6 - 4.4+      Any version             YES

set isutf8 = 0
set icu_new_naming_scheme = 0
set libicu36 = 0
if ($?gtm_chset) then
	if ("UTF-8" == $gtm_chset) then
		# UTF-8 mode
		set isutf8 = 1

		# using new naming scheme?
		$gtm_tst/com/is_icu_new_naming_scheme.csh
		if (0 == $status) set icu_new_naming_scheme = 1

		# test for ICU 3.6
		ls {/usr,,}{/local,,}/lib{32,64,,}/libicuio*36* >& /dev/null
		if ( 0 == $status) set libicu36 = 1

		# NOTE: ICU 3.6 must be installed with symbols renamed. This is the test
		# ( set setactive_parms=(V53003 p); setenv gtm_ver_noecho 1 ; \
		#   source $gtm_tools/setactive.csh ; printf 'write $zversion\nhalt\n' \
		#   | env LC_CTYPE=en_US.utf8 LC_ALL= gtm_chset=UTF-8 $gtm_dist/mumps -direct )
	endif
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
	if ("" != $checkonly) then
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

# To be compatible with the current usage, setenv v4ver and dsver is done
if ($?vertype) then
	# This script is called to pickup an old version and follow it up with switching it to it and execute some portion of test
	# priorver.txt mechanism ensures those randomly picked versions in the reference file gets filtered.
	# This file can be created by the individual tests. But it will also not harm if we create it here,
	# right at the point where we pick up a version.
	echo $prior_ver >& priorver.txt
endif
# The below echo command returns the version name and should be used by the caller.
echo $prior_ver

