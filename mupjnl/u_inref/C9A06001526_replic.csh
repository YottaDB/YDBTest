#!/usr/local/bin/tcsh -f
#

setenv gtm_white_box_test_case_number 43
setenv gtm_white_box_test_case_count 1

setenv gtmgbldir "mumps.gld"

@ rand = `$gtm_exe/mumps -run rand 2`
if ($rand) then
	setenv gtm_error_on_jnl_file_lost "1"
	set expected_jnl_state = "ON"
else
	set expected_jnl_state = "OFF"
endif

echo "Testing that replic related callers of jnl_ensure_open() handle non-return success"
echo "On error, journaling should be $expected_jnl_state"

echo "Testing for sr_port/mur_output_record.c"
# before journaling is required
setenv tst_jnl_str -journal=enable,on,before
setenv gtm_tst_ext_filter_rcvr "$gtm_exe/mumps -run ^jrtnullfilter"
$gtm_tst/com/dbcreate.csh mumps
$sec_shell '$sec_getenv ; cd $SEC_SIDE ; $gtm_tst/com/abs_time.csh time1'
sleep 1
$gtm_exe/mumps -run %XCMD 'set ^a=1'
$gtm_tst/com/RF_SHUT.csh
$sec_shell '$sec_getenv ; cd $SEC_SIDE ; set time1 = `cat time1_abs` ; setenv gtm_white_box_test_case_count 2 ; setenv gtm_white_box_test_case_enable 1 ; $MUPIP journal -recover -backward -since=\"$time1\" mumps.mjl'
unsetenv gtm_tst_ext_filter_rcvr

echo "Testing for sr_port/updproc.c"
set old_sec_getenv="$sec_getenv"
setenv sec_getenv "$old_sec_getenv; setenv gtm_white_box_test_case_count 1 ; setenv gtm_white_box_test_case_enable 1"
$gtm_tst/com/RF_START.csh
$gtm_exe/mumps -run %XCMD 'set ^a=1'
setenv sec_getenv "$old_sec_getenv; setenv gtm_white_box_test_case_enable 1; setenv gtm_white_box_test_case_number 23"
$gtm_tst/com/RF_SHUT.csh
setenv sec_getenv "$old_sec_getenv"

echo "Testing for sr_port/gtmsource_ctl_init.c"
$gtm_tst/com/dbcreate.csh mumps -buffsize=1
$GTM << EOF
for i=1:1:100 set ^a=i
zsystem "$MUPIP replic -source -instsecondary=$gtm_test_cur_sec_name -shutdown -timeout=0"
for i=1:1:150000 set ^a=i
EOF
set start_time=`date +%H_%M_%S`
set portno = `cat $SEC_DIR/portno`
setenv gtm_white_box_test_case_enable 1
$MUPIP replic -source -start -buffsize=1 -instsecondary=$gtm_test_cur_sec_name -secondary="$tst_now_secondary":"$portno" -log="$PRI_SIDE/SRC_${start_time}.log"
$gtm_tst/com/wait_for_log.csh -log "$PRI_SIDE/SRC_${start_time}.log" -message "GTM-E-JNLFILOPN" -duration 60
$gtm_tst/com/wait_for_log.csh -log "$PRI_SIDE/SRC_${start_time}.log" -message "Source server exiting" -duration 60
setenv gtm_white_box_test_case_number 23
unsetenv gtm_white_box_test_case_count
$DSE dump -fileheader |& $grep -E "Journal State" | $grep -v "$expected_jnl_state"
unsetenv gtm_white_box_test_case_enable
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replic -receiv -shutdown -timeout=0 ; $MUPIP replic -source -shutdown -timeout=0" >&! secondary_shut.out
$gtm_tst/com/dbcheck.csh
setenv loglist "SRC*.log SHUT*.out RCVR*.log.updproc rf_sync*.out src_*.log rcvr_*.log"
$grep GTM-E-JNLFILOPN $loglist | sort -u
tar -cf repliclogs.tar $loglist
rm -f $loglist
$sec_shell '$sec_getenv ; cd $SEC_SIDE ; $grep GTM-E-JNLFILOPN $loglist | sort -u; tar -cf repliclogs.tar $loglist passive*.log ; rm -f $loglist passive*.log'
