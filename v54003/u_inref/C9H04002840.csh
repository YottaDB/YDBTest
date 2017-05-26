#!/usr/local/bin/tcsh -f

$gtm_tst/com/dbcreate.csh mumps

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 47

$echoline

echo "Starting the first MUPIP process"
($MUPIP backup "*" backup >&! backup.out & ; echo $! >! mupip_backup_pid.log) >&! mupip_backup.out

$gtm_tst/com/wait_for_log.csh -log mupip_backup_pid.log
set pid = `cat mupip_backup_pid.log`

$gtm_tst/com/wait_for_log.csh -log backup.out -message "MUPIP BACKUP entered grab_crit"
echo "Will suspend the MUPIP BACKUP process now"
kill -s STOP $pid

$echoline

echo "Starting the second MUPIP process"
($MUPIP set -file -nojournal mumps.dat >&! set_no_journal.out & ; echo $! >! mupip_set_no_journal_pid.log) >&! mupip_set_no_journal.out

$gtm_tst/com/wait_for_log.csh -log mupip_set_no_journal_pid.log
set pid2 = `cat mupip_set_no_journal_pid.log`

$gtm_tst/com/wait_for_log.csh -log set_no_journal.out -message "MUPIP SET entered grab_crit"
echo "Will suspend the MUPIP SET process now"
kill -s STOP $pid2

$echoline

echo "Will resume the MUPIP BACKUP process now"
kill -s CONT $pid

$gtm_tst/com/wait_for_log.csh -log backup.out -message "MUPIP BACKUP is about to start long sleep"
echo "Will suspend the MUPIP BACKUP process now"
kill -s STOP $pid

$echoline

echo "Will resume the MUPIP SET process now"
kill -s CONT $pid2

$gtm_tst/com/wait_for_log.csh -log set_no_journal.out -message "PATH TO SOCKET IS"

echo "Will change permissions on the socket"
set socket_file = `$tail -n 1 set_no_journal.out`
chmod 555 $socket_file

$gtm_tst/com/wait_for_log.csh -log set_no_journal.out -message "CALLED CONTINUE_PROC() ON THE OTHER PROCESS"
echo "Will suspend the MUPIP SET process now"
kill -s STOP $pid2

$echoline

$gtm_tst/com/wait_for_proc_to_die.csh $pid 200

echo "Will resume the MUPIP SET process now"
kill -s CONT $pid2

$gtm_tst/com/wait_for_proc_to_die.csh $pid2 200

$echoline

unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number

$gtm_tst/com/dbcheck.csh
