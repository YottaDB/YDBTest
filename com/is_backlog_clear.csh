#!/usr/local/bin/tcsh -f
#
# check if the backlog is cleared.
#
# Exits with normal status   i.e. 0 if backlog is cleared
# Exits with abnormal status i.e. 1 if backlog is not cleared
#
if (! $?gtm_test_instsecondary ) then
	setenv gtm_test_instsecondary "-instsecondary=$gtm_test_cur_sec_name"
endif
set logfile = "$1"
if ("" == $logfile) set logfile = "sb_$$_`date +%H%M%S`.log"
$MUPIP replic -source $gtm_test_instsecondary -showbacklog >& $logfile
set backlog=`$grep "backlog" $logfile | $tst_awk '{print $1}'`
if ($backlog > 0) then
  exit 1
else
  exit 0
endif
