#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#=====================================================================
echo "# Functionality test for backup of instance files."
$MULTISITE_REPLIC_PREPARE 3
setenv gtm_test_disable_randomdbtn 1
setenv gtm_test_mupip_set_version "disable"
$gtm_tst/com/dbcreate.csh . 3
$MSR START INST1 INST2
$MSR START INST1 INST3

if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	set filterit = '%YDB-I-BACKUPTN, Transactions from'
else
	set filterit = 'NOTHINGTOFILTEROUT'
endif
alias trcount '$tst_awk '"'"'/%YDB-I-BACKUPTN, Transactions from/ {tot=tot+strtonum($6)} END{ print "# Total number of transactions backed up: ",tot}'"'"' '
$echoline
echo "#- Some bakground updates on INST1:"
$MSR RUN INST1 '$gtm_tst/com/simplebgupdate.csh 111 > bg_pid.out'
# Wait until all 111 updates are done
$gtm_tst/com/wait_for_transaction_seqno.csh 110 SRC 120 INSTANCE2 noerror
$MSR SYNC ALL_LINKS
echo "#- While the source servers are running on INST1, test:"
set echo; $MUPIP backup -replinstance=bak1on.repl; unset echo
echo "#        --> Does create a backup of the repl instance file"
ls bak1on.repl mumps.repl

$echoline
set echo; $MUPIP backup -replinstance=bak1on.repl >& backup1on1.out; unset echo
echo "#        --> We expect a MUNOACTION error since file bak1on.repl exists already"
$gtm_tst/com/check_error_exist.csh backup1on1.out MUNOACTION FILEEXISTS
cat backup1on1.out

$echoline
set echo; $MUPIP backup -replinstance=bakx.repl -incremental >& backup1on2.out; unset echo
echo "#        --> Issues a MUPCLIERR error, no bakx.repl generated"
$gtm_tst/com/check_error_exist.csh backup1on2.out MUPCLIERR
sort backup1on2.out

$echoline
set echo; $MUPIP backup -replinstance=bakx.repl -bkupdbjnl="off" >& backup1on3.out; unset echo
echo "#        --> Issues a MUPCLIERR error, no bakx.repl generated"
$gtm_tst/com/check_error_exist.csh backup1on3.out MUPCLIERR
sort backup1on3.out

$echoline
set echo; $MUPIP backup -replinstance=bakx.repl -newjnlfiles >& backup1on4.out; unset echo
echo "#        --> Issues a MUPCLIERR error, no bakx.repl generated"
$gtm_tst/com/check_error_exist.csh backup1on4.out MUPCLIERR
sort backup1on4.out

$echoline
set echo; mkdir bakdir1on; $MUPIP backup -replinstance=bakdir1on "*" bakdir1on >& backup1on5.out; unset echo
echo "#        --> Creates a backup of the replinstance file as well as all regions in the directory bakdir1on"
sort backup1on5.out |& $grep -v "$filterit"
trcount backup1on5.out
set echo; ls bakdir1on; unset echo

$echoline
set echo; $MUPIP backup -replinstance=bakdir1on >& backup1on6.out; unset echo
echo "#        --> We expect a MUNOACTION error since bakdir1on exists, since there is a mumps.repl in it already"
$gtm_tst/com/check_error_exist.csh backup1on6.out MUNOACTION FILEEXISTS
cat backup1on6.out

$echoline
set echo; $MUPIP backup -replinstance=bakdirf "*" bakdirf >& backup1on7.out; unset echo
cat << EOF
	--> Should error out after the replication instance file backup (at the first region's backup) that the file
	    exists.
EOF
$gtm_tst/com/check_error_exist.csh backup1on7.out MUNOACTION
sort backup1on7.out

$echoline
set echo; mkdir bakdirrepl bakdirdb; $MUPIP backup -replinstance=bakdirrepl "*" bakdirdb >& backup1on8.out; unset echo
echo "#	--> The replication instance file should be backed up into bakdirrepl directory, and databases into bakdirdb."
sort backup1on8.out |& $grep -v "$filterit"
trcount backup1on8.out
echo "bakdirrepl:"
ls bakdirrepl
echo "bakdirdb:"
ls bakdirdb

if (-e bakx.repl) then
	echo "TEST-E-BACKUPERR, bakx.repl should not have been created. Check the above commands."
endif

$echoline
echo "#- Do some of the backup commands on INST2, same results expected."
$MSR RUN INST2 '$MUPIP backup -replinstance=bak2.repl >& bak2.tmp; cat bak2.tmp'
echo "#        --> Does create a backup of the repl instance file"
$MSR RUN INST2 'ls bak2.repl mumps.repl'

$echoline
$MSR RUN INST2 'set msr_dont_chk_stat; $MUPIP backup -replinstance=bakx.repl -incremental >& backup21.tmp; cat backup21.tmp' >& backup21.out
$gtm_tst/com/check_error_exist.csh $msr_execute_last_out MUPCLIERR
$gtm_tst/com/check_error_exist.csh backup21.out MUPCLIERR
sort backup21.out
echo "#        --> Issues a MUPCLIERR error, no bakx.repl generated"

$echoline
$MSR RUN INST2 'set msr_dont_chk_stat; $MUPIP backup -replinstance=bakx.repl -bkupdbjnl="off" >& backup22.tmp; cat backup22.tmp' >& backup22.out
$gtm_tst/com/check_error_exist.csh $msr_execute_last_out MUPCLIERR
$gtm_tst/com/check_error_exist.csh backup22.out MUPCLIERR
sort backup22.out
echo "#        --> Issues a MUPCLIERR error, no bakx.repl generated"

$echoline
$MSR RUN INST2 'set msr_dont_chk_stat; $MUPIP backup -replinstance=bakx.repl -newjnlfiles >& backup23.tmp; cat backup23.tmp' >& backup23.out
$gtm_tst/com/check_error_exist.csh $msr_execute_last_out MUPCLIERR
$gtm_tst/com/check_error_exist.csh backup23.out MUPCLIERR
sort backup23.out
echo "#        --> Issues a MUPCLIERR error, no bakx.repl generated"

$echoline
$MSR RUN INST2 'mkdir bakdir2; $MUPIP backup -replinstance=bakdir2 "*" bakdir2 >& backup24.tmp; cat backup24.tmp' >& backup24.out
sort backup24.out |& $grep -v "$filterit"
trcount backup24.out
echo "#        --> Creates a backup of the replinstance file as well as all regions in the directory bakdir1"
$MSR RUN INST2 'ls bakdir2'

$MSR RUN INST2 'set msr_dont_trace; if (-e bakx.repl) echo "TEST-""E-BACKUPERR, bakx.repl should not have been created"'

$echoline
echo "#- Shutdown M process:"
touch endbgupdate.txt
$echoline
echo "#- Some more updates on INST1:"
$gtm_tst/com/simpleinstanceupdate.csh 111
$MSR SYNC INST1 INST2

$echoline
echo "#- Shutdown the replication servers"
$MSR STOP INST1 INST2
$MSR STOP INST1 INST3

$echoline
echo "#- Do some of the backup commands on INST1, same results expected"
set echo; $MUPIP backup -replinstance=bak1b.repl; unset echo
echo "#        --> Does create a backup of the repl instance file"
ls bak1b.repl mumps.repl

$echoline
set echo; $MUPIP backup -replinstance=bak1b.repl >& backup1off1.out; unset echo
echo "#        --> We expect a MUNOACTION error since file bak1b.repl exists already"
$gtm_tst/com/check_error_exist.csh backup1off1.out MUNOACTION FILEEXISTS
cat backup1off1.out

$echoline
set echo; $MUPIP backup -replinstance=bakx.repl -incremental >& backup1off2.out; unset echo
echo "#        --> Issues a MUPCLIERR error, no bakx.repl generated"
$gtm_tst/com/check_error_exist.csh backup1off2.out MUPCLIERR
sort backup1off2.out

$echoline
set echo; $MUPIP backup -replinstance=bakx.repl -bkupdbjnl="off" >& backup1off3.out; unset echo
echo "#        --> Issues a MUPCLIERR error, no bakx.repl generated"
$gtm_tst/com/check_error_exist.csh backup1off3.out MUPCLIERR
sort backup1off3.out

$echoline
set echo; $MUPIP backup -replinstance=bakx.repl -newjnlfiles >& backup1off4.out; unset echo
echo "#        --> Issues a MUPCLIERR error, no bakx.repl generated"
$gtm_tst/com/check_error_exist.csh backup1off4.out MUPCLIERR
sort backup1off4.out

$echoline
set echo; mkdir bakdir1off; $MUPIP backup -replinstance=bakdir1off "*" bakdir1off >& backup1off5.out; unset echo
echo "#        --> Creates a backup of the replinstance file as well as all regions in the directory bakdir1off"
sort backup1off5.out |& $grep -v "$filterit"
trcount backup1off5.out
set echo; ls bakdir1off; unset echo

$echoline
echo "#- Attempt to use the offline backup:"
mkdir cp
cp -p *.dat *.repl cp
cp -p bakdir1off/* .
$gtm_tst/com/jnl_on.csh
$MSR START INST1 INST2
$MSR START INST1 INST3
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 111'
$gtm_tst/com/dbcheck.csh -extract INST1 INST2 INST3
