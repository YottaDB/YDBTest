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
#   $gtm_tst/com/get_src_backlog.csh [instsecondary]
# Returns the source server backlog of the given secondary (if not passed, picks $gtm_test_cur_sec_name)

set vernow = "$gtm_exe:h:t"
if (`expr $vernow \< "V51000"`) then
	setenv gtm_test_instsecondary
endif
if (! $?gtm_test_instsecondary ) then
	setenv gtm_test_instsecondary "-instsecondary=$gtm_test_cur_sec_name"
endif
if ("" != "$1") then
	setenv gtm_test_instsecondary "-instsecondary=$1"
endif

set logfile = "get_src_backlog_`date +%H%M%S`_$$.out"
$MUPIP replicate -source $gtm_test_instsecondary -showbacklog >& $logfile
set backlog = `$tst_awk '/backlog number of transactions/ {if ($1 ~ /^[0-9]+$/) print $1}' $logfile`
echo $backlog
