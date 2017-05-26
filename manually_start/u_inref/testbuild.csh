#################################################################
#								#
# Copyright (c) 2011-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#!/usr/local/bin/tcsh -f
# Do simple execution tests of the built GT.M. It does not make sense to run
# the gamut of features because that is what the weekly test cylce does.

set bld=$1
set mode=$2
set dir=${bld}
set rtndir=${bld}
if ("utf8" == $mode) then
	set bld=utf${bld}
	$switch_chset UTF-8 >&! utf8_chset.${bld}.out
	set rtndir="${dir}/utf8(${dir})"
endif

# If we didn't build mumps, there is no point to testing. exit silently
if (! -e ${dir}/mumps ) exit -1

# setup to use the target build
setenv gtm_dist "$PWD/${dir}"
setenv gtmroutines "${rtndir}"
setenv gtmgbldir ${bld}.gld

printenv gtm_dist	>> ${bld}_setup.log
printenv gtmroutines	>> ${bld}_setup.log
printenv gtm_chset	>> ${bld}_setup.log

# 0. Ensure that GT.M was built before proceeding
if ( ! -e $gtm_dist/mumps ) then
	echo "TEST-F-FAIL: There is no $gtm_dist/mumps"
	exit 1
endif

# 1. Test whether or not we can invoke GT.M, if not skip all other tests
$gtm_dist/mumps -run %XCMD 'write "PASS",\!' || echo "TEST-E-FAIL %XCMD"

# Jackal uses the mutex files and not MSEMs so setuid gtmsecshr so that in case
# we need to prune the mutex files this will work
$gtm_com/IGS ${dir}/gtmsecshr "CHOWN"


# 2. Test GDE, MUPIP and DSE
set fail=0
$gtm_dist/mumps -run GDE change -segment DEFAULT -file=${bld}.dat >>&! ${bld}_exec.log || @ fail++
$gtm_dist/mupip create >>&! ${bld}_exec.log || @ fail++
$gtm_dist/dse dump -fileheader  >>&! ${bld}_exec.log || @ fail++
if ( 0 != $fail) then
	echo "TEST-E-FAIL GDE, MUPIP and/or DSE"
	cat ${bld}_exec.log
endif

# delete the DAT and GLD files, RM will squak if the files are not present
\rm ${bld}.gld ${bld}.dat

# delete the root owned files
$gtm_com/IGS ${dir}/gtmsecshr "RMDIR"
