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

# This script kills $gtm_dist/gtmsecshr if it is already running.

# Note that it is possible if "$gtm_dist" is a soft link, that the "ps -ef" output might show the soft link
# or the pointed to path of "gtmsecshr". It is not clear when one vs the other shows up. So this script checks
# for both possibilities ("$gtm_dist/gtmsecshr" and "realpath $gtm_dist/gtmsecshr") in the "ps -ef" output and
# kills either one if it exists. We use "pgrep -f" instead of "ps -ef" to do the actual search.
#
# An example is
#	$gtm_dist          = /usr/library/V71002_R206 VS
#	realpath $gtm_dist = /usr/library/R206

# Both searches are done BEFORE anything is killed, and the deduplicated union is killed in ONE
# "sudo kill". Doing them as two separate searches each followed by its own kill (as this script used
# to) is a race whenever "$gtm_dist" is NOT a soft link, because then both searches return the SAME
# pids. The first kill signals them, the second "pgrep" a moment later still sees them while they are
# going away, and by the time the second kill runs they are gone, so it writes
#
#	kill: (<pid>): No such process
#
# to stderr, once per pid. That is captured into the subtest output file and shows up as a subtest
# diff. It only fails when the processes finish exiting between the two kills, which is why it is
# seen on rare occasions rather than on every run.
set gtmsecshr_realpath = `realpath $gtm_dist/gtmsecshr`
set secshrpid = `(pgrep -f $gtmsecshr_realpath; pgrep -f $gtm_dist/gtmsecshr) | sort -u`
if ("$secshrpid" != "") then
	sudo kill $secshrpid
endif

