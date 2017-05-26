#!/usr/local/bin/tcsh -f
#
# check if the receiver backlog is cleared.
#
# Exits with normal status   i.e. 0 if backlog is cleared
# Exits with abnormal status i.e. 1 if backlog is not cleared
#
set logfile = "$1"
if ("" == $logfile) set logfile = "rb_$$_`date +%H%M%S`.log"
$MUPIP replic -receiv -showbacklog >& $logfile
set backlog=`$grep "backlog" $logfile | $tst_awk '{print $1}'`
if ($backlog > 0) then
  exit 1
else
  exit 0
endif
