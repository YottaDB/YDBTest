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

set gtmsecshr_realpath = `realpath $gtm_dist/gtmsecshr`
set secshrpid = `pgrep -f $gtmsecshr_realpath`
if ("$secshrpid" != "") then
	sudo kill $secshrpid
endif
set secshrpid = `pgrep -f $gtm_dist/gtmsecshr`
if ("$secshrpid" != "") then
	sudo kill $secshrpid
endif

