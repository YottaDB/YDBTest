#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2008-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

# Tool to wait until the journal seqno of the instance as reported by -showbacklog exceeds the input number
#
# Can be used either on the source or the receiver side.
# This tool should be used for "at least" and not for "exactly" n transactions.
#
# In case of multisite-replic, if multiple source servers are running the secondary instance name should be passed as 4th parameter
#
# If the tool is expected to silently exit (without printing -E- error message) if expected transaction seqno is not reached in the given time, "noerror" should be passed as 5th parameter
# Note:
# The tool currently doesn't handle numbers greater than 2G (2,147,483,648).
# If such a requiremnt arises in future build on top of the logic in ~library/cron/root_allunix_sysadmin_zipsyslog.csh

if ($#argv == 0) then
	echo ""
	echo "usage : $0 <seqno_to_wait> [RCVR|SRC] [maxwait] [secondary_instance_name] [noerror]"
	exit 1
endif

set seqno_to_wait = $1
if ("RCVR" == "$2") then
	set srcrcvr = "$2"
else
	set srcrcvr = "SRC"
endif

if ("" != "$3") then
	set maxwait = $3
else
	set maxwait = 120
endif

if ("" != "$4") then
	set instsecondary = "-instsecondary=$4"
else
	set instsecondary = ""
endif

if ("noerror" == "$5") set noerror=1

if ("SRC" == "$srcrcvr") then
	set bklogcmd = "$MUPIP replicate -source -showbacklog $instsecondary"
	set togrep = "Last transaction sequence number posted"
else
	set bklogcmd = "$MUPIP replicate -receiver -showbacklog"
	set togrep = "sequence number of last transaction processed by update process"
endif

# modified from test/com_u/wait_until_rcvr_trn_processed_above.csh
# Done here so that we can flip between SRC and RCVR
unset isdelta
if ("$seqno_to_wait" =~ +* ) set isdelta
if ($?isdelta) then
	# It means seqno_to_wait is not absolute value but increase from current value
	set seqno_to_wait = "$seqno_to_wait:s/+//"
	set logfile = "wfb_$$.log"
	$bklogcmd >&! $logfile
	set cur_seqno = `$tst_awk '/'"$togrep"'/ {cs=$1} END {print 0+cs}' $logfile`
	@ seqno_to_wait = $cur_seqno + $seqno_to_wait
	set starting_seqno = $cur_seqno
endif

$bklogcmd >&! wait_for_transaction_seqno.backlog
set cur_seqno = `$tst_awk '/'"$togrep"'/ {cs=$1} END {print 0+cs}' wait_for_transaction_seqno.backlog`
if !($?starting_seqno) set starting_seqno = $cur_seqno
set wait = 0

# loop until either the current seqence number is greater than the expected or
# wait time exceeds maxwait time
while (($cur_seqno <= $seqno_to_wait) && ($wait < $maxwait))
	sleep 1
	@ wait = $wait + 1
	$bklogcmd >&! wait_for_transaction_seqno.backlog
	set cur_seqno = `$tst_awk '/'"$togrep"'/ {cs=$1} END {print 0+cs}' wait_for_transaction_seqno.backlog`
end

if ($?noerror) exit 0

if ($?isdelta && ($starting_seqno == $cur_seqno)) then
	echo "TEST-E-WAIT_FOR_TRANSACTION_SEQNO no transactions committed in $wait seconds."
	echo "Started waiting at $starting_seqno and completed at $cur_seqno"
	exit 1
else if ($wait >= $maxwait) then
	echo "TEST-E-WAIT_FOR_TRANSACTION_SEQNO timeout. Waited for $wait seconds."
	echo "The '$togrep' is less than the expected $seqno_to_wait (started at $starting_seqno)"
	exit 1
endif

exit 0
