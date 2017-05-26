#!/usr/local/bin/tcsh -f
#
# RCVR.csh <replication flag> <portno> [time_stamp]
# Start receiver server, Turn replication on/off 1st depending on <flag>
#
#
if ($2 == "") then
        echo "Needs port number to start receiver server!"
        exit 1
else
        set portno=$2
        echo "Using port $portno"
endif
if ($3 == "") then
        setenv time_stamp `date +%H_%M_%S`
else
        set time_stamp=$3
endif

#in case dbcreate.csh is used outside test suite, and tst_rf_log is undefined
if ((!($?tst_rf_log))||("$tst_rf_log" == "")) setenv tst_rf_log  "log"

if ("$tst_rf_log" == "nolog") then
	setenv RCVR_LOG_FILE "/dev/null"
	setenv PASSIVE_LOG_FILE "/dev/null"
	unsetenv LOG_UPDATES
else
	if ($?RCVR_LOG_FILE == 0) then
		setenv RCVR_LOG_FILE "$SEC_SIDE/RCVR_${time_stamp}.log"
	endif
	if ($?PASSIVE_LOG_FILE == 0) then
		setenv PASSIVE_LOG_FILE "$SEC_SIDE/passive_${time_stamp}.log"
	endif
	if ($?UPD_LOG_FILE == 0) then
		setenv UPD_LOG_FILE "$SEC_SIDE/UPDPROC_${time_stamp}.log"
	endif
endif
# This is mainly for debugging (define it in .cshrc)
if ($?tst_updproc == 1)  then
	if ($tst_updproc == "log") setenv LOG_UPDATES $UPD_LOG_FILE
endif
setenv repl_state "$1"
# This section is meant for multisite_replic actions to decide about replication state of the database
if ( "decide" == $1 ) then
	set cur_state=`$DSE dump -fileheader|& $tst_awk '/Replication State/ {print $3}'`
	if ( "ON" == $cur_state ) then
		setenv repl_state "already_on"
	else
		setenv repl_state "on"
	endif
endif
if ( "on" == $repl_state ) then
	echo "Turn replication on:"
	cd $SEC_SIDE
	if !(-e mumps.repl)  $MUPIP replic -instance_create
	$gtm_tst/com/jnl_on.csh $test_remote_jnldir -replic=on
	if ($gtm_test_repl_norepl == 1) then
		echo "$MUPIP set -replication=off -journal=disable -REG HREG"
		$MUPIP set -replication=off -journal=disable -REG HREG
	endif
endif
echo "Using port $portno"
echo "Running : $gtm_exe"
echo "Using Global Directory $gtmgbldir"
echo "Starting Passive Source Server and Receiver Server in Host: $HOST:r:r:r:r"
echo "In directory:`pwd`"
$MUPIP replic -source -start -buffsize=$tst_buffsize -passive -log=$PASSIVE_LOG_FILE
$MUPIP replicate -source -checkhealth
if ($status == 0) then
	echo "Passive Source Server have started"
else
	echo "Could not start Passive Source Server!"
        exit 1
endif
if ($4 != "") then
	echo "$MUPIP replic -receiv -start -buffsize=$tst_buffsize $4 -listenport=$portno -log=$RCVR_LOG_FILE"
	$MUPIP replic -receiv -start -buffsize=$tst_buffsize -$4 -listenport=$portno -log=$RCVR_LOG_FILE
else
	echo "$MUPIP replic -receiv -start -buffsize=$tst_buffsize -listenport=$portno -log=$RCVR_LOG_FILE"
	$MUPIP replic -receiv -start -buffsize=$tst_buffsize -listenport=$portno -log=$RCVR_LOG_FILE
endif
$MUPIP replicate -receiv -checkhealth
if ($status == 0) then
	echo "Receiver Server have started"
else
	echo "Could not start Receiver Server!"
        exit 1
endif
