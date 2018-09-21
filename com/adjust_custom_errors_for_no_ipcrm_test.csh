#!/usr/local/bin/tcsh -f
#################################################################
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

if ($?gtm_custom_errors) then
	# Since this test does a kill -9, it is possible we get a DBDANGER in the syslog. If custom errors is turned on,
	# that would cause an instance freeze which would hang this test. So remove DBDANGER from the list of errors
	# that can turn on instance freeze.
	$grep -v 'DBDANGER' $gtm_custom_errors >&! new_custom_errors_sample.txt
	$cprcp new_custom_errors_sample.txt $SEC_SIDE
	setenv gtm_custom_errors new_custom_errors_sample.txt
endif
