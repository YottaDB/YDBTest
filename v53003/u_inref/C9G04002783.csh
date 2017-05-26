#!/usr/local/bin/tcsh -f
#
# C9G04-002783 MUPIP BACKUP and MUPIP INTEG -REG should prevent M-kills from starting
#
# The WHITE BOX test used in this section of test will leave the database inconsistent.
echo "# ENTERING C9G04002783"
$gtm_tst/com/dbcreate.csh .

echo "# SCENARIO #1"
#Do a global variable set to get shared memory segment.
#Set inhibit_kills=1
#Start set global variable
#Start kill global variable
#KILL will wait for inhibit_kills to reset for MAXWAIT2KILL time(2 minutes). After waiting for MAXWAIT2KILL it will
# override inhibit_kills flag to zero and proceed normally.
#Expect write to fail as KILL is succesfull.

$GTM << GTM_EOF
set ^x=1
write "Setting inhibit_kills=1 using DSE"
zsystem "$DSE change -file -inhibit_kills=1"
do mnset^c002783
do mnkill^c002783
write "Test if KILL of global variable a and b was successful. Expect write failure."
write ^a(10,10,10),!,^b(10,10,10)
zsystem "$DSE dump -file -all >& dse_dump.out"
halt
GTM_EOF

$grep -E "inhibiting KILLs" dse_dump.out

#Backup previously created job.txt by mnkill^c002783
\mv job.txt job_1.txt
# White box testing is disabled for the PRO builds, since the wait logic under WB test will not run in PRO builds.
# KILL process will be MUPIP STOP'ed in undermined state hence producing undetermined output.
if ("pro" == $tst_image) then
	echo "# SCENARIO #2 is disabled for PRO builds"
	echo "# LEAVING C9G04002783"
	$gtm_tst/com/dbcheck.csh
	exit
endif
echo "# SCENARIO #2"
#Set white box testing environment.
#Set global variables
#KILLs will be waiting in phase 2 of KILL, when the white box testing is enabled.Start them in background.
#Wait for job.txt to be created by KILL
#Mupip stop the process in job.txt(i.e KILLs waiting in phase 2). When the KILL command is mupip stop'ped in phase 2, 
# the signal handlers will invoke secshr_db_clnup, which will decrement KIP and increment abandoned_kills. 
# If the test fails KIP will be incremented while abandoned_kills will remain zero.
#Check if abandoned_kills is set in DSE dump

echo "# Enable WHITE BOX TESTING"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 21
setenv gtm_white_box_test_case_count 1

echo "# Set globals"
$GTM << GTM_EOF
do mnset^c002783
GTM_EOF

echo "# Since the KILLs will be waiting when white box testing is enabled.Start them in background"
$gtm_tst/$tst/u_inref/callmnkill.csh  >& callmnkill.log 

echo "# Wait for kill process to create job.txt with its process id. Mupip wait will stop this process"
$gtm_tst/com/wait_for_log.csh -log job.txt -waitcreation -duration 120
set pid = `cat job.txt`

echo "# Wait for log with message WBTEST_ABANDONEDKILL"
$gtm_tst/com/wait_for_log.csh -log mnkill.outx -waitcreation -duration 60 -message "WBTEST_ABANDONEDKILL waiting in Phase II of Kill"

echo "# Stop the kill process and display all kill related fields"
$MUPIP stop $pid

$gtm_tst/com/wait_for_proc_to_die.csh $pid 60 # 60 second wait

$DSE << DSE_EOF >&! dse_dump1.out
dump -file -all
exit
DSE_EOF

$grep -E "KILLs in progress|Actual kills in progress|inhibiting KILLs" dse_dump1.out

echo "# LEAVING C9G04002783"
$gtm_tst/com/dbcheck_filter.csh
