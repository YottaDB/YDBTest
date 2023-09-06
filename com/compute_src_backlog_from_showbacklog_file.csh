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

# This script computes the source side backlog from the MUPIP REPLIC -SOURCE -SHOWBACKLOG output.
# The output is present in a file that is passed in as $1.
# It is possible for multiple showbacklog outputs to be present in the same file (for example, if the caller is RF_sync.csh).
# In that case, the LAST showbacklog output is taken into account for the calculations (hence the "tail -1" below).

set logfile = $1

set posted = `$tst_awk '/Last transaction sequence number posted/ {print $NF}' $logfile | tail -1`
if ("" == $posted) then
	echo "COMPUTE_SRC_BACKLOG-E-FAIL1 : No [posted] sequence number found in $logfile"
	exit -1
endif

set sent = `$tst_awk '/Last transaction sequence number sent/ {print $NF}' $logfile| tail -1`
if ("" == $posted) then
	echo "COMPUTE_SRC_BACKLOG-E-FAIL2 : No [sent] sequence number found in $logfile"
	exit -1
endif

set backlog = `expr $posted - $sent`
echo $backlog

