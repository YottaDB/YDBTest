#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# If the test started with V4 blocks, we need to check for V4 blocks prior to any online rollback.
# It would be nice to do this in try_rolrec.csh, but the arguments are passed down from
# rolrec_three_tries.csh
if (("V4" == "$gtm_test_db_format") && ("" != "$rollbackmethod")) then
	set activeblockver = `$gtm_tst/com/check_for_V4_blocks.csh`
	if ("V4" == "$activeblockver") then
		setenv rollbackmethod ""
		echo "# V4 block version detected, disabling online rollback" >> settings.csh
	endif
endif
