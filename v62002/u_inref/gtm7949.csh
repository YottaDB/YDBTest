#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Verify $ZHOROLOG and $ZUT display the correct time

set prior_ver = `$gtm_tst/com/random_ver.csh -gte V62001 -lte V62001`
if ("$prior_ver" =~ "*-E-*") then
	echo "No such prior version : $prior_ver"
	exit -1
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
source $gtm_tst/com/switch_gtm_version.csh $prior_ver pro
set prior_gtm_dist = "$gtm_dist"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image

# Compare $ZUT value against the unix timestamp
# If a time zone is not installed or undefined it should fall back to UTC
foreach zone ( EST EDT EEST UTC NOVT AKDT XXX )
	set i = 0
	set file = zutcheck_${zone}.outx
	while ($i < 10)
		env TZ=$zone $gtm_exe/mumps -run %XCMD "do zutcheck^gtm7949("`date +%s`")" >> $file
		@ i++
	end
	if (`$grep -c FAIL $file` >= 3) then
		echo "TEST-E-FAIL at least 3 ZUT values were different in 10 runs. See $file"
	else
		echo "TEST-I-PASS ZUT: $zone is OK"
	endif
end

# Compare the $zhorolog value against the unix timestamp
set file = zhorologcheck_UTC.outx
set i = 0
while ($i < 10)
	env TZ=UTC $gtm_exe/mumps -run %XCMD "do zhorologcheck^gtm7949("`date +%s`")" >> $file
	@ i++
end
if (`$grep -c FAIL $file` >= 3) then
	echo "TEST-E-FAIL at least 3 zhorolog values were different in 10 runs. See $file"
else
	echo "TEST-I-PASS zhorolog is OK"
endif

# Backwards compatibility test. The older version and newer version should give approximately same value
set file = horolog_compatibility.outx
set i = 0
while ($i < 10)
	set oldvertime = `env gtm_chset=M gtm_dist=$prior_gtm_dist gtmroutines=$prior_gtm_dist $prior_gtm_dist/mumps -run %XCMD 'write $horolog'`
	set newvertime = `$gtm_exe/mumps -run %XCMD 'write $horolog'`
	$gtm_exe/mumps -run %XCMD 'do comparehorologs^gtm7949("'"$oldvertime"'","'"$newvertime"'")' >> $file
	@ i++
end
if (`$grep -c FAIL $file` >= 3) then
	echo "TEST-E-FAIL at least 3 horolog values were incompatible in 10 runs. See $file"
else
	echo "TEST-I-PASS horolog compatibility is OK"
endif
