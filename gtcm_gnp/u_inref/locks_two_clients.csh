#!/usr/local/bin/tcsh -f
source $gtm_tst/com/dbcreate.csh . 4

setenv > setenv.out
$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM ; $rcp $gtm_tst/$tst/inref/*.m TST_REMOTE_HOST_GTCM:SEC_DIR_GTCM"
echo "Testing LOCK..."
echo "No other processes are holding locks..."

echo "##################################################################################"

# lock ^b by another client

echo "Now, another client process is going to lock ^b, ^d, a, b"
($gtm_exe/mumps -run lockbcl </dev/null  >& lockbcl.out &)> lockbck_bg.out
$gtm_tst/com/wait_for_log.csh -log lockedbcl.out -waitcreation
set wait_status = $status
if ($wait_status)  then
	echo "$tst_remote_host_2 could not lock ^b. Cannot continue testing"
	$gtm_tst/$tst/u_inref/exit.csh b
	$gtm_tst/com/dbcheck.csh
	exit
endif

$gtm_exe/mumps -run lockcl
$gtm_tst/com/wait_for_log.csh -log lockbcl.out -message "Bye then."

$gtm_tst/com/dbcheck.csh
