#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Tests GTM correctly cleans buffers which were allocated due to a missing global directory
#
echo '# Updating a non existant database 100 times, comparing memory allocated to an initial baseline to check for a memory leak'
$ydb_dist/mumps -run gtm8855 >& dbupdates.outx
cat dbupdates.outx |& $grep "Initial Memory Allocated"
cat dbupdates.outx |& $grep TEST
