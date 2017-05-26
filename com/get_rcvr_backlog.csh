#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Usage :
#   $gtm_tst/com/get_rcvr_backlog.csh [rcvpool|updproc]
# Returns one of the below depending on the parameter passed (default is receiver backlog)
#   -> receiver backlog
#   -> Last transaction written to receive pool
#   -> Last transaction procesed by update process

set todo = "$1"
if ("" == "$todo") then
	set toget = "number of backlog transactions"
else if ("rcvpool" == "$todo") then
	set toget = "last transaction received from Source Server"
else if ("updproc" == "$todo") then
	set toget = "last transaction processed by update process"
endif
set logfile = "get_rcvr_backlog_`date +%H%M%S`_$$.out"
$MUPIP replicate -receiver -showbacklog >&! $logfile
set tn = `$tst_awk '/'"$toget"'/ {if ($1 ~ /^[0-9]+$/) print $1}' $logfile`
echo $tn
