#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# The below script is currently short-circuited as V7.0-000 does not support MUPIP REORG -UPGRADE or -DOWNGRADE.
# This short-circuit can be removed once MUPIP SET -VERSION=, MUPIP REORG -UPGRADE etc. are supported (in V7.1-000).
# Note: There is a similar comment in com/mupip_set_version.csh.
exit	# [UPGRADE_DOWNGRADE_UNSUPPORTED]

if ( "ENCRYPT" == $test_encryption ) then
        echo "TEST-I-ENCRYPT, Online upgrade-downgrade cannot be run since MUPIP SET version=V4 not supported with encryption"
	exit
endif

if ( 1 == "$gtm_test_asyncio") then
        echo "TEST-I-ASYNCIO, Online upgrade-downgrade cannot be run since MUPIP SET version=V4 not supported with ASYNCIO"
	exit
endif

set run_reorg_upgrd_dwngrd

if (! $?gtm_test_disable_randomdbtn) then
	#cannot downgrade if the TN is too large, so makes no sense to try to upgrade, either
	# Check the gtm_test_dbcreate_initial_tn value in settings.csh
	if (-e settings.csh) then
		$grep gtm_test_dbcreate_initial_tn settings.csh >&! tmp.csh
		source tmp.csh
		\rm tmp.csh
	else
		echo "BKGRND_REORG_UPGRD_DWNGRD-E-SETTINGS.CSH is not found"
	endif
	if ($?gtm_test_dbcreate_initial_tn) then
		if (32 > $gtm_test_dbcreate_initial_tn) then
			set run_reorg_upgrd_dwngrd
		else
			echo "TEST-I-LARGETN, too large a starting TN, cannot downgrade, so makes no sense to run upgrade either"
			unset run_reorg_upgrd_dwngrd
		endif
	else
		echo "TEST-E-SKIP. gtm_test_dbcreate_initial_tn is not known. So will skip online_reorg_upgrd_dwngrd"
		exit
	endif
endif

if ($?run_reorg_upgrd_dwngrd) $gtm_tst/com/online_reorg_upgrd_dwngrd.csh >& online_reorg_upgrd_dwngrd.log &
