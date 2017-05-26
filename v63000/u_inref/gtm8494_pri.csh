#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Helper script for gtm8494.csh that runs in the primary side, starting and stopping replication source server

@ cnt = 1

# test.end is created by gtm8494_sec.csh when it is done executing.
# It is also created (by this script) when the primary side is done generating 50 history records.

while ( ! -e test.end )
	$gtm_exe/mumps -run %XCMD 'for i=1:1:$r(100) set ^x('$cnt',i)='${cnt}'_i'
	echo "# `date` : stop-start round $cnt"
	$MSR STOPSRC INST1 INST2
	$MSR STARTSRC INST1 INST2
	@ cnt = $cnt + 1
	if ($cnt == 50) then
		echo "`date` : gtm8494_sec.csh ends : cnt = $cnt" >> test.end
		# Copy test.end to secondary
		$MSR RUN SRC=INST1 RCV=INST2 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/test.end _REMOTEINFO___RCV_DIR__/'
	endif
end

$MUPIP replic -editinstance -show mumps.repl >&! pri_replinstance_show_final.out
