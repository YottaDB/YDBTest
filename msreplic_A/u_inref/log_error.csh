#!/usr/local/bin/tcsh -f
# Test:
# This is to test what happens when the specified log files are not available for various replicate operations
# We need three instances.

# Layout:
# INST1 --> INST2 --> INST3
$MULTISITE_REPLIC_PREPARE 3
$gtm_tst/com/dbcreate.csh . 1

$MSR START INST1 INST2 RP
$MSR START INST2 INST3 PP
$MSR SYNC ALL_LINKS
$MSR STOP ALL_LINKS

## ## multisite_replic/log_error --

## prepare replication for 3 servers:

cat << EOF
## Tests replication log failure for various replication operations
##   \$MULTISITE_REPLIC_PREPARE 3
##   INST1 --> INST2 --> INST3
EOF
alias knownerror 'mv \!:1 {\!:1}x ; $grep -vE "\!:2" {\!:1}x >&! \!:1 '

echo " "
$echoline
echo "Test 1-5: Test for source (active and passive) and receiver starts"
$echoline

echo " "
echo "# Test 1: The INST1 starts active source server with unwritable log file "
$echoline
echo "# Attempt 1: to start source server for INST1 with a general log, but the directory containing the log file does not exist"
setenv tmp_portno `$MSR RUN INST2 'set msr_dont_trace;source $gtm_tst/com/portno_acquire.csh'`
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -source -start -log=test/gen_source1.log -secondary=__RCV_HOST__:$tmp_portno -buff=$tst_buffsize -instsecondary=__RCV_INSTNAME__' >& src_log_dir_not_exist1.out
echo "#         --> We expect a REPLLOGOPN error"
$gtm_tst/com/check_error_exist.csh src_log_dir_not_exist1.out REPLLOGOPN
knownerror $msr_execute_last_out REPLLOGOPN

echo "# Attempt 2: to start source server for INST1 with a log, but the directory containing the log file is not writable"
$MSR RUN INST1 'mkdir test1; chmod =r test1'
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -source -start -log=test1/gen_source1.log -secondary=__RCV_HOST__:$tmp_portno -buff=$tst_buffsize -inst=__RCV_INSTNAME__' >& src_log_dir_unwritable1.out
echo "#         --> We expect a REPLLOGOPN error"
$gtm_tst/com/check_error_exist.csh src_log_dir_unwritable1.out REPLLOGOPN
knownerror $msr_execute_last_out REPLLOGOPN

echo "# Attempt 3: to start source server for INST1 with a log not accessible"
$MSR RUN INST1 'touch mumps.dat.log; chmod og-rwx mumps.dat.log; $gtm_com/IGS mumps.dat.log CHOWN gtmtest1 gtc'
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -source -start -log=mumps.dat.log -secondary=__RCV_HOST__:$tmp_portno -buff=$tst_buffsize -inst=__RCV_INSTNAME__' >& src_log_unwritable1.out
echo "#         --> We expect a REPLLOGOPN error"
$gtm_tst/com/check_error_exist.csh src_log_unwritable1.out REPLLOGOPN
knownerror $msr_execute_last_out REPLLOGOPN
echo "============Test1 ends=========="

echo " "
echo "# Test 2: The INST1 starts active source server with writable log file"
$echoline
echo "# Attemp to start an active source server with writable log file. Expect no failure"
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -source -start -log=gen_source2.log -secondary=__RCV_HOST__:$tmp_portno -buff=$tst_buffsize -inst=__RCV_INSTNAME__ -root' >& normal_activity.out
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -source -checkhealth -inst=__RCV_INSTNAME__' >>& normal_activity.out
echo "============Test2 ends=========="

echo " "
echo "# Test 3: The INST2 starts passive source server with unwritable log file"
$echoline
echo "# Attempt 1: to start passive server for INST2, but the directory containing the log file does not exist"
$MSR RUN SRC=INST2 RCV=INST3 'set msr_dont_chk_stat; $MUPIP replic -source -start -passive -log=test/passive3.log -inst=__RCV_INSTNAME__ -root' >&src_log_dir_not_exist3.out
echo "#  	--> We expect a REPLLOGOPN error"
$gtm_tst/com/check_error_exist.csh src_log_dir_not_exist3.out REPLLOGOPN
knownerror $msr_execute_last_out REPLLOGOPN

echo "# Attempt 2: to start passive server for INST2, but the directory containing the log file is not writable"
$MSR RUN INST2 ' mkdir test2; chmod =r test2'
$MSR RUN SRC=INST2 RCV=INST3 'set msr_dont_chk_stat; $MUPIP replic -source -start -passive -log=test2/passive3.log -inst=__RCV_INSTNAME__ -root' >&src_log_dir_unwritable3.out
echo "#         --> We expect a REPLLOGOPN error"
$gtm_tst/com/check_error_exist.csh src_log_dir_unwritable3.out REPLLOGOPN
knownerror $msr_execute_last_out REPLLOGOPN

echo "# Attempt 3: to start passive server for INST2 with a log not accessible"
$MSR RUN INST2 'touch mumps.dat.log; chmod og-rwx mumps.dat.log; $gtm_com/IGS mumps.dat.log CHOWN gtmtest1 gtc'
$MSR RUN SRC=INST2 RCV=INST3 'set msr_dont_chk_stat; $MUPIP replic -source -start -passive -log=mumps.dat.log -inst=__RCV_INSTNAME__ -root' >&src_log_unwritable3.out
echo "#         --> We expect a REPLLOGOPN error"
$gtm_tst/com/check_error_exist.csh src_log_unwritable3.out REPLLOGOPN
knownerror $msr_execute_last_out REPLLOGOPN
echo "============Test3 ends=========="

echo " "
echo "# Test 4: The INST2 starts passive source server with writable log file"
$echoline
echo "#- Attempt to start passive source server of INST2 with writable log file. Expect no failure"
$MSR RUN SRC=INST2 RCV=INST3 'set msr_dont_chk_stat; $MUPIP replic -source -start -passive -log=passive4.log -inst=__RCV_INSTNAME__ -prop'  >>&normal_activity.out
$MSR RUN SRC=INST2 RCV=INST3 'set msr_dont_chk_stat; $MUPIP replic -source -checkhealth -inst=__RCV_INSTNAME__' >>&normal_activity.out
echo "============Test4 ends=========="


echo " "
echo "# Test 5: The INST2 starts the receiver server with unwritable log file"
$echoline
echo "#- Attempt 1: to start receiver server of INST2, but the directory containing the log file does not exist"
$MSR RUN RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -receiv -start -listen='$tmp_portno' -log=test/receiver.log -buf=$tst_buffsize'>&rcv_log_dir_not_exist5.out
echo "#         --> We expect a REPLLOGOPN error"
$gtm_tst/com/check_error_exist.csh rcv_log_dir_not_exist5.out REPLLOGOPN
knownerror $msr_execute_last_out REPLLOGOPN

echo "# Attempt 2: to start receiver server of INST2, but the directory containing the log file is not writable"
$MSR RUN RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -receiv -start -listen='$tmp_portno' -log=test2/receiver.log -buf=$tst_buffsize'>>&rcv_log_dir_unwritable5.out
echo "#         --> We expect a REPLLOGOPN error"
$gtm_tst/com/check_error_exist.csh rcv_log_dir_unwritable5.out REPLLOGOPN
knownerror $msr_execute_last_out REPLLOGOPN


echo "# Attempt 3: to start receiver server of INST2 with a log not accessible"
$MSR RUN RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -receiv -start -listen='$tmp_portno' -log=mumps.dat.log -buf=$tst_buffsize' >& rcv_log_unwritable5.out
echo "#         --> We expect a REPLLOGOPN error"
$gtm_tst/com/check_error_exist.csh rcv_log_unwritable5.out REPLLOGOPN
knownerror $msr_execute_last_out REPLLOGOPN
echo "============Test5 ends=========="


echo " "
$echoline
echo "Test 6-10: Test for activating, changing log"
echo "## which will affect the server process running background #####"
$echoline

echo " "
echo "# Test 6: Activate passive server of INST2 with logfile not writable"
echo "# Note: if there are other servers besides passive receiver running on INST2, they must be shut down first"
$echoline
setenv tmp_portno2 `$MSR RUN INST3 'set msr_dont_trace;source $gtm_tst/com/portno_acquire.csh'`
echo "#- Attempt 1: Directory containing the log file does not exist"
$MSR RUN SRC=INST2 RCV=INST3 'set msr_dont_chk_stat; $MUPIP replic -source -activate -secondary=__RCV_HOST__:'$tmp_portno2' -log=test/activate.log -inst=__RCV_INSTNAME__ -propagate' >& src_activ_log_dir_not_exist6.out
echo "#         --> We expect a REPLLOGOPN error"
$gtm_tst/com/check_error_exist.csh src_activ_log_dir_not_exist6.out REPLLOGOPN
knownerror $msr_execute_last_out REPLLOGOPN

echo "# Attempt 2: Directory containing the log file is not writable"
$MSR RUN SRC=INST2 RCV=INST3 'set msr_dont_chk_stat; $MUPIP replic -source -activate -secondary=__RCV_HOST__:'$tmp_portno2' -log=test2/activate.log -inst=__RCV_INSTNAME__ -propagate' >& src_activ_log_dir_unwritable6.out
echo "#         --> We expect a REPLLOGOPN error"
$gtm_tst/com/check_error_exist.csh src_activ_log_dir_unwritable6.out REPLLOGOPN
knownerror $msr_execute_last_out REPLLOGOPN

echo "# Attempt 3: The log is not accessible"
$MSR RUN SRC=INST2 RCV=INST3 'set msr_dont_chk_stat; $MUPIP replic -source -activate -secondary=__RCV_HOST__:'$tmp_portno2' -log=mumps.dat.log -inst=__RCV_INSTNAME__ -propagate' >& src_activ_log_unwritable6.out
echo "#         --> We expect a REPLLOGOPN error"
$gtm_tst/com/check_error_exist.csh src_activ_log_unwritable6.out REPLLOGOPN
knownerror $msr_execute_last_out REPLLOGOPN


echo "#Now activate passive server of INST2 with writable log file. Expect no failure"
$MSR RUN SRC=INST2 RCV=INST3 'set msr_dont_chk_stat; $MUPIP replic -source -activate -secondary=__RCV_HOST__:'$tmp_portno2' -log=activate.log -inst=__RCV_INSTNAME__ -prop' >& src_activ_log.out
$MSR RUN SRC=INST2 RCV=INST3 'set msr_dont_chk_stat; $MUPIP replic -source -deactivate -instsecondary=__RCV_INSTNAME__ -prop' >>& src_activ_log.out
echo "============Test6 ends=========="

echo " "
echo "# Test 7: Turn on the detailed logging on source server"
echo "# This test is removed for gtm-7296 change"
echo "============Test7 ends=========="

echo " "
echo "# Test 8: INST2 turns on the detailed logging on receiver server"
echo "# This test is removed for gtm-7296 change"
echo "============Test8 ends=========="



echo " "
echo "# Test 9: INST1 changes its log on the source server"
$echoline
echo "#- Attempt 1: The directory containing the log file does not exist"
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -source -changelog -log=test/source_new.log -inst=__RCV_INSTNAME__'>& src_chang_log_dir_not_exist9.out

echo "#         --> We expect a REPLLOGOPN error "
$gtm_tst/com/check_error_exist.csh src_chang_log_dir_not_exist9.out REPLLOGOPN
knownerror $msr_execute_last_out REPLLOGOPN

echo "# Attempt 2: Directory containing the log file is not writable"
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -source -changelog -log=test1/source_new.log -inst=__RCV_INSTNAME__'>& src_chang_log_dir_unwritable9.out
echo "#         --> We expect a REPLLOGOPN error"
$gtm_tst/com/check_error_exist.csh src_chang_log_dir_unwritable9.out REPLLOGOPN
knownerror $msr_execute_last_out REPLLOGOPN

echo "# Attempt 3: New log not accessible"
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -source -changelog -log=mumps.dat.log -inst=__RCV_INSTNAME__'>& src_chang_log_unwritable9.out
echo "#         --> We expect a REPLLOGOPN error"
$gtm_tst/com/check_error_exist.csh src_chang_log_unwritable9.out REPLLOGOPN
knownerror $msr_execute_last_out REPLLOGOPN

echo " "
echo "#Now change the log to a writable log. Expect no failure"
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -source -changelog -log=source_new.log -inst=__RCV_INSTNAME__'>& src_chang_log9.out
echo "src_chang_log9.out:"; cat src_chang_log9.out
echo "============Test9 ends=========="

echo " "
echo "# Test 10: INST2 changes its log on the receiver server"
$echoline
$MSR RUN RCV=INST2 '$MUPIP replic -receiv -start -listen='$tmp_portno' -log=gen_receiver.log -buf=$tst_buffsize' >>& normal_activity.out
$MSR RUN RCV=INST2 '$MUPIP replic -receiv -checkhealth' >>& normal_activity.out
echo "#- Attempt 1: The directory containing the log file does not exist"
$MSR RUN RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -receiv -changelog -log=test/receiver_new.log'>& rcv_chang_log_dir_not_exist10.out
echo "#         --> We expect a REPLLOGOPN error "
$gtm_tst/com/check_error_exist.csh rcv_chang_log_dir_not_exist10.out REPLLOGOPN
knownerror $msr_execute_last_out REPLLOGOPN

echo "# Attempt 2: Directory containing the log file is not writable"
$MSR RUN RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -receiv -changelog -log=test2/receiver_new.log'>& rcv_chang_log_dir_unwritable10.out
echo "#         --> We expect a REPLLOGOPN error"
$gtm_tst/com/check_error_exist.csh rcv_chang_log_dir_unwritable10.out REPLLOGOPN
knownerror $msr_execute_last_out REPLLOGOPN

echo "# Attempt 3: New log not accessible"
$MSR RUN RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -receiv -changelog -log=mumps.dat.log'>& rcv_chang_log_unwritable10.out
echo "#         --> We expect a REPLLOGOPN error"
$gtm_tst/com/check_error_exist.csh rcv_chang_log_unwritable10.out REPLLOGOPN
knownerror $msr_execute_last_out REPLLOGOPN

echo " "
echo "# Now change the log to a writable log. Expect no failure"
$MSR RUN RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -receiv -changelog -log=receiver_new.log'>& rcv_chang_log10.out
echo "rcv_chang_log10.out:"; cat rcv_chang_log10.out
echo "============Test10 ends=========="

$MSR RUN SRC=INST1 'chmod =rwx test1'  >>&normal_activity.out
$MSR RUN INST1 '$gtm_com/IGS mumps.dat.log CHOWN $USER gtc; chmod og+rwx mumps.dat.log' >>&normal_activity.out
$MSR RUN SRC=INST2 'chmod =rwx test2' >>&normal_activity.out
$MSR RUN INST2 '$gtm_com/IGS mumps.dat.log CHOWN $USER gtc; chmod og+rwx mumps.dat.log' >>&normal_activity.out

$MSR RUN RCV=INST2 '$MUPIP replic -receiv -shut -time=0' >>&normal_activity.out
$MSR RUN SRC=INST1 RCV=INST2 '$MUPIP replic -source -shut -inst=__RCV_INSTNAME__ -time=0' >>&normal_activity.out
$MSR RUN SRC=INST2 RCV=INST3 '$MUPIP replic -source -shut -inst=__RCV_INSTNAME__ -time=0' >>&normal_activity.out
$MSR RUN RCV=INST2 SRC=INST1 "set msr_dont_trace ; $gtm_tst/com/portno_release.csh $tmp_portno"
$MSR RUN RCV=INST3 SRC=INST2 "set msr_dont_trace ; $gtm_tst/com/portno_release.csh $tmp_portno2"
$gtm_tst/com/dbcheck.csh
#==================================================================================================================================
