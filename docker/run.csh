#!/bin/tcsh
#################################################################
#								#
# Copyright (c) 2021-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
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

# Trust localhost
su - gtmtest -c "ssh-keyscan -t rsa localhost >>& ~/.ssh/known_hosts"
su - gtmtest -c "ssh-keyscan -t rsa `hostname -I` >>& ~/.ssh/known_hosts"
su - gtmtest -c "ssh-keyscan -t rsa $HOST >>& ~/.ssh/known_hosts"

# Next two seds, fix the serverconf.txt file
## Correct the host; as it differs each time we start docker
sed -i "s/HOST/$HOST/" /usr/library/gtm_test/serverconf.txt
sed -i 's|LOG|/var/log/syslog|' /usr/library/gtm_test/serverconf.txt

# Set HOST on tstdirs.csh file
sed -i "s/HOST/$HOST/" /usr/library/gtm_test/tstdirs.csh

# Make sure /testarea1 is writeable, as it can be redirected from the host
chmod 777 /testarea1

# User passed in the Test system as a volume
if ( -f /YDBTest/com/gtmtest.csh ) then
	# Symlink to allow user to experiment and get the test to pass
	echo "Test System passed in as a volume... symlinking test system"
	rm -r /usr/library/gtm_test/T999
	ln -s /YDBTest /usr/library/gtm_test/T999
endif

# Sudo tests rely on the source code for ydbinstall to be in a specific location
ln -s /Distrib/YottaDB /Distrib/YottaDB/V999_R999

setenv ydb_test_inside_docker 1
set pass_env = "-w CI_PIPELINE_ID -w CI_COMMIT_BRANCH -w ydb_test_inside_docker -w gtm_curpro"

if ( $#argv == 0 ) then
	exec su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -h"
endif

# Debugging entry points for testing problems with the system
if ( "$argv[1]" == "-rootshell") then
	exec su - $pass_env
endif

if ( "$argv[1]" == "-shell") then
	echo "Try running gtmtest -t r134"
	echo "Type 'ver' to switch versions"
	exec su -l gtmtest $pass_env
endif

if ( "$argv[1]" == "-pipelineydb") then
	exec su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/docker/pipeline-test-ydb.csh"
endif

# Run the tests as the test user
exec su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 $argv"
