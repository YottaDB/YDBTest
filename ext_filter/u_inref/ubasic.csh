#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
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
$gtm_tst/com/dbcheck.csh -extract

# Now that the replication servers (and backgrounded filter programs writing to log.extout) have been shut down,
# verify the log.extout contents.
echo "Verifying log file:"
# Filter volatile fields in journal records like checksum, timestamp and nodeflags
# (different between trigger supporting and trigger non-supporting platforms)
check_mjf log.extout

