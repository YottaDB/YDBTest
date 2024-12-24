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
echo '# Test ydb_env_set calls in a multi-user environment do not result in GTMSECSHRSRVF errors'
echo "##########################################################################################"

echo '# See https://gitlab.com/YottaDB/DB/YDB/-/issues/1112#description for more details'

# Note: This subtest flow is very similar to that of sudo/u_inref/gtmsecshrsrvf-ydb_tmp-ydb1112.csh.

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

chmod +x $script

echo "# Execute script $script as userid $gtmtest1"
echo '# This will open $gtm_dist/gtmhelp.dat and then kill -9 itself leaving the ftok semaphore lying around'
$rsh $tst_org_host -l $gtmtest1 $tst_tcsh `pwd`/$script

echo '# Start $gtm_dist/gtmsecshr after setting ydb_tmp/gtm_tmp to something like /tmp/yottadb/r2.02_x86_64'
echo '# (which matches what ydb_env_set would have set the env var to)'
set dirname = `$gtm_dist/mumps -run %XCMD 'write $piece($zyrelease," ",2)_"_"_$piece($zyrelease," ",4),!'`
setenv ydb_tmp /tmp/yottadb/$dirname
# Create directory before starting gtmsecshr, in case it does not already exist
sudo mkdir -p $ydb_tmp
sudo chmod 777 $ydb_tmp

set syslog_before1 = `date +"%b %e %H:%M:%S"`

$gtm_dist/gtmsecshr

cat > ydb_env_set_execute.sh << CAT_EOF
unset ydb_log gtm_log
unset ydb_tmp gtm_tmp
unset ydb_gbldir gtmgbldir
unset ydb_chset gtm_chset
export LC_ALL=C
. $ydb_dist/ydb_env_set
env | grep '^ydb_tmp='
CAT_EOF

echo '# Open $gtm_dist/gtmhelp.dat as current userid using $gtm_dist/ydb_env_set (which does PEEKBYNAME calls)'
echo '# This would need help from gtmsecshr server to remove the ftok semaphore when it terminates'
echo '# But this process has ydb_tmp/gtm_tmp unset, whereas gtmsecshr server started in the previous step has it set.'
echo '# We expect the ydb_env_set call to set ydb_tmp to the appropriate value and successfully communicate with the server.'
echo '# And NOT end up with a GTMSECSHRSRVF error which it did before the YDB#1112 code fixes.'
echo '# We expect to see NO errors from the ydb_env_set invocation.'
sh ydb_env_set_execute.sh | sed 's,'$ydb_tmp',##YDB_TMP##,;'

$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog1.txt

set pattern = "GTMSECSHRDMNSTARTED|GTMSECSHRTMPPATH|SYSCALL|GTMSECSHRSTART|DBRNDWN"
echo "# 1) Check that a GTMSECSHRDMNSTARTED message is seen in syslog"
echo "# 2) Check that a GTMSECSHRTMPPATH message is seen in syslog"
echo "# 3) Check that a SYSCALL message is NOT seen in syslog"
echo "# 4) Check that a GTMSECSHRSTART message is NOT seen in syslog"
echo "# 5) Check that a DBRNDWN message is NOT seen in syslog"
$grep -E "$pattern" syslog1.txt | sed 's/.* YDB-/YDB-/;s/\[.*\]/[##PID##]/;s/8 - [0-9]* :/8 - ##PID##/;s,version .* from /,version ##ZYRELEASE## from /,;s/ -- generated from.*//;s/ydb_secshr......../ydb_secshrXXXXXXXX/;s,'$ydb_tmp',##YDB_TMP##,;s,called from module .*/sr_,called from module sr_,;'

# Kill gtmsecshr process started above before leaving subtest
set secshrpid = `pgrep -f $gtm_dist/gtmsecshr`
if ("$secshrpid" != "") then
	sudo kill $secshrpid
endif

