#!/usr/local/bin/tcsh -f
#
# extract.awk is used to check external filter log in the source side. The stream seqno will be "0" for non-suppl instance and non-zero for suppl instance
set strm_seqno_zero = "TRUE"
if ((1 == $test_replic) && (2 == $test_replic_suppl_type)) then
	set strm_seqno_zero = "FALSE"
endif
alias check_mjf '$tst_awk -f $gtm_tst/mupjnl/inref/extract.awk -v "user=$USER" -v "host=$HOST:r:r:r" '"-v strm_seqno_zero=$strm_seqno_zero" ' \!:*'
$switch_chset UTF-8
echo "External Filter test"
# this test has jnl extract output, so let's not change the tn
setenv gtm_test_disable_randomdbtn
setenv gtm_test_mupip_set_version "disable"
setenv gtm_tst_ext_filter_src "$gtm_exe/mumps -run ^uextfilter"
setenv gtm_tst_ext_filter_rcvr "$gtm_exe/mumps -run ^uextfilter"
$gtm_tst/com/dbcreate.csh mumps 1
#
$GTM<<EOF
d ^unicodeJnlrec
h
EOF
#
echo "Verifying log file:"
sleep 5
# Filter volatile fields in journal records like checksum, timestamp and nodeflags (different between trigger supporting and 
# trigger non-supporting platforms)
check_mjf log.extout
#
$gtm_tst/com/dbcheck.csh -extract
