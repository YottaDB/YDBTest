#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

if ($?gtm_test_temporary_disable) then
	# With encryption enabled, we get a CRYPTKEYFETCHFAILED error currently (hash mismatch).
	# Temporarily disable encryption until this issue is fixed.
	if ("ENCRYPT" == "$test_encryption" ) then
		if (`expr "V63000A" \> "$prior_ver"`) then
			setenv test_encryption NON_ENCRYPT
		endif
	endif
endif
