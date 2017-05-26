#!/usr/local/bin/tcsh -f
#
echo "External Filter test with changes on receiver side"
# this test has jnl extract output, so let's not change the tn
setenv gtm_test_disable_randomdbtn
setenv gtm_test_mupip_set_version "disable"
setenv gtm_tst_ext_filter_rcvr "$gtm_exe/mumps -run ^multifilter"
$gtm_tst/com/dbcreate.csh mumps 1
# extract.awk is used to check external filter log in the receiver side. The stream seqno will be "0" for non-suppl instance and non-zero for suppl instance
set strm_seqno_zero = "TRUE"
if ((1 == $test_replic) && (2 == $test_replic_suppl_type)) then
	set strm_seqno_zero = "FALSE"
endif
alias check_mjf '$tst_awk -f $gtm_tst/mupjnl/inref/extract.awk -v "user=$USER" -v "host=$HOST:r:r:r" '"-v strm_seqno_zero=$strm_seqno_zero" ' \!:*'
#
$GTM<<EOF
set ^abc0="1234"
set ^abc="1234"
set ^abc2="1234"
set ^abc3="1234"
set ^abc4="1234"
set ^abc5="1234"
tstart
set ^def="3456"
set ^ghi="4567"
tcommit
set ^aaa="5555"
tstart
set ^tr1="6666"
tcommit
tstart
set ^tr1a="6666"
tcommit
set ^nontr1="7777"
tstart
set ^tr2="8888"
tcommit
tstart
set ^tr3="8899"
tcommit
tstart
set ^tr4="AAAA"
tcommit
set ^nontr2="9999"
tstart
set ^tr5="9900"
tcommit
set ^nontr3="0011"
tstart
set ^tr6="0000"
tcommit
tstart
set ^n1="3456"
set ^n2="4567"
set ^n3="4567"
tcommit
EOF
#
echo "Expect DATABASE EXTRACT to fail due to multifilter changes on receiver side"
$gtm_tst/com/dbcheck.csh -extract
echo
echo "log.extout from secondary:"
check_mjf $SEC_DIR/log.extout
echo
echo "Globals on secondary after multifilter:"
cat sec*.glo
