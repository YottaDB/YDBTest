#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2005-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# The below script is currently short-circuited as V7.0-000 does not support V6 block format in db file on disk.
# This short-circuit can be removed once MUPIP SET -VERSION=, MUPIP REORG -UPGRADE etc. are supported (in V7.1-000).
# Note: There is a similar comment in com/bkgrnd_reorg_upgrd_dwngrd.csh.
echo "# gtm_test_db_format=NO_CHANGE set in mupip_set_version.csh until V6 block format is supported"	>>! settings.csh
setenv gtm_test_db_format "NO_CHANGE"
echo "setenv gtm_test_db_format $gtm_test_db_format" 								>>! settings.csh
exit	# [UPGRADE_DOWNGRADE_UNSUPPORTED]

# unless otherwise requested, set block version to V6 or V7, randomly [50-50]
# So possibilities are:
# $gtm_test_mupip_set_version 	- undefined means random [50-50]
#				- V6 - set it to V6
#				- V7 - set it to V7
#				- "no", "disable" - (effectively equivalent to V6 for now)
#				  "NO", "DISABLE"

# if it is an MM test, we cannot change the desired db block format, so exit:
if ("MM" == $acc_meth) exit

#if it is a GT.CM test, we will disable mupip set version
if ("GT.CM" == $test_gtm_gtcm) exit

#if it is an encryption test, we cannot change the the desired db block format, so exit:
if ("ENCRYPT" == $test_encryption) exit

# if this script has been run before, the decision made will be in settings.csh, so source that
# so that we will use the same setting this time round as well:
if (-e settings.csh) then
	# Get only the value of gtm_test_db_format from settings.csh. If present tmp.csh will have the setenv command
	# else the file will be null. So no need to check the presence of gtm_test_db_format explicitly
	$grep -E "gtm_test_db_format|gtm_test_online_integ" settings.csh >&! tmp.csh
	source tmp.csh
	\rm tmp.csh
endif

if (! $?gtm_test_db_format) then
	if (0 == $?gtm_test_mupip_set_version) then
		# pick randomly [0,1]
		\rm -f rand.o	# In case prior versions are being used and rand.o already existed
		set rand = `$gtm_exe/mumps -run rand 2`
		# Note: We cannot do 'setenv' gtm_test_db_format since mupip_set_version will be invoked again in case of
		# replication and will bypass all these checks and will NOT create settings.csh for secondary side. This
		# is something that dbcheck->set_online_for_dbcheck relies upon. So instead of setenv, use set
		# See <mupip_set_version_SSV4NOALLOW>
		if (0 == $rand) set gtm_test_db_format = "V6"
		if (1 == $rand) set gtm_test_db_format = "V7"
	else
		switch($gtm_test_mupip_set_version)
			case "V6":
				setenv gtm_test_db_format "V6"
				breaksw
			case "V7":
				setenv gtm_test_db_format "V7"
				breaksw
			case "no":
			case "NO":
			case "disable":
			case "DISABLE":
				setenv gtm_test_db_format "NO_CHANGE"
				breaksw
		endsw
	endif
	echo "# gtm_test_db_format defined in mupip_set_version.csh" 				>>! settings.csh
	echo "setenv gtm_test_db_format $gtm_test_db_format" 					>>! settings.csh
else if (-e settings.csh) then
	if (! `$grep -c gtm_test_db_format settings.csh`) then
		echo "# gtm_test_db_format was specified before entering mupip_set_version.csh" >>! settings.csh
		echo "setenv gtm_test_db_format $gtm_test_db_format" 				>>! settings.csh
		echo ""						 				>>! settings.csh
	endif
endif

if ("NO_CHANGE" == "$gtm_test_db_format") exit

set timestamp = `date +%y%m%d_%H%M%S`

# now that the version is determined, set it:
alias command '$MUPIP set -version=$gtm_test_db_format -region "*"'
echo "#########################################################################" >>! msv_${timestamp}.out
date >>! msv_${timestamp}.out
alias command	>>! msv_${timestamp}.out
command 	>>&! msv_${timestamp}.out
set mupip_status = $status
echo "#########################################################################" >>! msv_${timestamp}.out
if ($mupip_status) then
	echo "MUPIP_SET_VERSION-E-ERROR, mupip set -version returned status $mupip_status, please check msv_${timestamp}.out"
endif
