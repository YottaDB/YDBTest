#!/usr/local/bin/tcsh -f
#
setenv test_sleep_sec 10
#
$gtm_tst/com/dbcreate.csh mumps
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
# part A
# test the fix to the problem where after REPL_WILL_RESTART, Tr sent is negative, which is meaningless
#
$MUPIP replic -source -statslog=on -instsecondary=$gtm_test_cur_sec_name
echo "Starting sending data"
$GTM << aaa
  f i=1:1:6000 s ^a(i)="a"_i
aaa
# wait for 5 minute to kick off the statistics
echo "Waiting for 5 minutes ..."
sleep 320
$GTM << kick
  s ^k="k1"
kick
#
sleep $test_sleep_sec
# shutdown and restart receiver server
setenv start_time `date +%H_%M_%S`
echo "Shuting down receiver server"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null "">>&!"" $SEC_SIDE/SHUT_${start_time}.out"
sleep $test_sleep_sec
echo "Restarting receiver server"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh ""on"" $portno $start_time < /dev/null "">&!"" $SEC_SIDE/RCVR_${start_time}.out"
#
echo "waiting 5 minutes and sending more data"
sleep 335
$GTM << bbb
   s ^b(1)="b1"
bbb
sleep $test_sleep_sec
#
echo "Check Tr sent number "
$grep "Tr sent" SRC*.log
#
$gtm_tst/com/dbcheck.csh -extra
