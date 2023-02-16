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

# This script is sourced when "gtm_test_trigupdate" env var is set to 0 by certain tests.
# Some reasons for doing so are
# 1) The test does a switch over in which case the test needs to uninstall the trigger definitions from the old source side
#    and install the trigger definitions in the new source side to avoid db extract differences between the new source and
#    receiver (and in turn test failures). See https://gitlab.com/YottaDB/DB/YDB/-/issues/722#note_1283413238 for more details.
#    This is not easily done and so we disable this env var in such tests.
# 2) The test does a fail over. For the same reasons as described in the "switch over" case we need to disable this env var.
# 3) The test plays with trigger definitions and is run with -replic (e.g. all subtests of the "triggers" subtest). This can
#    cause db extract differences on the source/receiver side (due to trigger definitions that are missing on the receiver
#    side) when run with -trigupdate so disable that.
# 4) The test refreshes the secondary/receiver-side from a backup of the primary/source-side. This means triggers from the source
#    side will also be installed on the receiver side and -trigupdate will replicate the updates happenning inside the trigger
#    from the source side leading to duplicated updates (see https://gitlab.com/YottaDB/DB/YDB/-/issues/722#note_1283644272 for
#    more details).
# 5) The test runs A->P configuration where imptp.csh is invoked on A and P. That will install triggers on both A and P. Some
#    of the triggers rely on $ztwormhole and that won't be replicated across in case of -trigupdate resulting in NULSUBSC errors
#    when $ztwormhole is used as a last subscript in the global variable node as part of the imptp.csh trigger definition.
#    The suppl_inst_A/same_start_seqno subtest fails/hangs with this symptom.

set logfile = "settings.csh"

echo "# Disabling gtm_test_trigupdate in gtm_test_trigupdate_disabled.csh"	>>&! $logfile
echo "# Possible due to test doing switchover/failover etc."			>>&! $logfile
echo "setenv gtm_test_trigupdate 0"						>>&! $logfile
setenv gtm_test_trigupdate 0

# In addition, we also need to undo the "setenv gtm_test_extr_no_trig 1" that was done by "gtm_test_trigupdate_enabled.csh"
# in case that setenv happened (we know this by looking at "gtm_test_trigupdate_enabled" env var).
if ($?gtm_test_trigupdate_enabled) then
	if ($gtm_test_trigupdate_enabled) then
		echo '# Undoing "setenv gtm_test_extr_no_trig 1" done in gtm_test_trigupdate_enabled.csh'	>>&! $logfile
		echo '# Now that "setenv gtm_test_trigupdate 1" is being undone as well'			>>&! $logfile
		echo "unsetenv gtm_test_extr_no_trig"								>>&! $logfile
		unsetenv gtm_test_extr_no_trig
	endif
endif

unset logfile
