#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps 2 255 1000 -allocation=2048 -extension_count=2048
setenv portno `$sec_shell 'cat $SEC_DIR/portno'`
if ("ENCRYPT" == $test_encryption) then
	mv ${gtmcrypt_config} ${gtmcrypt_config}.orig
	sed 's|dat: "'$cwd'/|dat: "|' ${gtmcrypt_config}.orig >& $gtmcrypt_config
endif

echo "# Starting Background Updates..."
setenv gtm_test_jobid 1
$gtm_tst/com/imptp.csh >&! imptp.out
sleep 10

$MUPIP set $tst_jnl_str -reg "*" >>& mup_set1.log

$gtm_tst/com/endtp.csh >>&! imptp.out
$gtm_tst/com/RF_sync.csh


mkdir bak1 ; $MUPIP backup -replinstance=bak1 "*" bak1/ >&! backup_bak1.out
if (0 != $status) then
	echo "TEST-E-ERROR backup errors pls. check backup_bak1.out"
endif
mv bak1/mumps.repl bak1/pri_mumps.repl
$sec_shell '$sec_getenv; cd $SEC_SIDE; mkdir bak2 ; $MUPIP backup -online "*" bak2/ >&! backup_bak2.out'

$MUPIP set $tst_jnl_str -reg "*" >>& mup_set2.log

ls *.mjl* >&! pri_jnl_after_bkup.txt
$sec_shell '$sec_getenv; cd $SEC_SIDE;ls *.mjl* >&! sec_jnl_after_bkup.txt'
# The above list of mjl files are not required to be copied over. This list includes mumps.mjl and a.mjl. These are not required.
echo "# Continuing with updates on primary" >>&! imptp.out
setenv gtm_test_jobid 2

# When ASYNCIO is ON, we have seen that in rare cases (particularly when the system is loaded), the forward recovery (done
# by this test a little later) takes a lot of time to finish and by that time the backlog due to the below call to "imptp.csh"
# builds up a lot resulting in the test eventually taking a long time to run. So we slow down the rate of updates of this
# second "imptp.csh" call (in this test) by using SLOWFILL only when ASYNCIO is ON.
if (0 != $gtm_test_asyncio) then
	setenv gtm_test_dbfill SLOWFILL
endif

$gtm_tst/com/imptp.csh >>&! imptp.out

foreach i (3 4 5)
	sleep 5
	$MUPIP set $tst_jnl_str -reg "*" >>& mup_set$i.log
end

$gtm_tst/com/rfstatus.csh "BEFORE_SEC_CRASH:"
$sec_shell '$sec_getenv; cd $SEC_SIDE;$gtm_tst/com/receiver_crash.csh'

$sec_shell '$sec_getenv; cd $SEC_SIDE; mkdir bak_b4recover ; mv *.mjl* *.dat *.repl bak_b4recover/'
set a_count = `$grep a.mjl pri_jnl_after_bkup.txt | wc -l`
@ count = $a_count
setenv files_tocp1 `ls -rt a.mjl_* | $tail -n +$count`

set mumps_count = `$grep mumps.mjl pri_jnl_after_bkup.txt | wc -l`
@ count = $mumps_count
setenv files_tocp2 `ls -rt mumps.mjl_* | $tail -n +$count`
setenv files_tocp "$files_tocp1 $files_tocp2"
setenv jnls_to_recover "`echo $files_tocp | sed 's/ /,/g'`"

# The below section wouldn't work in a multi-host scenario. Fix it when required.
# set_regseqno.csh relies on the timestamps of the journal files to determine the last generation journal file
# so preserve timestamps of journal files while copying from primary to secondary (see <refresh_secondary_diff_in_extract>)
cp -p $files_tocp $SEC_SIDE
\cp bak1/* $SEC_SIDE

if ( "ENCRYPT" == $test_encryption) then
	cp gtmcrypt.cfg $SEC_SIDE/gtmcrypt.cfg
endif
echo "# Start forward recovery using the journals from Primary..."
$sec_shell '$sec_getenv; cd $SEC_SIDE; echo "$MUPIP journal -recover -forward -verbose -redirect=$PRI_SIDE/mumps.dat=$SEC_SIDE/mumps.dat,$PRI_SIDE/a.dat=$SEC_SIDE/a.dat $jnls_to_recover" >>&! recover_forward_1.out'
$sec_shell '$sec_getenv; cd $SEC_SIDE; $MUPIP journal -recover -forward -verbose -redirect="$PRI_SIDE/mumps.dat=$SEC_SIDE/mumps.dat,$PRI_SIDE/a.dat=$SEC_SIDE/a.dat" $jnls_to_recover >>&! recover_forward_1.out'
echo "# We should see JNLSUCCESS messages and should NOT see any .broken or .lost files created"
echo "# Previous generation journal files should NOT be included and so we should NOT see MUJNLPREVGEN message"
$sec_shell '$sec_getenv; cd $SEC_SIDE; $grep -E "JNLSUCCESS|\.broken|\.lost" recover_forward_1.out '
echo "# Forward recovery ends"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/set_regseqno.csh >>&! change_regseqno.out"

# replication instance file be created with -supplementary option for A->P and P->Q situations i.e if test_replic_suppl_type is 1 or 2
set supplarg = ""
if ((1 == $test_replic_suppl_type) || (2 == $test_replic_suppl_type)) then
	set supplarg = "-supplementary"
endif
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replic -instance_create -name=$gtm_test_cur_sec_name $supplarg $gtm_test_qdbrundown_parms"
setenv starttime1 `date +%H_%M_%S`

# Now that all updates from journal files have been played forward, start secondary with -updateresync. For that you need an instance file from the primary.
# Take a backup again on the primary of just the instance file and ship it to the secondary.
mkdir bak2 ; $MUPIP backup -replinstance=bak2 >&! backup_bak2.out
mv bak2/mumps.repl bak2/pri2_mumps.repl
\cp bak2/pri2_mumps.repl $SEC_SIDE

setenv updresyncstr "updateresync=pri2_mumps.repl"
# For A->P configuration, we need to additionally use the -RESUME qualifier
if (1 == $test_replic_suppl_type) then
	setenv updresyncstr "$updresyncstr -resume=1"
endif
# signal jnl_on.csh to use -file while turning on journaling, as the db copied from primary will have jnl file pointing to the primary directory
setenv test_jnl_on_file 1
$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh "on" $portno $starttime1 "$updresyncstr" < /dev/null >>&! $SEC_SIDE/START_${starttime1}.out'
unsetenv test_jnl_on_file

$gtm_tst/com/endtp.csh >>&! endtp.out
$gtm_tst/com/dbcheck.csh -extract
$gtm_tst/com/checkdb.csh
