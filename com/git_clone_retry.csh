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
# Usage:
# $gtm_tst/com/git_clone_retry.csh <logfile> [<git clone option> ...] <url> <destination directory>
#
# Runs "git clone" with the supplied arguments and retries it if it fails. The destination directory
# is a required last argument because it is removed before each retry; "git clone" refuses to clone
# into an existing non-empty directory, and a failed clone can leave one behind.
#
# The output of every attempt is appended to <logfile>, and is displayed only if every attempt
# fails, so a caller whose output is compared against a reference file sees nothing extra as long as
# the clone eventually succeeds.
#
# Exits with the status of the last "git clone" attempt.

if (3 > $#argv) then
	echo "GITCLONERETRY-E-USAGE : Usage : $0 <logfile> [<git clone option> ...] <url> <destination directory>"
	exit 1
endif
set logfile = $argv[1]
shift
set clonedir = $argv[$#argv]
set maxattempt = 3	# total number of "git clone" attempts before giving up
set sleeptime = 30	# seconds to wait before each retry
set attempt = 1
while (1)
	echo "# Attempt $attempt of $maxattempt : git clone $argv" >>& $logfile
	git clone $argv >>& $logfile
	set clonestatus = $status
	if (0 == $clonestatus) break
	if ($maxattempt <= $attempt) break
	if (-d $clonedir) rm -rf $clonedir
	sleep $sleeptime
	@ attempt = $attempt + 1
end
if (0 != $clonestatus) then
	echo "GITCLONERETRY-E-FAILED : [git clone $argv] failed with status [$clonestatus] after $attempt attempts"
	cat $logfile
endif
exit $clonestatus
