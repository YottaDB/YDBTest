#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "##########################################################################################"
echo '# Test ydb_tmp env var mismatch between multiple clients results in GTMSECSHRSRVF errors'
echo "##########################################################################################"

echo "# This test runs commands as current user and $gtmtest1 userid. The latter is not easy to do in UTF-8 mode."
echo "# Since this test does not care about M vs UTF-8 mode, wwitch test to M mode for ease of implementation."
$switch_chset "M"

set script = "gtmtest1_execute.csh"
echo "# Prepare script $script to be executed by $gtmtest1 userid"
cat >> gtmtest1_execute.csh << CAT_EOF
setenv gtm_dist $gtm_dist
setenv gtmroutines "$gtmroutines"
$gtm_dist/mumps -run %XCMD 'set \$zgbldir=\$ztrnlnm("gtm_dist")_"/gtmhelp.gld",dbfname=\$\$^%PEEKBYNAME("gd_segment.fname","DEFAULT","S")  zsystem "kill -9 "_\$job'
CAT_EOF

chmod +x gtmtest1_execute.csh

echo "# Execute script $script as userid $gtmtest1"
echo '# This will open $gtm_dist/gtmhelp.dat and then kill -9 itself leaving the ftok semaphore lying around'
$rsh $tst_org_host -l $gtmtest1 $tst_tcsh `pwd`/gtmtest1_execute.csh

echo '# Start $gtm_dist/gtmsecshr after setting ydb_tmp/gtm_tmp to /tmp/tmp.xxxx (where xxxx is a randomly generated name)'
set tmpdir = `mktemp -d`
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_tmp gtm_tmp $tmpdir
$gtm_dist/gtmsecshr
echo "# Unset ydb_tmp/gtm_tmp env var"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_tmp gtm_tmp

set syslog_before1 = `date +"%b %e %H:%M:%S"`

echo '# Open $gtm_dist/gtmhelp.dat as current userid'
echo '# This would need help from gtmsecshr server to remove the ftok semaphore when it terminates'
echo '# But this process has ydb_tmp/gtm_tmp unset, whereas gtmsecshr server started in the previous step has it set.'
echo '# We therefore expect this process to be unable to communicate with the server and end up with a GTMSECSHRSRVF error'
echo '# We also expect to see various other secondary errors CRITSEMFAIL/ENO2 etc.'
$gtm_dist/mumps -run %XCMD 'set $zgbldir=$ztrnlnm("gtm_dist")_"/gtmhelp.gld",dbfname=$$^%PEEKBYNAME("gd_segment.fname","DEFAULT","S")'

$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog1.txt

set pattern = "GTMSECSHRDMNSTARTED|GTMSECSHRTMPPATH|SYSCALL|GTMSECSHRSTART|DBRNDWN"
echo "# Check that $pattern messages are seen in syslog"
echo '# 1) Test that GTMSECSHRDMNSTARTED message in syslog includes full path of server socket file'
echo '# 2) Test that %SYSTEM-E-ENO2 error (ENOENT) is seen from the sendto() system call'
echo '# 3) Test that sendto() system call shows full path of the server socket file that client is sending to'
echo '# 4) Test that the client retries for a total of 5 times before giving up (5 sets of messages seen below)'
$grep -E "$pattern" syslog1.txt | sed 's/.* YDB-/YDB-/;s/\[.*\]/[##PID##]/;s/8 - [0-9]* :/8 - ##PID##/;s,version .* from /,version ##ZYRELEASE## from /,;s/ -- generated from.*//;s/ydb_secshr......../ydb_secshrXXXXXXXX/;s,/tmp/tmp...........,/tmp/tmp.XXXXXXXXXX,;s,called from module .*/sr_,called from module sr_,;'

# Kill gtmsecshr process started above before leaving subtest
set secshrpid = `ps -ef | grep $gtm_dist/gtmsecshr | grep -v grep | $tst_awk '{print $2}'`
if ("$secshrpid" != "") then
	sudo kill $secshrpid
endif

# Remove temporary directory created above before leaving subtest
rm -rf $tmpdir

