#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This is a helper script for spanning_nodes/sn_jnl5 test. It picks a random version whose
# journal buffer size default and minimum and below the current ones.

# Save the index for log-naming purposes
set index = $1

if ( ("ENCRYPT" == "$test_encryption") && ("aix" == "$gtm_test_osname") ) then
	# From random_ver: On AIX, the AES256 cipher in versions [V53004; V60000] and Blowfish cipher in versions [V53004; V54000A]
	# were either unsupported or caused hangs in tests, and thus are not usable.
	unsetenv gtm_crypt_plugin
	setenv gtm_test_exclude_encralgo AES256CFB
	echo "# Encryption algorithm re-randomized by the test"	>>&! settings.csh
	source $gtm_tst/com/set_encryption_lib_and_algo.csh	>>&! settings.csh
endif

# Pick a random version whose default and minimum journal buffer sizes are below the
# current default and minimum. (Actually, the current default is one above the minimum.)
set msver = `$gtm_tst/com/random_ver.csh -gte V53000 -lte V55000`
if ("$msver" =~ "*-E-*") then
	echo "No prior versions available: $msver"
	exit -1
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $msver

# Remember the selected old version
source $gtm_tst/com/switch_gtm_version.csh $msver pro

# Print the prior version to a file
echo $msver >& priorver${index}.txt
