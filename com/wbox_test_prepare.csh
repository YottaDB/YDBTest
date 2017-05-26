# Framework script that is invoked by all tests which want to do white box tests 
#
# $1 = type of test needed (e.g. "CACHE_RECOVER" etc.)
# $2 = range of frequency of errors to be induced
# $3 = minimum frequency of errors
# $4 = file where error_frequency has to be written to (usually settings.csh)
#
# Actual error frequency = rand($2) + $3
#

@ error_frequency = `$gtm_exe/mumps -run rand $2`
@ error_frequency = $error_frequency + $3

# On AIX, keep the error frequency to at least 1000. A low error frequency causes updates to do cache recovery quite often thereby
# flooding the syslog with WCBLOCKED, DBCRERR and other cache recovery related messages. On AIX, calls to syslog are essentially
# forked off and AIX sometimes does not clean up things quickly causing the processes to become defunct. More details on this issue
# can be found in <GTM_6937_syslog_flooding_causes_defunct_procs_AIX>.
if ($?HOSTOS && ($HOSTOS == "AIX")) then
	if ($error_frequency < 1000) then
		@ error_frequency = 1000
	endif
endif

echo "# error_frequency = $error_frequency" >>&! $4

setenv gtm_white_box_test_case_enable 1		
setenv gtm_white_box_test_case_count  $error_frequency

switch($1)
	case "CACHE_RECOVER":
		# We want to randomly choose to trigger error in PHASE1 or PHASE2 of the commit.
		@ phase2choice = `$gtm_exe/mumps -run rand 2`
		echo "# phase2choice = $phase2choice" >>&! $4
		if ($phase2choice == 0) then
			# Trigger error in bt_put : WBTEST_BG_UPDATE_BTPUTNULL in wbox_test_init.h
			setenv gtm_white_box_test_case_number  4
		else
			# Trigger error in phase2 : WBTEST_BG_UPDATE_PHASE2FAIL in wbox_test_init.h
			setenv gtm_white_box_test_case_number 15
		endif
		breaksw;
	case "REPL_HEARTBEAT_NO_ACK":
		# Trigger error in heartbeat acknowledgement logic : WBTEST_REPL_HEARTBEAT_NO_ACK in wbox_test_init.h
		setenv gtm_white_box_test_case_number 17
		breaksw;
	case "REPL_TEST_UNCMP_ERROR":
		# Trigger error in uncompression of REPL_MSG_TEST imessage : WBTEST_REPL_TEST_UNCMP_ERROR in wbox_test_init.h
		setenv gtm_white_box_test_case_number 18
		breaksw;
	case "REPL_TR_UNCMP_ERROR":
		# Trigger error in uncompression of REPL_TR_CMP_JNL_RECS imessage : WBTEST_REPL_TR_UNCMP_ERROR in wbox_test_init.h
		setenv gtm_white_box_test_case_number 19
		breaksw;
	case "TP_HIST_CDB_SC_BLKMOD":
		# Trigger cdb_sc_blkmod error in tp_hist : WBTEST_TP_HIST_CDB_SC_BLKMOD in wbox_test_init.h
		setenv gtm_white_box_test_case_number 20
		breaksw;
	default:
		echo "WBOX_TEST_PREPARE-E-INVALIDTYPE : $1 is not a valid type"
		breaksw;
endsw
# log the randomly set env.variables in the log
cat >> $4 << EOF
setenv gtm_white_box_test_case_enable $gtm_white_box_test_case_enable
setenv gtm_white_box_test_case_count $gtm_white_box_test_case_count
setenv gtm_white_box_test_case_number $gtm_white_box_test_case_number
EOF
