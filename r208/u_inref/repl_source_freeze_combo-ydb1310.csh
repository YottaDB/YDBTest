#!/usr/local/bin/tcsh -f
#################################################################
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

echo "#-----------------------------------------------------------------------------------------------#"
echo "# [#1310] MUPIP REPLICATE -SOURCE rejects -FREEZE together with another control qualifier       #"
echo "#-----------------------------------------------------------------------------------------------#"
echo

# mupip_cmd_disallow.c allows a MUPIP REPLICATE -SOURCE command at most one of thirteen control qualifiers, checked
# by a cli_check_any2() call that declared 11 of the 13 qualifiers it passed. cli_check_any2() reads only as many
# as its count, so -JNLPOOL and -FREEZE were never examined there. -JNLPOOL is rejected with another control
# qualifier by a separate rule, -FREEZE was not. So -FREEZE with -SHUTDOWN, -DEACTIVATE, -CHECKHEALTH, -STATSLOG,
# -SHOWBACKLOG, -STOPSOURCEFILTER, -LOSTTNCOMPLETE or -NEEDRESTART got past the check and went on to open the
# global directory. -START, -ACTIVATE and -CHANGELOG are rejected with -FREEZE by other rules.
#
# Each command below must fail the qualifier check with CLIERR before it opens anything. This subtest creates no
# global directory, so a command that gets past the check fails with ZGBLDIRACC instead.

set quals = "-start -shutdown -activate -deactivate -checkhealth -statslog=on -showbacklog -changelog -stopsourcefilter"
set quals = "$quals -losttncomplete -needrestart -jnlpool"
foreach qual ($quals)
	set outfile = freeze$qual:s/=/_/.out
	echo "# Command : "'$MUPIP'" replicate -source $qual -freeze"
	$MUPIP replicate -source $qual -freeze < /dev/null >&! $outfile
	set firstline = "`head -1 $outfile`"
	if ("-jnlpool" == "$qual") then
		set expected = "%YDB-E-CLIERR, Unrecognized option : FREEZE"
	else
		set expected = "%YDB-E-CLIERR, Missing or illegal combination of command elements - check documentation: "
	endif
	if ("$firstline" =~ "${expected}*") then
		echo "PASS : rejected with CLIERR"
	else
		echo "WRONG : expected [$expected...] - see $outfile"
		echo "$firstline"
	endif
	$gtm_tst/com/check_error_exist.csh $outfile CLIERR >&! ${outfile:r}_check.logx
end
