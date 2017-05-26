#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Run $ZSYSLOG() test keeping track of start/stop time (plus a few seconds padding since test is fast)
#
echo "Ignore following error messages which are just used to muck up messaging buffers (SUSPENDING and DBCERR)"
set time_before = `date +"%b %e %H:%M:%S"`
$gtm_dist/mumps -run zsyslog
sleep 3
set time_after = `date +"%b %e %H:%M:%S"`
#
# Collect operator log info
#
$gtm_tst/com/getoper.csh "$time_before" "$time_after" zsyslog.syslog.txt
#
# Locate our messages and pull into reference file.
#
$grep bogus zsyslog.syslog.txt
