#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# -- Test that MUPIP INTEG immediately after a crashed shutdown works fine without switching journals.
# -- We do this in a loop of 5 times to ensure this test only takes around 1 minute to run and not longer.
#
@ num = 0
setenv gtmgbldir mumps.gld
$GDE exit
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif

# This test does kill -9 followed by a MUPIP INTEG. A kill -9 could hit the running GT.M process while it
# was in the middle of executing wcs_wtstart. This could potentially leave some dirty buffers hanging in the shared
# memory. So, set the white box test case to avoid asserts in wcs_flu.c
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 29

while ($num < 5)
	echo "---------------------------------------------------------------------------------------------"
	echo "Iteration number : $num "
	echo "---------------------------------------------------------------------------------------------"
	rm -f mumps.dat
	$MUPIP create
	rm -f mumps.mjl*
	$MUPIP set -journal="enable,on,before" -reg "*"
	$GTM << EOF
	d ^c002079
EOF
	$MUPIP integ -reg "*"
	set exitstatus = $status
	if ($exitstatus != 0) then
		exit
	endif
	$MUPIP rundown -reg "*"	# ensure shared memory and semaphores are removed
	@ num = $num + 1
end

$MUPIP rundown -relinkctl >&! mupip_rundown_rctl.logx
