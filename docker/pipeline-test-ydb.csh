#!/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
set echo
set verbose

#set TEST_LIST=$1
set TEST_LIST="basic r134 r138 r200 v70001 v70002 70003 v70004 v70005"

# Ensure that our hostname does not have dashes as that crashes multiple parts of the test system
# (it converts hostnames into variables)
echo "HOSTNAME: $HOST"

# Preamble
# Start log server; needed by test framework
rsyslogd
# needed to create the /var/log/syslog file; as otherwise it won't exist at start
logger test

# The file is created asynchronously, so this ensures we don't proceed till it's created
while ( ! -e /var/log/syslog)
  sleep .01
end

# Next two seds, fix the serverconf.txt file
## Correct the host; as it differs each time we start docker
sed -i "s/HOST/$HOST/" /usr/library/gtm_test/serverconf.txt
sed -i 's|LOG|/var/log/syslog|' /usr/library/gtm_test/serverconf.txt

# Fix HOST on tstdirs.csh file
sed -i "s/HOST/$HOST/" /usr/library/gtm_test/tstdirs.csh

# Runner job does not set TERM
setenv TERM xterm

# Set-up some environment variables to pass to the test system
setenv ydb_test_inside_docker 1
set pass_env = "-w CI_PIPELINE_ID -w CI_COMMIT_BRANCH -w ydb_test_inside_docker"

RANDOM_TEST_LIST=`shuf -n5 -e $TEST_LIST`

foreach test ($RANDOM_TEST_LIST)
	unsetenv subtest_list subtest_list_non_replic subtest_list_common subtest_list_replic
	grep "setenv subtest_list_" ${test}/instream.csh > instream_setenvs
	source instream_setenvs
	rm instream_setenvs
	set subtest_list "$subtest_list_non_replic $subtest_list_common $subtest_list_replic"
	set random_subtest_list=`shuf -n5 -e $subtest_list`
	set subtest_list_with_commas=`tr $random_subtest_list ' ' ','`
	su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -noencrypt -fg -env gtm_ipv4_only=1 -stdout 2 -t $test -st $subtest_list_with_commas"
	su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -noencrypt -fg -env gtm_ipv4_only=1 -stdout 2 -t $test -st $subtest_list_with_commas -replic"
end
