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
#

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-9443 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-001_Release_Notes.html#GTM-9443)

When MUPIP SET -JOURNAL encounters a temporary journal file that is an artifact of the renaming
process GT.M uses to create a chain of journal files, it only deletes it after concluding that has
been abandoned by seeing that it persists for an interval longer than the renaming process should
take. Previously when MUPIP encountered a temporary journal file, it assumed the file was an abandoned
artifact and immediately deleted it potentially inappropriately breaking the chain. (GTM-9443)

CAT_EOF

setenv gtm_test_jnl SETJNL

echo "# Create database with journaling turned on"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate.out
	exit -1
endif

set tempjnlfile = "mumps.mjl_%YGTM"
foreach count (1 2)
	echo ""
	echo "# ############################## Test $count #############################"
	if (1 == $count) then
		echo "# Preserve original journal file [mumps.mjl]"
		echo "# Create temporary journal file name used in journal file renaming process [$tempjnlfile]"
		touch $tempjnlfile
	else
		echo "# Delete original journal file [mumps.mjl]"
		echo "# Create temporary journal file name used in journal file renaming process [$tempjnlfile]"
		mv mumps.mjl $tempjnlfile
	endif
	echo "# ########################################################################"
	echo "# Run [mupip set -journal] command and verify it does checks on [$tempjnlfile] multiple times"
	echo "# to confirm it is indeed abandoned BEFORE going ahead with deleting that file."
	echo "# Use [strace] and check for system calls that use [$tempjnlfile] OR [nanosleep]."
	echo "# We expect to see 30 of the stat($tempjnlfile) and nanosleep() calls below."
	echo "# Before GTM-9443, these 30 stat() and nanosleep() calls would not show up."
	echo "# This also verifies that [$tempjnlfile] file gets deleted/created/renamed in that order by [mupip set -journal]"
	echo "# ########################################################################"
	# Keep strace output in .outx file (not .out) as strings like "Permission denied" can show up in strace output
	# and would be falsely identified as a test failure by the test framework error catcher.
	strace -o trace$count.outx $MUPIP set $tst_jnl_str -reg "*" >&! mupip_set_journal$count.out
	# Remove system call parameters as those can vary with different kernel/linux-distributions
	# Treat "newfstat()" and "stat()" as same as these show up on different kernels/linux-distributions.
	# Same with "openat()" -> "open()" and others.
	$grep -E "$tempjnlfile|nanosleep" trace$count.outx | sed 's/(.*/()/;s/newfstatat/stat/;s/statx/stat/;s/openat/open/;s/unlinkat/unlink/;s/renameat/rename/;'
end

echo "# Do dbcheck on database"
$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck.out
	exit -1
endif

