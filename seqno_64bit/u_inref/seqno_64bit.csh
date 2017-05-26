#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv test_jnlseqno 4G
$gtm_tst/com/dbcreate.csh load 3
setenv gtmgbldir load.gld
$GTM << xyz
do ^sfill("set",3,3)
do ^sfill("ver",3,3)
do ^sfill("kill",3,3)
xyz
# In the test plan formal inspection, Layek suggested to merge the test case
# for TR C9C12-002201 into this test - zhouc - 05/21/2003
# switch jornal file on primary side
# Before switching journal files make sure the backlog is clear on both pri and sec.
# This in turn, ensures the logging of only new transactions to the switched journals.
$gtm_tst/com/RF_sync.csh
$MUPIP set $tst_jnl_str -reg "*" >>& mup_set.log
# switch journal file on secondary side
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP set $tst_jnl_str -reg '*' >>& mup_set.log "
set format="%d-%b-%Y %H:%M:%S"
set time1=`date +"$format"`
echo $time1 >& time1.txt
$GTM << bbb
  do ^c002201
bbb

$gtm_tst/com/wait_until_src_backlog_below.csh 0 100

$gtm_tst/com/dbcheck.csh -extract
echo "extract file on secondary side on the journal file during c002201"
$sec_shell '$sec_getenv; cd $SEC_SIDE; set loadmjl = `ls -rt load.mjl | $tail -n 1`;  echo $loadmjl >! loadmjl.filename ; $MUPIP journal -extract=load2.mjf -for $loadmjl'
echo "verify the secondary side extract file"

# Copy the extract file to primary and execute the awk command
$cprcp _REMOTEINFO_$SEC_SIDE/load2.mjf ./load2_secondary.mjf
set rcp_status = $status
if ( 0 != $rcp_status ) then
	echo "FAILED: $rcp ${tst_remote_host}:${SEC_SIDE}/load2.mjf ./load2_secondary.mjf"
else
	# The below awk expression with double quotes is very difficult to execute in the secondary shell.
	# so we execute it locally.  If you want to run it by hand, use \\\\ inside the quotes
	$tst_awk '{n=split($0,f,"\\"); if (f[1]=="05" || f[1]=="09") print f[n]}' load2_secondary.mjf
endif
