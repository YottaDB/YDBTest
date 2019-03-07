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

if ($?ydb_environment_init && $?gtm_chset) then
	if ("UTF-8" == "$gtm_chset") then
		# gtm_test_trig_upgrade env var would have been set to 1 by triggers/instream.csh but in UTF-8 mode if we go to
		# dbcheck.csh with this env var set, we would try to run a pre-V63000A version in UTF-8 mode which currently does
		# not work in a YDB setup (due to ICU library naming issues with older builds). So disable the trigger upgrade check
		# in that case.
		unsetenv gtm_test_trig_upgrade
	endif
endif
