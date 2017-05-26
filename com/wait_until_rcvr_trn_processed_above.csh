#!/usr/local/bin/tcsh -f
# usage:
# $gtm_tst/com/wait_until_rcvr_trn_processed_above.csh [+]trn_number [timeout]
# trn_number : wait until the "last transaction processed by update process" exceeds this value
# optional + indicates wait untill trn_number more transactions are processed from the current transaction
# optional timeout is the max time to wait - Defaults to 600 seconds
# eg :
# $gtm_tst/com/wait_until_rcvr_trn_processed_above.csh 1000
# $gtm_tst/com/wait_until_rcvr_trn_processed_above.csh 2000 60
# $gtm_tst/com/wait_until_rcvr_trn_processed_above.csh +3000

set limit=$1
set isdelta = `echo $limit | cut -c 1`
if ("+" == "$isdelta") then
	# It means limit is not absolute value but increase from current value
	set limit = `echo $limit | cut -c 2-`
	set logfile = "rb_$$.log"
	$MUPIP replic -receiver -showbacklog >& $logfile
	set cur_trn = `$tst_awk '/last transaction processed by update process/ {print $1}' $logfile`
	@ limit = $cur_trn + $limit
endif
set timeout=$2
if ("" == "$timeout") set timeout=600
set sleepinc = 5

while ($timeout > 0)
	set logfile = "rb_$$_`date +%H%M%S`.log"
	$MUPIP replic -receiv -showbacklog >& $logfile
	set trn_processed = `$tst_awk '/last transaction processed by update process/ {print $1}' $logfile`
	if ($trn_processed >= $limit) exit 0
	sleep $sleepinc
	@ timeout = $timeout - $sleepinc
end
exit 1
