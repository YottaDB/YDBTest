#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This script is sourced when "gtm_test_trigupdate" env var is set to 1.
# This will set other related env vars that are needed to avoid false test failures.
#
# $1 - Full path of settings.csh file to record this script invocation.
#

if ("" == $1) then
	set logfile = settings.csh
else
	set logfile = $1
endif

echo '# gtm_test_extr_no_trig env var forced to be 1 due to $gtm_test_trigupdate=1'	>>&! $logfile
echo '# This is needed to avoid db extract differences at the trigger level between'	>>&! $logfile
echo '# the source and receiver side in a replication test'				>>&! $logfile
echo "setenv gtm_test_extr_no_trig 1"							>>&! $logfile
setenv gtm_test_extr_no_trig 1

# Also note the fact that this script is the one that set "gtm_test_extr_no_trig" by setting a "gtm_test_trigupdate_enabled"
# env var. This will be later used by "gtm_test_trigupdate_disabled.csh" to undo the "gtm_test_extr_no_trig" env var setting
# in case "gtm_test_trigupdate_enabled.csh" set the env var. If any other script set this env var (e.g. "filter/instream.csh"),
# then we do not want to undo hence the need to note down that this script did the setenv.
setenv gtm_test_trigupdate_enabled 1

unset logfile
