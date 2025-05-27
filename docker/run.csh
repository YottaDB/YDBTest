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
source /usr/library/gtm_test/T999/docker/shared-setup.csh

if ( $#argv == 0 ) then
	exec su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -h"
endif

# Debugging entry points for testing problems with the system
if ( "$argv[1]" == "-rootshell") then
	exec su - $pass_env
endif

# Sudo tests rely on the source code for ydbinstall to be in a specific location
ln -s /Distrib/YottaDB /Distrib/YottaDB/V999_R999

if ( "$argv[1]" == "-shell") then
	echo "Try running gtmtest -t r134"
	echo "Type 'ver' to switch versions"
	exec su -l gtmtest $pass_env
endif

# Run the tests as the test user
exec su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 $argv"
