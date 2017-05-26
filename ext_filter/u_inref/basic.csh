#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# extract.awk is used to check external filter log in the source side. The stream seqno will be "0" for non-suppl instance and non-zero for suppl instance
set strm_seqno_zero = "TRUE"
if ((1 == $test_replic) && (2 == $test_replic_suppl_type)) then
	set strm_seqno_zero = "FALSE"
endif
alias check_mjf '$tst_awk -f $gtm_tst/mupjnl/inref/extract.awk -v "user=$USER" -v "host=$HOST:r:r:r" '"-v strm_seqno_zero=$strm_seqno_zero" ' \!:*'

echo "External Filter test"
# this test has jnl extract output, so let's not change the tn
setenv gtm_test_disable_randomdbtn
setenv gtm_test_mupip_set_version "disable"
setenv gtm_tst_ext_filter_src "$gtm_exe/mumps -run ^extfilter"
setenv gtm_tst_ext_filter_rcvr "$gtm_exe/mumps -run ^extfilter"
$gtm_tst/com/dbcreate.csh mumps 1 -stdnull -null_subscripts=TRUE
#
$GTM<<EOF
d ^jnlrec2
EOF
#
echo "Verifying log file:"
$gtm_tst/com/RF_sync.csh
check_mjf log.extout

# [GTM-7854] Replication filters (aka external filters) dont work with null subscripts if std_null_coll is TRUE
echo "# Test case for GTM-7854 : Check external filters work with null subscripts & stdnullcoll"

echo '# set ^a("")=1'
$gtm_exe/mumps -run %XCMD 'set ^a("")=1'

echo "# zwrite ^a on the primary side"
$gtm_exe/mumps -run %XCMD 'zwrite ^a'

echo "# zwrite ^a on the secondary side"
$gtm_tst/com/RF_sync.csh
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_exe/mumps -run %XCMD 'zwrite ^a'"
#
$gtm_tst/com/dbcheck.csh -extract
