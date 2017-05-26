#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

echo "------------------------------------------------------------------------------------------------------------"
echo "Test 1 : Source server sends transactions in timely fashion when reading from journal files after a rollback"
echo "------------------------------------------------------------------------------------------------------------"
echo "--> Set jnlpool buffer size of 1Mb"
setenv gtm_test_jnlpool_buffsize 1000000 # Set small jnlpool size (1Mb) to ensure source server reads first seqno from files
setenv gtm_test_spanreg     0		# Test requires traditional global mappings, so disable spanning regions
echo "--> Set alignsize of 8Mb"
setenv test_align 16384			# Set 8Mb alignsize
set tstjnlstr = `echo $tst_jnl_str | sed 's/align=[1-9][0-9]*/align='$test_align'/'`
setenv tst_jnl_str $tstjnlstr
$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps 3 -record_size=20000
$MSR START INST1 INST2 RP
get_msrtime
$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/com/wait_for_log.csh -log RCVR_${time_msr}.log -message 'New History Content'"
$MSR STOPRCV INST1 INST2
#
echo "--> Do updates that fill up the journal pool"
$gtm_dist/mumps -run test1^gtm8118
#
echo "--> Stop source server to adjust region sequence numbers in db file header (simulates the effect of a rollback)"
$MSR STOPSRC INST1 INST2
#
echo "--> Find Region Seqno of B.DAT"
$DSE >& breg_dse_df.log << DSE_EOF
	find -reg=BREG
	dump -file
DSE_EOF
echo ""
set bregseqno = `$tst_awk '/Region Seqno/ {gsub("0x0*","") ; print $NF}' breg_dse_df.log`
echo "--> BREG Region Seqno = $bregseqno"
#
echo "--> Adjust region sequence numbers of AREG and DEFAULT to be the same as BREG"
$DSE << DSE_EOF
	change -file -reg_seqno=$bregseqno
	find -reg=DEFAULT
	change -file -reg_seqno=$bregseqno
DSE_EOF
echo ""
#
echo "--> Restart source server"
$MSR STARTSRC INST1 INST2
echo "--> Start receiver server"
$MSR STARTRCV INST1 INST2
#
echo "--> Check that source server has sent all data without issues"
echo "--> Expect backlog progress every 30 seconds instead of the test framework default (which could be order of minutes)"
setenv gtm_tst_rfsync_check_frequency 30
# Note that .dat and .repl files are still accessed by the source and receiver server so a mupip rundown -reg * will issue a
# MUNOTALLSEC warning if invoked. So pass -noleftoveripccheck so dbcheck_base does not invoke leftover_ipc_cleanup_if_needed.csh
$gtm_tst/com/dbcheck.csh -extract -noshut -noleftoveripccheck

echo "-------------------------------------------------------------------------------------------------------------------------"
echo "Test 2 : Source server reads correctly from journal files even if concurrent jnl switch happens while it is in first_read"
echo "-------------------------------------------------------------------------------------------------------------------------"
echo "--> Set alignsize of 2Mb and autoswitchlimit of 8Mb"
echo "--> This causes source server to invoke <repl_read_file> of first 2Mb inside <first_read> function"
echo "-->      as well as invoke <repl_read_file> of last 2Mb (of 8Mb) at end of <first_read> as part of <update_max_seqno_info>"
echo "--> We hope to do the concurrent jnl switch while it is in the second <repl_read_file> call"
echo "--> This tests a regression in the code that happened as part of the first round of GTM-8118 fixes"
setenv test_align 4096			# Set 2Mb alignsize
set tstjnlstr = `echo $tst_jnl_str | sed 's/align=[1-9][0-9]*/align='$test_align'/'`
setenv tst_jnl_str "$tstjnlstr,auto=16384"
echo "--> Stop receiver server"
$MSR STOPRCV INST1 INST2
echo "--> Switch to new journal file with 8Mb autoswitchlimit and 2Mb alignsize"
$MUPIP set $tst_jnl_str -reg "*"|& sort -f 	# sort output to avoid output ordering issues (due to ftok) with multiple regions
echo "--> Do approximately 8Mb of updates to fill it"
$gtm_dist/mumps -run test2a^gtm8118
echo "--> Do some more updates in the background to cause autoswitch"
echo "--> Sleep randomly before switch to increase chances of catching source server in the second call to <repl_read_file>"
$gtm_dist/mumps -run test2b^gtm8118
echo "--> Start receiver server. Since jnlpool size is 1Mb, source server is now forced to read from journal file"
$MSR STARTRCV INST1 INST2
echo "--> Wait for backgrounded updates to finish"
$gtm_dist/mumps -run test2bwait^gtm8118
$gtm_tst/com/dbcheck.csh -extract
