#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set timestamp = `date +%H%M%S`
set chkhealth = checkhealth_$timestamp.out
set showbacklog = showbacklog_$timestamp.out
set pslist = b4_srcsrvkill_pslist_$timestamp.outx

echo "BEFORE Kill -9 of Source Server" >>&! $pslist
echo "-------------------------------" >>&! $pslist
$ps >>&! $pslist
$MUPIP replicate -source -showbacklog >&! $showbacklog
$MUPIP replicate -source -checkhealth >&! $chkhealth
if (! $status) then
	$MSR SYNC INST1 INST2	# SYNC before Killing the source server so that we can expect the DB Extract to PASS
	set pidsrc = `$tst_awk '($1 == "PID") && ($2 ~ /[0-9]*/) { print $2 }' $chkhealth`
	$kill9 $pidsrc
endif
echo "AFTER Kill -9 of Source Server" >>&! $pslist
echo "------------------------------" >>&! $pslist
$ps >>&! $pslist
