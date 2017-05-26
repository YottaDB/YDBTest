#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#==========================
# RCVR_SHUT.csh [replication flag]
# 	Shut down receiver server
#       and turn replication off depending on replication flag
#==========================
# Include -l option to have the "Process State" information. But not including it in the default $ps as it has some column issues
set ps = "${ps:s/ps /ps -l /}"	#BYPASSOK ps
$MUPIP replic -receiv -shutdown -timeout=0
if ($status) then
        echo  "Receriver server shutdown on receiver side failed!"
	$gtm_tst/com/ipcs -a
	$ps
	sleep 5
	echo "Trying again ..."
	$MUPIP replic -receiv -shutdown -timeout=0
endif
$MUPIP replic -source -shutdown -timeout=0
if ($status) then
        echo  "Passive source server shutdown on receiver side failed!"
	$gtm_tst/com/ipcs -a
	$ps
endif
setenv repl_state "$1"
# MSR tests will call replication scripts with "decide" sometimes to let the script decide about the replication state
# this will NOT affect any regular dual site test
if ( "decide" == $1 ) then
	$MUPIP replic -source -checkhealth >&! checkhealth_decide_state_v4.out
	if ($status) then
		# this filters NOJNLPOOL errors from the out so we don't get that reported at the end of the test
		$gtm_tst/com/check_error_exist.csh checkhealth_decide_state_v4.out "NOJNLPOOL" >/dev/null
		setenv repl_state "off"
	else
		echo "MSR-I-REPLOFF cannot be done at this point in time as some other servers are still running"
	endif
endif
if ( "off" == $repl_state ) then
	$MUPIP set -replic=off -reg "*"
	if ($status) then
		echo  "Turning replication off on receiver side failed!"
		$gtm_tst/com/ipcs -a
		$ps
	endif
endif
