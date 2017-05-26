#!/usr/local/bin/tcsh -f
#
# C9H09-002905 Source server should log only AFTER sending at least 1000 transactions on the pipe
#
if (! $?test_replic) then
	echo "This subtest is applicable only with -replic. Exiting."
	exit
endif

$gtm_tst/com/dbcreate.csh mumps		# create database and start replication servers
$gtm_exe/mumps -run c002905		# generate updates
$gtm_tst/com/dbcheck.csh -extract	# shut down replication servers and do data check between primary and secondary

# Check that REPL INFO messages show up only after at least 1000 transactions.
$tst_awk -f $gtm_tst/$tst/inref/c002905.awk SRC_*.log
