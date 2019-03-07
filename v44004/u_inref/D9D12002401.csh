#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2004-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# D9D12-002401 sync_io characteristics do not get preserved across MUPIP SET JOURNAL commands
#
# Journaling is turned on explicitly in this test. So let's not randomly enable it in dbcreate.csh
setenv gtm_test_jnl NON_SETJNL
$gtm_tst/com/dbcreate.csh mumps 6
#
# in order to test thoroughly, we set a multi-region database alternately to
#	-journal=disable
#	-journal=enable,off,before
#	-journal=enable,on,before,nosync_io
#	-journal=enable,on,before,sync_io
#	-journal=enable,on,before,nosync_io -replication=on
#	-journal=enable,on,before,sync_io -replication=on
#
if ("BG" == $acc_meth) then
	set tstacc = "before"
else
	set tstacc = "nobefore"
endif
$MUPIP set -journal="disable" -region AREG
$MUPIP set -journal="enable,off,$tstacc" -region BREG
$MUPIP set -journal="enable,on,$tstacc,nosync_io" -region CREG >&! jnl_on_1.logx
$grep -v "YDB-I-JNLCREATE" jnl_on_1.logx
$MUPIP set -journal="enable,on,$tstacc,sync_io" -region DEFAULT >&! jnl_on_2.logx
$grep -v "YDB-I-JNLCREATE" jnl_on_2.logx
$MUPIP set -journal="enable,on,$tstacc,nosync_io" -replication="on" -region DREG >&! jnl_on_3.logx
$grep -v "YDB-I-JNLCREATE" jnl_on_3.logx
$MUPIP set -journal="enable,on,$tstacc,sync_io" -replication="on" -region EREG >&! jnl_on_4.logx
$grep -v "YDB-I-JNLCREATE" jnl_on_4.logx

mkdir savedir
cp -f *.dat *.mjl* savedir

@ count = 0

foreach sync_io ("" ",nosync_io" ",sync_io")
	mkdir savedir_$count
	mv *.dat *.mjl* savedir_$count
	if (-e dse_df.log) mv dse_df.log savedir_$count	# created by get_dse_df.csh of previous iteration
	cp -f savedir/* .
	@ count = $count + 1

	echo ""
	echo "---------- Enable journaling with $sync_io -----------"
	# the command is hard-coded in two lines, one for echoing and one for executing.
	# this is done instead of "set echo" and "unset echo" surrounding the command execution line.
	# this is because it seems like the order in which the commands get echoed is not guaranteed when pipelines are involved.
	# we had a test failure in lespaul (AIX) where "sort -f" got echoed ahead of the MUPIP set
	# hence the decision to explicitly echo what we want even if it means duplicating the command line.
	$MUPIP set -journal="on,$tstacc$sync_io" -region "*"  >&! jnl_on_5${sync_io}.logx
	$grep -v "YDB-I-JNLCREATE" jnl_on_5${sync_io}.logx |& sort -f
	$gtm_tst/com/get_dse_df.csh
	$grep -E "Region          |Journal State|Journal Sync IO" dse_df.log | sed 's/\(Journal Before imaging\).*/\1##FILTERED##/'
end

$gtm_tst/com/dbcheck.csh
