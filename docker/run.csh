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

# Fix length of columns to prevent wrapping issues
#setenv COLUMNS 4096
# Debug
#stty -a

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

# Make sure /testarea1 is writeable, as it can be redirected from the host
chmod 777 /testarea1

# Compile YottaDB if passed in as a volume
if ( -f /YDB/CMakeLists.txt ) then
  /usr/library/gtm_test/T999/docker/build_and_install_yottadb.csh
  if ( $status ) then
    echo "Compilation error"
    exit 99
  endif
endif

# User passed in the Test system as a volume
if ( -f /YDBTest/com/gtmtest.csh ) then
  echo "Copying passed in test system"
  rm -r /usr/library/gtm_test/T999
  mkdir -p /usr/library/gtm_test/T999
  cp -r /YDBTest/. /usr/library/gtm_test/T999
  chown -R gtmtest:gtc /usr/library/gtm_test/T999
endif

if ( $#argv == 0 ) then
  exec su -l gtmtest -c "/usr/library/gtm_test/T999/com/gtmtest.csh -h"
endif

# Debugging entry points for testing problems with the system
if ( "$argv[1]" == "-rootshell") then
  exec su -
endif

if ( "$argv[1]" == "-shell") then
  echo "Try running /usr/library/gtm_test/T999/com/gtmtest.csh -nomail -noencrypt -fg -env gtm_ipv4_only=1 -stdout 1 -t r132"
  exec su -l gtmtest
endif

# Run the tests as the test user
exec su -l gtmtest -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -noencrypt -fg -env gtm_ipv4_only=1 -stdout 1 $argv"
