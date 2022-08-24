#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '# Test that VIEW "NOISOLATION" optimization affects non-TP transactions like it does TP transactions.'
echo '# In the below test, ^x(n) is incremented by each of the 5 processes (for 5000 times each). All of the'
echo '# counters live in the same data block. We expect that ISOLATION runs will have type 13 restarts while'
echo '# NOISOLATION runs will have type 14 restarts (restart type t_blkmod_t_end3 vs t_blkmod_t_end4).'

setenv acc_meth "BG"  # Make sure we only do BG as MM disables NOISOLATION
$gtm_tst/com/dbcreate.csh mumps

# Be sure to capture all NONTPRESTART messages
setenv gtm_nontprestart_log_first 1
setenv gtm_nontprestart_log_delta 1
echo
echo "# Case (1) : Invoking :mumps -run gtm9230^gtm9230: with VIEW NOISOLATION turned OFF"
set syslog1_begin = `date +"%b %e %H:%M:%S"`
logger "***************** gtm9230 - starting with case 1:"
$gtm_dist/mumps -run gtm9230^gtm9230 "ISOLATION"
# Rename the *.mjo and *.mje files before they get overwritten by the next invocation
foreach file (child*.mj*)
	mv $file ISOLATION_$file
end
# Collect the syslog messages for the ISOLATION run
$gtm_tst/com/getoper.csh "$syslog1_begin" "" syslog_ISOLATION.txt
echo
echo "# Case (2) : Invoking :mumps -run gtm9230^gtm9230: with VIEW NOISOLATION turned ON"
sleep 1 # Gives us a clean fence between the ISO and NOISO cases
set syslog2_begin = `date +"%b %e %H:%M:%S"`
logger "***************** gtm9230 - switching to case 2:"
$gtm_dist/mumps -run gtm9230^gtm9230 "NOISOLATION"
# Rename the *.mjo and *.mje files so we know they correspond to the NOISOLATION run
foreach file (child*.mj*)
	mv $file NOISOLATION_$file
end
# Collect the syslog messages for the NOISOLATION run
$gtm_tst/com/getoper.csh "$syslog2_begin" "" syslog_NOISOLATION.txt
echo
echo '# Verify the restart types from the ISOLATION and NOISOLATION runs:'
$gtm_dist/mumps -run DriveSyslogValidation^gtm9230
echo
echo '# Validate our database'
$gtm_tst/com/dbcheck.csh
