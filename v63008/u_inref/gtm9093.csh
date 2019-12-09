#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
#
echo '# The $translate command returns a string that results from replacing or dropping'
echo 'characters in the first of its arguments as specified by the pattern of its other arguments.'
echo 'In V6.3-006 and V6.3-007, it could cause a sig11 if a previous call to $translate had been'
echo 'passed an undefined argument.'

echo '# Verifying that "$translate" does not sig11'
echo '# Should run for 15 seconds'
$gtm_dist/mumps -r gtm9093
