#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
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
echo '# Test of $ZSYSLOG()'
echo "Ignore following error messages which are just used to muck up messaging buffers (SUSPENDING and DBCERR)"
set time_before = `date +"%b %e %H:%M:%S"`
$gtm_dist/mumps -run zsyslog
#
# Collect syslog info
#
$gtm_tst/com/getoper.csh "$time_before" "" zsyslog.syslog.txt
#
# Locate our messages and pull into reference file.
#
$grep bogus zsyslog.syslog.txt
