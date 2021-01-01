#!/bin/tcsh
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
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
# needed to create the /var/log/messages or /var/log/syslog file; as otherwise it won't exist at start
logger test

# Next two seds, fix the serverconf.txt file
## Correct the host; as it differs each time we start docker
sed -i "s/HOST/$HOST/" /usr/library/gtm_test/serverconf.txt
## Correct the syslog file too
if ( -f /var/log/messages ) then
	sed -i 's|LOG|/var/log/messages|' /usr/library/gtm_test/serverconf.txt
else if (-f /var/log/syslog ) then
	sed -i 's|LOG|/var/log/syslog|' /usr/library/gtm_test/serverconf.txt
else
  exit 99
endif

## Make sure /testarea1 is writeable, as it can be redirected from the host
chmod 777 /testarea1

# Run the tests as the test user
exec su -l gtmtest -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -noencrypt -fg -stdout 1 $argv"
