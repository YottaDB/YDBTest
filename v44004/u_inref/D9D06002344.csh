#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2004-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# D9D06-002344 -newjnlfiles=sync_io option with mupip backup
#
# the output of this test relies on transaction numbers, so let's not do anything that might change the TN
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
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
$MUPIP set -journal="enable,on,$tstacc,nosync_io" -region CREG >&! jnl_on_1.log
$grep -v "YDB-I-JNLCREATE" jnl_on_1.log
$MUPIP set -journal="enable,on,$tstacc,sync_io" -region DEFAULT >&! jnl_on_2.log
$grep -v "YDB-I-JNLCREATE" jnl_on_2.log
$MUPIP set -journal="enable,on,$tstacc,nosync_io" -replication="on" -region DREG >&! jnl_on_3.log
$grep -v "YDB-I-JNLCREATE" jnl_on_3.log
$MUPIP set -journal="enable,on,$tstacc,sync_io" -replication="on" -region EREG >&! jnl_on_4.log
$grep -v "YDB-I-JNLCREATE" jnl_on_4.log

mkdir savedir
cp *.dat *.mjl* savedir

mkdir backupdir
@ count = 0

foreach sync_io ("" ",nosync_io" ",sync_io")
	mkdir savedir_$count
	mv *.dat *.mjl* backupdir savedir_$count
	if (-e dse_df.log) mv dse_df.log savedir_$count	# created by get_dse_df.csh of previous iteration
	cp savedir/* .
	mkdir backupdir
	@ count = $count + 1

	echo ""
	echo "---------- With -newjnlfiles=prevlink$sync_io -----------"
	# the command is hard-coded in two lines, one for echoing and one for executing.
	# this is done instead of "set echo" and "unset echo" surrounding the command execution line.
	# this is because it seems like the order in which the commands get echoed is not guaranteed when pipelines are involved.
	# we had a test failure in lespaul (AIX) where "sort -f" got echoed ahead of the MUPIP BACKUP
	# hence the decision to explicitly echo what we want even if it means duplicating the command line.
	echo "$MUPIP backup -newjnlfiles=prevlink$sync_io * backupdir |& sort -f"
	$MUPIP backup -newjnlfiles=prevlink$sync_io "*" backupdir >&! jnl_on_5_${sync_io}.log
	$grep -v "YDB-I-JNLCREATE" jnl_on_5_${sync_io}.log |& sort -f
	$gtm_tst/com/get_dse_df.csh
	$grep -E "Region          |Journal State|Journal Sync IO" dse_df.log | sed 's/\(Journal Before imaging\).*/\1##FILTERED##/'
end

$gtm_tst/com/dbcheck.csh
