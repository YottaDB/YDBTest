#!/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
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

# Start sshd
/sbin/sshd

# Add an extra hostname for remote tests
echo "127.0.0.1 ydbtest" >> /etc/hosts

# Trust localhost
su - gtmtest -c "ssh-keyscan -t rsa localhost >>& ~/.ssh/known_hosts"
su - gtmtest -c "ssh-keyscan -t rsa `hostname -I` >>& ~/.ssh/known_hosts"
su - gtmtest -c "ssh-keyscan -t rsa $HOST >>& ~/.ssh/known_hosts"
su - gtmtest -c "ssh-keyscan -t rsa ydbtest >>& ~/.ssh/known_hosts"

# Next seds, fix the serverconf.txt file
## Correct the host; as it differs each time we start docker
sed -i "s/HOST/$HOST/" /usr/library/gtm_test/serverconf.txt
sed -i 's|LOG|/var/log/syslog|' /usr/library/gtm_test/serverconf.txt
sed -i "s/SE1/localhost/" /usr/library/gtm_test/serverconf.txt
sed -i "s/SE2/ydbtest/" /usr/library/gtm_test/serverconf.txt

# Set hosts on tstdirs.csh file
sed -i "s/HOST/$HOST/" /usr/library/gtm_test/tstdirs.csh
sed -i "s/SE1/localhost/" /usr/library/gtm_test/tstdirs.csh
sed -i "s/SE2/ydbtest/" /usr/library/gtm_test/tstdirs.csh

# Make sure /testarea[n] is writeable, as it can be redirected from the host
chmod 777 /testarea1
chmod 777 /testarea2
chmod 777 /testarea3

# Runner job does not set TERM
setenv TERM xterm

if ( ! -f /YDBTest/com/gtmtest.csh && -f ${PWD}/com/gtmtest.csh ) then
	# Copy over the test system to $gtm_tst
	# This is ineffecient, but not worth optimizing. It copies everything over rather than only changed files.
	setenv gtm_tst "/usr/library/gtm_test/T999"
	rsync . -ar --delete $gtm_tst
	chown -R gtmtest:gtc $gtm_tst
	git config --global --add safe.directory $gtm_tst
endif

if ( -f /YDBTest/com/gtmtest.csh ) then
	# Test system passed in /YDBTest, use that
	rm -r /usr/library/gtm_test/T999
	ln -s /YDBTest /usr/library/gtm_test/T999
	git config --global --add safe.directory /YDBTest
endif

# Special pipeline set-up for testareas
# Set-up testareas to be in the current directory so we can upload the artifacts
if ( $?CI_PIPELINE_ID ) then
	mkdir -p testarea{1,2,3}
	# tst_dir can only be one test area, the main one
	echo "setenv tst_dir ${PWD}/testarea1" >> ~gtmtest/.cshrc
	chmod 777 ${PWD}/testarea{1,2,3}
	sed -i "s|/testarea|$PWD/testarea|g" /usr/library/gtm_test/tstdirs.csh
endif

# Set-up some environment variables to pass to the test system
setenv ydb_test_inside_docker 1
setenv pass_env "-w CI_PIPELINE_ID -w CI_COMMIT_BRANCH -w ydb_test_inside_docker"
