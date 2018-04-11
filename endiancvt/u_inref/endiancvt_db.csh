#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################

# This redirect-grep arrangement is for the "wait" command to work
# wait works only if the background jobs are in the same shell. (bla &) >&! /dev/null will not make the wait command actually wait. Hence the workaround
foreach db ($*)
	$MUPIP endiancvt $db < yes.txt >&! endiancvt_$db.out &
end

# the wait command waits for all the background processes to be complete before it returns
wait
set wait_status = $status
echo $wait_status
if ($wait_status) then
	echo "TEST-E-WAIT the command wait failed with the status $wait_status"
endif

foreach file ($*)
	$grep YDB-I-ENDIANCVT endiancvt_$file.out
end
