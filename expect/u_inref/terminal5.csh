#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Don't use an existing screen instance
unsetenv STY

# Use xterm settings
setenv TERM xterm

# HP-UX Solaris machines use these settings because they have this path
if ( -d /usr/local/lib/terminfo ) then
	setenv TERM vt320
	setenv TERMINFO /usr/local/lib/terminfo
endif

# Use the OS default ICU version. Some servers are configured to use 3.6 out of /usr/local
# and that does not work because screen unsetenvs LD_LIBRARY_PATH and LIBPATH
unsetenv LD_LIBRARY_PATH

$echoline
echo "Step 5 - verify that the screen redraw works with using screen since the output contains terminal characters"

# If there is no screen, skip the test
if ( ! -X screen ) then
	echo No hay screen
	exit 0
endif

expect -f $gtm_tst/$tst/inref/terminal5.exp >& terminal5_expect.log
$echoline
# Screen does not create the file immediately, so wait for the files creation and read the first 5 lines, the rest are empty
$gtm_dist/mumps -run waitforfilecreate terminal5.out.1 && $head -n5 terminal5.out.1
$echoline
$gtm_dist/mumps -run waitforfilecreate terminal5.out.2 && $head -n5 terminal5.out.2
$echoline
