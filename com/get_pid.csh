#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# A tool to get the pid of the server type passed as the first argument (rcvr|updproc|src|passive) src optionally accepts instsecondary
# returns null if the server isn't running or even if the instance isn't setup - No error thrown
# Usage:
# $gtm_tst/com/get_pid.csh <src|rcvr|updproc|passive> [secondary_instance_name]

set what = $1
if ("" == "$2") then
	set instsecondary = ""
else
	set instsecondary = "-instsecondary=$2"
endif
set logfile = "get_pid_{$$}.outx"	# servers not running is not an error condition for now

if ($what =~ {rcvr,updproc} ) then
	$MUPIP replicate -receiv -checkhealth >& $logfile
	if ( "rcvr" == "$what" ) set msg = "Receiver server is alive"
	if ( "updproc" == "$what" ) set msg = "Update process is alive"
	set pid = `$tst_awk '/'"$msg"'/ {print $2}' $logfile`
endif

if ($what =~ {src,passive} ) then
	$MUPIP replicate -source -checkhealth $instsecondary >& $logfile
	if ( "passive" == "$what" ) set msg = "Source server is alive in PASSIVE mode"
	if ( "src" == "$what" ) set msg = "Source server is alive in ACTIVE mode"
	set pid = `$tst_awk '/'"$msg"'/ {print $2}' $logfile`
endif

echo $pid
