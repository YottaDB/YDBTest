#!/usr/local/bin/tcsh -f
#
# SRC.csh <replication flag> <portno> [time_stamp]
#               portno=unique number for each test
#
# Turn replication on and start source server
#
setenv filter_arg ""
if ($2 == "") then
	echo "Needs port number to start source server!"
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
if( (!($?tst_rf_log))||("$tst_rf_log" == "")) setenv tst_rf_log  "log"
if ("$tst_rf_log" == "nolog") then
        setenv SRC_LOG_FILE "/dev/null"
else
	if ($?SRC_LOG_FILE == 0) then 
		setenv SRC_LOG_FILE "$PRI_SIDE/SRC_${time_stamp}.log"
	endif
endif
#
setenv repl_state "$1"
# This section is meant for multisite_replic tests.
# MSR tests will call replication scripts with "decide" sometimes to let the script decide about the replication state
# this will NOT affect any regular dual site test
if ( "decide" == $1 ) then
	set cur_state=`$DSE dump -fileheader|& $tst_awk '/Replication State/ {print $3}'`
	if ( "ON" == $cur_state ) then
		setenv repl_state "off"
	else
		setenv repl_state "on"
	endif
endif
if ("on" == $repl_state) then
	cd $PRI_SIDE
	if !(-e mumps.repl)  $MUPIP replic -instance_create
	$gtm_tst/com/jnl_on.csh $test_jnldir -replic=on
	if ($gtm_test_repl_norepl == 1) then
		echo "$MUPIP set -replication=off -journal=disable -REG HREG"
		$MUPIP set -replication=off -journal=disable -REG HREG
	endif
endif
echo "Using port $portno"
echo "Running : $gtm_exe"
echo "Using Global Directory $gtmgbldir"
echo "Starting Active Source Server in Host: $HOST:r:r:r:r"
echo "In directory:`pwd`"
if($?gtm_tst_ext_filter_src) then
    setenv filter_arg "-filter=$gtm_tst_ext_filter_src"
endif
echo $MUPIP replic -source -start -buffsize=$tst_buffsize -secondary="$tst_now_secondary":"$portno" $filter_arg -log=$SRC_LOG_FILE
$MUPIP replic -source -start -buffsize=$tst_buffsize -secondary="$tst_now_secondary":"$portno" $filter_arg -log=$SRC_LOG_FILE
$MUPIP replicate -source -checkhealth
if ($status == 0) then
	echo "Active Source Server started"
else
	echo "Could not start Primary Source server!"
	exit 1
endif
