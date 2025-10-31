#################################################################
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

# $1 - output file containing imptp.csh invocation output

# This script checks if the imptp.csh output has any errors.
# It searches for -E-, -W-, -F- and if so issues an error and exits the calling script.

# Every script that calls imptp.csh should immediately afterwards call this script to check for imptp.csh errors.
# This ensures the calling script (usually a subtest driver script) does not continue past an imptp.csh
# invocation that errored out as it could otherwise lead to hard-to-diagnose subtest hangs (see YDBTest#431 for details).

# It is possible some caller scripts (e.g. "ideminter_rolrec/u_inref/wait_multiple_history.csh") have "set echo" or
# "set verbose" on and redirect the output to a "*.out" file. In that case the "-E-" in the grep command below would
# show up in the output and be flagged by the test framework as a false failure. To avoid that, "unset echo" and
# "unset verbose" while doing the grep.
if ($?echo) then
	set echo_was_set = 1
	unset echo
endif

if ($?verbose) then
	set verbose_was_set = 1
	unset verbose
endif

$grep -E "\-E-|-W-|-F-" $1 >& /dev/null
if (1 != $status) then
	echo "IMPTP-E-FAIL : imptp.csh invocation had errors in file [$1]:"
	# print from error or "# Running" to end of file
	sed -En '/-E-|-W-|-F-|# Running/,$p' $1
	@ exit_status = 1
else
	@ exit_status = 0
endif

# Restore "set echo" and "set verbose" settings as it was at entry into this script before returning
if ($?verbose_was_set) then
	set verbose
endif
if ($?echo_was_set) then
	set echo
endif

exit $exit_status

