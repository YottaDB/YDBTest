#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# the script triggers an online backup and most importantly carries the PPID of the process that trigerrs it
# this PPID will be useful to MUPIP stop the backup half way down the line in the test
#
echo "PID  ""$$" >& mu_bkup_parent.pid
# to avoid output from bg process exits in the reference file we need to push the mupip online backup to a new shell and then
# trigerr it in background.
# to identify the right process we suffix here the ppid to the dir name and match that in our ps output
mkdir $$"_online1"
if ($?bkgrnd_bkup_ts) then
	set bkgrnd_bkup_out_filter='|& $tst_awk '"'"'{print $0 ; print strftime(),$0 >> "online1_ts.out" ; fflush() ; fflush("online1_ts.out")}'"'"
else
	set bkgrnd_bkup_out_filter=""
endif
(set echo verbose ; eval '$MUPIP backup -online $* "*" ./$$"_online1" '"$bkgrnd_bkup_out_filter"' >&! online1.out &') >&! bgg.out
#
