#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Find all ICU libraries installed on this machine
set nonomatch = 1
set libraries = ({,/usr,/usr/local}/lib{,32,64}{,/*linux-gnu*}/libicuio*)
set libvers   = ()

foreach lib ( $libraries )
	if ( -l $lib ) continue
	if ( ! -f $lib ) continue
	set ver = ${lib:t:s/libicuio//:s/.so.//:s/.sl.//:s/.so//:s/.a//}
	set -f libvers = ($libvers ${ver})
	set libdir${ver:as/./_/} = "${lib:h}"
end

# Switch to UTF-8 mode
$switch_chset UTF-8 >& switch_chset.out

# For each found library, use the library's version number for gtm_icu_version. Note that these numbers are always
# <major><minor> as opposed to pkg-config's responses which varied over time. The test system always provides the
# old style gtm_icu_version
foreach ver ( $libvers )
	$echoline											>>& gtm6858.outx
	echo "${ver} gtm_icu_version" 									>>& gtm6858.outx
	eval 'set libdir = "${libdir'${ver:as/./_/}'}"'
	env gtm_icu_version="$ver" LIBPATH=$libdir $gtm_dist/mumps -run %XCMD 'zwr $zchset zhalt 0'	>>& gtm6858.outx
	set savestat = $status
	if ($savestat && `expr $ver \> 35` ) set fail=1
end

if ($?fail) then
	cat gtm6858.outx
else
	echo PASS
endif
# Some machines (pfloyd for instance) have older unsupported ICU versions. Ignore the error
$grep -v ICUVERLT36 gtm6858.outx > gtm6858.out

