#!/usr/local/bin/tcsh -f
# Test that update process issues TRIGDEFNOSYNC whenever it sees a out-of-sync situation in the trigger definitions for 
# the global in question. Such out-of-sync can happen in two ways:
# (a) A global has triggers defined in the primary but none in the secondary
# (b) A global has triggers defined in the secondary but none in the primary.

# Test flow:
# Since secondary doesn't allow updates, creating such an out-of-sync is not easy. So, 
# (a) load triggers for two globals ^a and ^b on primary, which will be replicated to secondary
# (b) Use DSE REMOVE -BLOCK -REC to remove ^#t entries corresponding to ^b on primary. 
# At this point, the trigger definitions on primary is out-of-sync from secondary. 
# (c) Do some updates to ^a. We don't expect any issues as the trigger definitions matches.
# (d) Do an update to ^b. We should see a TRIGDEFNOSYNC in the syslog.
# (e) Do another update to ^b to ensure that we DO NOT see the TRIGDEFNOSYNC

$gtm_tst/com/dbcreate.csh mumps 1

set syslog_before = `date +"%b %e %H:%M:%S"`

$gtm_exe/mumps -run trigdefnosync

# Testing both ways (i.e. triggers defined on primary but not on secondary and vice-versa) is cumbersome. So, 
# randomly decide whether we are going to remove triggers on the primary or secondary. Due to the large number
# of boxes that runs these tests, we are guaranteed to test both the possibilities
$echoline
echo "Randomly decide to delete triggers for global ^b either on primary or secondary"
$echoline
set rand = `$gtm_exe/mumps -run rand 2`
echo "Value of rand = $rand" >&! rand.txt
set timestamp = `cat $PRI_DIR/start_time`
if (0 == "$rand") then
	$gtm_exe/mumps -run removetrigdef^trigdefnosync >&! removetrigdef.out
else
	# It is possible that by the time we invoke DSE to remove the ^#t entries corresponding to ^b, triggers were not replicated 
	# in the secondary side. So, wait for the update process server log to show up the completed trigger update
	set message = "Rectype = 17 Committed Jnl seq no is : 1 .0x1."
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log RCVR_$timestamp.log.updproc -message "$message" -duration 180"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_exe/mumps -run removetrigdef^trigdefnosync >&! removetrigdef.tmp ; cat removetrigdef.tmp" >&! removetrigdef.out
endif
echo ""
echo ""

$gtm_exe/mumps -run expectnoissues^trigdefnosync
$gtm_exe/mumps -run insyslog^trigdefnosync
$gtm_exe/mumps -run notinsyslog^trigdefnosync

# Since the trigger definitions were out of sync, we can't expect database extract to pass. So, just do the database integrity check.
$gtm_tst/com/dbcheck.csh

echo ""
echo ""
$gtm_tst/com/getoper.csh "$syslog_before" "" syslog.txt "" TRIGDEFNOSYNC
if ($status) then
	echo "TEST-E-FAILED, TRIGDEFNOSYNC warning not seen in the syslog."
else
	echo "TEST-I-PASSED, TRIGDEFNOSYNC warning seen in the syslog as expected"
endif
