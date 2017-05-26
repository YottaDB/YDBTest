#! /usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "Testing D9E04002445"

# Create database
# This test does backward recovery (and before image journaling) which is not suppored by MM access method. Force BG access method
source $gtm_tst/com/gtm_test_setbgaccess.csh
$gtm_tst/com/dbcreate.csh mumps

# Turn on journaling
$MUPIP set -journal=enable,on,before,sync_io -reg DEFAULT

# Crash the database
$GTM << EOF
set ^a=1
zsystem "$kill9 "_\$job
EOF

# If a flush timer pops while waiting on zsystem above, the kill -9 could hit the running GT.M process while it
# is in the middle of executing wcs_wtstart. This could potentially leave some dirty buffers hanging in the shared
# memory. So, set the white box test case to avoid asserts in wcs_flu.c
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 29

# Recover the database and check the journal file isn't open with O_SYNC flag.
$truss $MUPIP journal -recover -backward '*' >& truss_recover.txt
$grep -E "open.*mumps.mjl.*SYNC" truss_recover.txt

# Crash the database
$GTM << EOF
set ^a=1
zsystem "$kill9 "_\$job
EOF

# Rundown the database and check that the journal file is open with O_SYNC flag.
$truss $MUPIP rundown -region DEFAULT -override >& truss_rundown.txt
$grep -E "open.*mumps.mjl.*SYNC" truss_rundown.txt > /dev/null
if ($status) then
	# For OSF1 : there's a reporting issue with trace that prevent us from getting the O_SYNC flag, let the test pass.
	# For HOST_HP-UX_PA_RISC : Until tusc is installed on lester, let the test pass.
	if (("osf1" != "$gtm_test_osname") && (("HOST_HP-UX_PA_RISC" != "$gtm_test_os_machtype") || ("`which tusc`" != "tusc: Command not found."))) then
		echo "MUPIP rundown didn't open mumps.mjl with O_SYNC.  Check truss_rundown.txt."
	endif
endif

# Check database integrity
$gtm_tst/com/dbcheck.csh

