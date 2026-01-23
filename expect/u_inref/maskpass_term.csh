#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test verifies that maskpass restores the terminal settings when killed with Ctrl-C and
# that it honors most conventional signals (such as SIGTERM, SIGSEGV, and so on) while ignoring
# most others.

# AIX boxes seem to have issues with spawning processes from Expect scripts.
if ("AIX" != "$HOSTOS") then
	(expect -d $gtm_tst/$tst/inref/maskpass_term.exp > expect.out) >& expect.dbg
	# If nothing has changed then this is a pass
	diff tty_before.logx tty_after.logx
	if (0 != $status) then
		echo "TEST-E-FAIL, Terminal characteristics changed; see diff above."
		exit 1
	endif
endif

$gtm_dist/mumps -run maskpassterm
